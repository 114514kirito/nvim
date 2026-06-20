-- ============================================
-- blink.cmp — snippet_forward 优先
-- Tab: snippet_forward → select_and_accept → fallback
-- S-Tab: select_prev → snippet_backward → fallback
-- Enter: accept（确认当前选中项）
-- ============================================
if vim.g.vscode then return {} end

return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        preset = "default",
        ["<Tab>"] = {
          "snippet_forward",
          "select_and_accept",
          "fallback",
        },
        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          "fallback",
        },
        ["<CR>"] = { "accept", "fallback" },
      })
    end,
  },

  -- 诊断命令：:CheckCmp — 检查 snippet/completion 状态
  {
    "saghen/blink.cmp",
    cmd = "CheckCmp",
    config = function()
      vim.api.nvim_create_user_command("CheckCmp", function()
        local lines = {}

        -- 检查 snippet 引擎
        local has_native = pcall(function() return vim.snippet.active end)
        table.insert(lines, "vim.snippet available: " .. tostring(has_native))

        if has_native then
          local active = pcall(vim.snippet.active, { direction = 1 })
          table.insert(lines, "vim.snippet active: " .. tostring(active))
        end

        -- 检查 blink.cmp snippets config
        local snippets = require("blink.cmp.config").snippets
        table.insert(lines, "blink snippets preset: " .. tostring(snippets.preset))

        -- 检查 clangd 配置
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
          if client.name == "clangd" then
            table.insert(lines, "clangd attached: yes")
            local cmd = client.config.cmd or {}
            local has_placeholders = false
            for _, arg in ipairs(cmd) do
              if arg:find("function%-arg%-placeholders") then
                has_placeholders = true
              end
            end
            table.insert(lines, "  --function-arg-placeholders: " .. tostring(has_placeholders))

            local init = client.config.init_options or {}
            table.insert(lines, "  usePlaceholders: " .. tostring(init.usePlaceholders))

            -- 检查 completion capabilities
            local caps = client.server_capabilities.completionProvider or {}
            table.insert(lines, "  triggerCharacters: " .. vim.inspect(caps.triggerCharacters or {}))
            break
          end
        end

        -- 检查 Tab 键映射
        local maps = vim.api.nvim_buf_get_keymap(0, "i")
        for _, m in ipairs(maps) do
          if m.lhs == "<Tab>" and m.desc and m.desc:find("blink") then
            table.insert(lines, "Tab keymap: " .. m.desc)
            break
          end
        end

        -- 输出
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        local width = 0
        for _, line in ipairs(lines) do
          width = math.max(width, #line)
        end
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = math.min(width + 2, vim.o.columns - 4),
          height = #lines + 2,
          col = 2,
          row = 2,
          style = "minimal",
          border = "rounded",
          title = " CheckCmp ",
          title_pos = "center",
        })
        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf })
      end, { desc = "Check blink.cmp / clangd snippet status" })
    end,
  },
}
