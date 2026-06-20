-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- RISC-V assembly: .s files → asm filetype
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("riscv_ft", { clear = true }),
  pattern = "*.s",
  callback = function()
    vim.bo.filetype = "asm"
  end,
})

-- C/C++ indentation: cindent handles case/switch/#define/labels
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("c_cindent", { clear = true }),
  pattern = { "c", "cpp" },
  callback = function()
    vim.bo.cindent = true
  end,
})

-- Markdown: disable spellcheck/wrap/conceal (let markview render cleanly)
if not vim.g.vscode then
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("markdown_opt", { clear = true }),
    pattern = "markdown",
    callback = function()
      vim.opt_local.spell = false
      vim.opt_local.wrap = false
      vim.opt_local.conceallevel = 0
    end,
  })
end

-- :CheckCmp — 诊断 blink.cmp / clangd snippet 状态
vim.api.nvim_create_user_command("CheckCmp", function()
  local lines = {}

  -- 1. Neovim snippet 引擎
  table.insert(lines, "=== vim.snippet ===")
  local has_native = pcall(function() return vim.snippet.active end)
  table.insert(lines, "  available: " .. tostring(has_native))
  if has_native then
    local ok, active = pcall(vim.snippet.active, { direction = 1 })
    table.insert(lines, "  active: " .. tostring(ok and active))
  end

  -- 2. blink.cmp snippets
  table.insert(lines, "")
  table.insert(lines, "=== blink.cmp ===")
  local ok, snippets = pcall(function() return require("blink.cmp.config").snippets end)
  if ok then
    table.insert(lines, "  preset: " .. tostring(snippets.preset))
    local expand = snippets.expand
    table.insert(lines, "  expand: " .. (tostring(expand):match("function") and "function" or tostring(expand)))
  else
    table.insert(lines, "  ERROR: " .. tostring(snippets))
  end

  -- 3. LSP (clangd)
  table.insert(lines, "")
  table.insert(lines, "=== clangd ===")
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local found = false
  for _, client in ipairs(clients) do
    if client.name == "clangd" then
      found = true
      table.insert(lines, "  attached: yes")
      local cmd = client.config.cmd or {}
      for _, arg in ipairs(cmd) do
        if arg:find("placeholder") or arg:find("query%-driver") then
          table.insert(lines, "  " .. arg)
        end
      end
      local init = client.config.init_options or {}
      table.insert(lines, "  usePlaceholders: " .. tostring(init.usePlaceholders))
      table.insert(lines, "  completeUnimported: " .. tostring(init.completeUnimported))
      break
    end
  end
  if not found then
    table.insert(lines, "  NOT ATTACHED — open a C/C++ file first")
  end

  -- 4. 项目编译数据库
  table.insert(lines, "")
  table.insert(lines, "=== project ===")
  local root = vim.fs.root(0, { "compile_commands.json", "compile_flags.txt", ".clangd", ".git", "Makefile" }) or "?"
  table.insert(lines, "  root: " .. root)
  local has_ccdb = vim.fn.filereadable(root .. "/compile_commands.json") == 1
  local has_flags = vim.fn.filereadable(root .. "/compile_flags.txt") == 1
  local has_clangd = vim.fn.filereadable(root .. "/.clangd") == 1
  table.insert(lines, "  compile_commands.json: " .. tostring(has_ccdb))
  table.insert(lines, "  compile_flags.txt: " .. tostring(has_flags))
  table.insert(lines, "  .clangd: " .. tostring(has_clangd))
  if not has_ccdb and not has_flags and not has_clangd then
    table.insert(lines, "  WARNING: no compilation database — user functions may not be indexed")
    table.insert(lines, "  Fix: cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. (CMake)")
    table.insert(lines, "  or: create compile_flags.txt with -I/path/to/headers")
  end

  -- 5. Tab keymap
  table.insert(lines, "")
  table.insert(lines, "=== keymaps ===")
  local maps = vim.api.nvim_buf_get_keymap(0, "i")
  for _, m in ipairs(maps) do
    if (m.lhs == "<Tab>" or m.lhs == "<CR>") and m.desc and m.desc:find("blink") then
      table.insert(lines, "  " .. m.lhs .. ": " .. m.desc)
    end
  end

  -- 输出
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, #line)
  end
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.min(width + 2, vim.o.columns - 4),
    height = math.min(#lines + 2, vim.o.lines - 4),
    col = 2,
    row = 2,
    style = "minimal",
    border = "rounded",
    title = " CheckCmp ",
    title_pos = "center",
  })
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end, { buffer = buf })
end, { desc = "Diagnose blink.cmp / clangd snippet status" })

-- ============================================================
-- LSP Attach — 在所有 LSP buffer 上设置 keymaps
-- 用 vim.schedule 确保在其他 LspAttach handler 之后执行
-- ============================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_keymaps", { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      local bufnr = ev.buf
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- gd: 跳转到定义
    map("gd", function()
      vim.lsp.buf.definition()
    end, "Goto Definition")

    -- gi: 浮窗预览实现
    map("gi", function()
      local params = vim.lsp.util.make_position_params(0)
      vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result)
        if err then
          vim.notify("LSP error: " .. vim.inspect(err), vim.log.levels.ERROR)
          return
        end
        local locs = {}
        if not result or vim.isempty(result) then
          -- no results
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
    end, "Peek Implementation")

    -- gh: 查看引用
    map("gh", function()
      vim.lsp.buf.references()
    end, "References")

    -- K: 增强悬浮文档
    map("K", function()
      vim.lsp.buf.hover({
        border = "rounded",
        max_width = math.floor(vim.o.columns * 0.5),
        max_height = math.floor(vim.o.lines * 0.4),
      })
    end, "Enhanced Hover")
    end)
  end,
})
