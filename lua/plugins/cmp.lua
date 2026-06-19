-- ============================================
-- blink.cmp — super-tab preset
-- Tab: snippet 中则接受 → 否则 select_and_accept（选下一个/确认）→ snippet_forward → fallback
-- S-Tab: select_prev → snippet_backward → fallback
-- Enter: 始终接受当前选中项
-- ============================================
if vim.g.vscode then return {} end

return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- super-tab preset: Tab 既能导航也能确认，Enter 也是确认
      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        preset = "super-tab",
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      })
    end,
  },
}
