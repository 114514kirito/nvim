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

  -- <leader>nh 临时清除搜索高亮（n/N 跳转后自动恢复）
  vim.keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
end
