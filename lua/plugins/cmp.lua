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
}
