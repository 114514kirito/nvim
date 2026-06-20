-- ============================================
-- blink.cmp — snippet_forward 优先
-- Tab: snippet_forward → select_and_accept → fallback
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
          "fallback",
        },
      })
      -- CR 和 C-y 已经在 "enter" preset 中
    end,
  },
}
