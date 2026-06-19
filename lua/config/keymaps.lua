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

  -- ── 左手键盘优化 ────────────────────────────

  -- jk/jj 替代 Escape（无需离开主键区）
  vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape (jk)" })
  vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape (jj)" })

  -- <C-s> 保存（左手，比 :w 快）
  vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

  -- <C-q> 关闭当前窗口（左手，代替 :q）
  vim.keymap.set("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit window" })

  -- 水平/垂直分屏（左手，用 | 和 _ 记：竖线和横线）
  vim.keymap.set("n", "<C-w>v", "<C-w>v", { desc = "Vertical split", remap = true })
  vim.keymap.set("n", "<C-w>s", "<C-w>s", { desc = "Horizontal split", remap = true })

  -- 窗口间移动（HJKL 不用离开主键区）
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to down window" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to up window" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

  -- <leader>+hjkl 调整窗口大小
  vim.keymap.set("n", "<C-w>H", "<cmd>vertical resize -2<CR>", { desc = "Shrink width" })
  vim.keymap.set("n", "<C-w>L", "<cmd>vertical resize +2<CR>", { desc = "Expand width" })
  vim.keymap.set("n", "<C-w>J", "<cmd>resize -2<CR>", { desc = "Shrink height" })
  vim.keymap.set("n", "<C-w>K", "<cmd>resize +2<CR>", { desc = "Expand height" })
end

-- Escape clears search highlight（终端和 VSCode 都生效）
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
