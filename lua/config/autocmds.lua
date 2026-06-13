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
