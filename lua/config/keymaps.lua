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

-- gh: LSP 引用（覆盖 vim 内置 Select mode）
vim.keymap.set("n", "gh", function()
  if has_lsp() then
    vim.lsp.buf.references()
  else
    vim.cmd("normal! gh")
  end
end, { desc = "References" })

-- gd: LSP 跳转到定义（覆盖 vim 内置 goto local declaration）
vim.keymap.set("n", "gd", function()
  if has_lsp() then
    vim.lsp.buf.definition()
  else
    vim.cmd("normal! gd")
  end
end, { desc = "Goto Definition" })

-- K: LSP 增强悬浮文档（覆盖 vim 内置 man page lookup）
vim.keymap.set("n", "K", function()
  if has_lsp() then
    vim.lsp.buf.hover({
      border = "rounded",
      max_width = math.floor(vim.o.columns * 0.5),
      max_height = math.floor(vim.o.lines * 0.4),
    })
  else
    vim.cmd("normal! K")
  end
end, { desc = "Enhanced Hover" })

-- gi: 浮窗预览实现（LazyVim 未提供）
vim.keymap.set("n", "gi", function()
  if not has_lsp() then return end
  local params = vim.lsp.util.make_position_params(0)
  vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result)
    if err then
      vim.notify("LSP error: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end
    local locs = {}
    if not result or vim.isempty(result) then
      -- no result
    elseif result.uri then
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
    if #locs == 0 then
      vim.notify("No implementation found", vim.log.levels.WARN)
    elseif #locs == 1 then
      vim.lsp.util.preview_location(locs[1], {
        border = "rounded",
        max_width = math.floor(vim.o.columns * 0.65),
        max_height = math.floor(vim.o.lines * 0.80),
      })
    else
      Snacks.picker.lsp_implementations()
    end
  end)
end, { desc = "Peek Implementation" })
