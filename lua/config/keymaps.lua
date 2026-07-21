-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- 仅在终端 Neovim 中设置这些映射（VSCode 有自己的快捷键体系）
if not vim.g.vscode then
  -- Swap 0 and ^
  -- 0 jumps to first non-whitespace, ^ jumps to column 0 (matching old .vimrc behavior)
  vim.keymap.set("n", "0", "^", { desc = "First non-whitespace char" })
  vim.keymap.set("n", "^", "0", { desc = "Column 0 (beginning of line)" })

  -- <C-w>e : equalize all window sizes (代替 <C-w>=)
  vim.keymap.set("n", "<C-w>e", "<C-w>=", { desc = "Equalize windows" })

  -- ── 左手键盘优化 ────────────────────────────

  -- jk/jj 替代 Escape（无需离开主键区）
  vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape (jk)" })
  vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape (jj)" })

  -- <C-s> 保存（左手，比 :w 快）
  vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

  -- <C-q> 关闭当前窗口（左手，代替 :q）
  vim.keymap.set("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit window" })

  -- <leader>nh 临时清除搜索高亮（n/N 跳转后自动恢复）
  vim.keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
end

-- ============================================================
-- LSP Keymaps — 全局映射覆盖 vim 内置键位
-- 用全局映射 + LSP guard 确保一定覆盖内置 gh/gd/K 等
-- ============================================================
local function has_lsp()
  return not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0 }))
end

-- ── LSP Helpers ─────────────────────────────────────────────

-- Parse LSP location results into a flat list of {uri, range}
local function parse_lsp_locations(result)
  local locs = {}
  if not result or vim.isempty(result) then
    return locs
  end
  if result.uri then
    locs = { { uri = result.uri, range = result.targetSelectionRange or result.targetRange or result.range } }
  elseif result.targetUri then
    locs = { { uri = result.targetUri, range = result.targetSelectionRange or result.targetRange } }
  elseif result[1] then
    for _, item in ipairs(result) do
      if item.uri then
        locs[#locs + 1] = { uri = item.uri, range = item.targetSelectionRange or item.targetRange or item.range }
      elseif item.targetUri then
        locs[#locs + 1] = { uri = item.targetUri, range = item.targetSelectionRange or item.targetRange }
      end
    end
  end
  return locs
end

-- Check if a URI points to a C/C++ implementation file (.c/.cpp/.cc/.cxx — not headers)
local function is_c_impl_file(uri)
  local path = vim.uri_to_fname(uri):lower()
  return path:match("%.c$") or path:match("%.cpp$") or path:match("%.cc$") or path:match("%.cxx$")
end

-- Format a location for vim.ui.select display
local function format_location(loc)
  local fname = vim.uri_to_fname(loc.uri)
  local rel = vim.fn.fnamemodify(fname, ":~:.")
  local line = loc.range.start.line + 1
  return string.format("%s:%d", rel, line)
end

-- Shared: get implementation locations (textDocument/implementation)
-- Falls back to textDocument/references filtered for .c/.cpp files
-- when clangd returns no implementation results (common in C projects).
local function get_implementation_locations(callback)
  local params = vim.lsp.util.make_position_params(0)
  vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result)
    if err then
      vim.notify("LSP error: " .. vim.inspect(err), vim.log.levels.ERROR)
      callback({})
      return
    end
    local locs = parse_lsp_locations(result)
    if #locs > 0 then
      callback(locs)
      return
    end
    -- Fallback: scan references, keep only .c/.cpp/.cc/.cxx files
    vim.lsp.buf_request(0, "textDocument/references", params, function(err2, refs)
      if err2 then
        vim.notify("LSP error: " .. vim.inspect(err2), vim.log.levels.ERROR)
        callback({})
        return
      end
      local impl_locs = {}
      for _, loc in ipairs(parse_lsp_locations(refs)) do
        if is_c_impl_file(loc.uri) then
          impl_locs[#impl_locs + 1] = loc
        end
      end
      callback(impl_locs)
    end)
  end)
end

-- ── Keymaps ─────────────────────────────────────────────────

-- gh: LSP 引用（覆盖 vim 内置 Select mode）
vim.keymap.set("n", "gh", function()
  if has_lsp() then
    vim.lsp.buf.references()
  else
    vim.notify("No LSP client attached", vim.log.levels.WARN)
  end
end, { desc = "References" })

-- gd: LSP 跳转到定义（覆盖 vim 内置 goto local declaration）
vim.keymap.set("n", "gd", function()
  if has_lsp() then
    vim.lsp.buf.definition()
  else
    vim.notify("No LSP client attached", vim.log.levels.WARN)
  end
end, { desc = "Goto Definition" })

-- gD: 跳转到实现 — 从 .h 声明跳到 .c 函数体
--     先查 textDocument/implementation；clangd 无结果时 fallback 到 references
--     过滤 .c/.cpp/.cc/.cxx 文件，排除头文件
vim.keymap.set("n", "gD", function()
  if not has_lsp() then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end
  get_implementation_locations(function(locs)
    if #locs == 0 then
      vim.notify("No implementation found", vim.log.levels.WARN)
    elseif #locs == 1 then
      vim.lsp.util.jump_to_location(locs[1])
    else
      vim.ui.select(locs, {
        prompt = "Go to implementation:",
        format_item = format_location,
      }, function(choice)
        if choice then vim.lsp.util.jump_to_location(choice) end
      end)
    end
  end)
end, { desc = "Jump to Implementation" })

-- K: LSP 增强悬浮文档（覆盖 vim 内置 man page lookup）
vim.keymap.set("n", "K", function()
  if has_lsp() then
    vim.lsp.buf.hover({
      border = "rounded",
      max_width = math.floor(vim.o.columns * 0.5),
      max_height = math.floor(vim.o.lines * 0.4),
    })
  else
    vim.notify("No LSP client attached", vim.log.levels.WARN)
  end
end, { desc = "Enhanced Hover" })

-- gi: 浮窗预览实现 — 看一眼函数体，不离开当前位置
--     同样享受 references fallback，C 语言也可用
vim.keymap.set("n", "gi", function()
  if not has_lsp() then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end
  get_implementation_locations(function(locs)
    if #locs == 0 then
      vim.notify("No implementation found", vim.log.levels.WARN)
    elseif #locs == 1 then
      vim.lsp.util.preview_location(locs[1], {
        border = "rounded",
        max_width = math.floor(vim.o.columns * 0.65),
        max_height = math.floor(vim.o.lines * 0.80),
      })
    else
      vim.ui.select(locs, {
        prompt = "Peek implementation:",
        format_item = format_location,
      }, function(choice)
        if choice then
          vim.lsp.util.preview_location(choice, {
            border = "rounded",
            max_width = math.floor(vim.o.columns * 0.65),
            max_height = math.floor(vim.o.lines * 0.80),
          })
        end
      end)
    end
  end)
end, { desc = "Peek Implementation" })
