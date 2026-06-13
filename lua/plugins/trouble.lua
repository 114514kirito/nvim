return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
      { "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", desc = "References (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<CR>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location List" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix List" },
    },
    opts = {
      modes = {
        preview_float = {
          relative = "editor",
          border = "rounded",
        },
      },
    },
  },
}
