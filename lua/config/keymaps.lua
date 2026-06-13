-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- 仅在终端 Neovim 中设置这些映射（VSCode 有自己的快捷键体系）
if not vim.g.vscode then
  -- Swap 0 and ^
  -- 0 jumps to first non-whitespace, ^ jumps to column 0 (matching old .vimrc behavior)
  vim.keymap.set("n", "0", "^", { desc = "First non-whitespace char" })
  vim.keymap.set("n", "^", "0", { desc = "Column 0 (beginning of line)" })

  -- <C-w>e : equalize all window sizes (代替 <C-w>=)
  vim.keymap.set("n", "<C-w>e", "<C-w>=", { desc = "Equalize windows" })
end

-- Escape clears search highlight（终端和 VSCode 都生效）
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
