-- VSCode mode: markdown is handled by VSCode's built-in renderer
if vim.g.vscode then return {} end

return {
  -- Disable markdownlint linter
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },

  -- Markdown preview keymap
  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Preview Markdown" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop Preview" },
    },
  },

  -- Inline markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    opts = {
      preset = "lazy",
      render_modes = { "n", "c" },
    },
  },
}
