-- ============================================
-- blink.cmp (LazyVim v8 default completion engine)
-- Tab: snippet_forward first (for function arg navigation),
-- then select_and_accept (for completion menu)
-- ============================================
if vim.g.vscode then return {} end

return {
  {
    "saghen/blink.cmp",
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        -- Tab: snippet_forward first (for function arg navigation),
        -- then select_and_accept (for completion menu)
        ["<Tab>"] = {
          LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
          "select_and_accept",
          "fallback",
        },
        ["<S-Tab>"] = {
          "select_prev",
          LazyVim.cmp.map({ "snippet_backward" }),
          "fallback",
        },
      })
    end,
  },
}
