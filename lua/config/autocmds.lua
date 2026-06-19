-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- RISC-V assembly: .s files → asm filetype
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("riscv_ft", { clear = true }),
  pattern = "*.s",
  callback = function()
    vim.bo.filetype = "asm"
  end,
})

-- C/C++ indentation: cindent handles case/switch/#define/labels
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("c_cindent", { clear = true }),
  pattern = { "c", "cpp" },
  callback = function()
    vim.bo.cindent = true
  end,
})

-- Markdown: disable spellcheck/wrap/conceal (let markview render cleanly)
if not vim.g.vscode then
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("markdown_opt", { clear = true }),
    pattern = "markdown",
    callback = function()
      vim.opt_local.spell = false
      vim.opt_local.wrap = false
      vim.opt_local.conceallevel = 0
    end,
  })
end
