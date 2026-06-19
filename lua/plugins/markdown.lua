return {
  -- 关闭 markdownlint linter（避免 markdownlint 规则导致的 warning 红线）
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
}

-- 关闭 LazyVim 默认对 markdown 开启的拼写检查（这是"爆红"的真正元凶）
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_opt", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.wrap = false
  end,
})
