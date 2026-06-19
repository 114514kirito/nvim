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
  -- Disable spellcheck and conceal in markdown (let markview render cleanly)
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("markdown_opt", { clear = true }),
        pattern = "markdown",
        callback = function()
          vim.opt_local.spell = false
          vim.opt_local.wrap = false
          vim.opt_local.conceallevel = 0
        end,
      })
    end,
  },
}
