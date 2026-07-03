-- ============================================
-- blink.cmp — snippet_forward 优先
-- Tab: snippet_forward → select_and_accept → cindent 重缩进 → fallback
-- Enter / C-y: accept
-- ============================================
if vim.g.vscode then return {} end

return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- 不覆盖 preset，保持 LazyVim 默认的 "enter"
      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        ["<Tab>"] = {
          "snippet_forward",
          "select_and_accept",
          function(cmp)
            -- C/C++ cindent 重缩进：光标在行首空白区时，按缩进规则重新对齐
            local ft = vim.bo.filetype
            if ft ~= "c" and ft ~= "cpp" then return cmp.fallback() end
            local cursor = vim.api.nvim_win_get_cursor(0)
            local line = vim.api.nvim_get_current_line()
            local col = cursor[2]
            if col > 0 and line:sub(1, col):find("[^%s]") then
              return cmp.fallback()
            end
            local indent = vim.fn.cindent(cursor[1])
            if indent > 0 then
              local new_line = string.rep(" ", indent) .. line:gsub("^%s*", "")
              local lnum = cursor[1]
              vim.schedule(function()
                pcall(vim.api.nvim_set_current_line, new_line)
                pcall(vim.api.nvim_win_set_cursor, 0, { lnum, indent })
              end)
            end
            return true -- 已处理，停止 fallback
          end,
          "fallback",
        },
      })
      -- CR 和 C-y 已经在 "enter" preset 中
    end,
  },
}
