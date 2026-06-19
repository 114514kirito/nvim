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

-- Force mini.pairs to load — LazyVim's event="VeryLazy" fails with defaults.lazy=false
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local path = vim.fn.stdpath("data") .. "/lazy/mini.pairs"
    if vim.fn.isdirectory(path) == 1 then
      vim.cmd("set rtp+=" .. path)
      pcall(function()
        require("mini.pairs").setup({
          modes = { insert = true, command = true, terminal = false },
        })
      end)
    end
  end,
})
