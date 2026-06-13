-- ============================================================
-- plugins/vscode.lua — VSCode 模式下禁用冗余插件
-- 当 Neovim 由 vscode-neovim 启动时，vim.g.vscode == 1
-- 此文件禁用所有 UI/LSP/DAP/补全插件，只保留纯编辑增强
-- ============================================================

-- ── 禁用整个 LazyVim 核心（noice, neo-tree, telescope 等全部跳过）──
if vim.g.vscode then
  -- 通知 LazyVim: 当前在 VSCode 中
  vim.g.lazyvim_ui_disable = true

  -- 禁用 Neovim 原生 UI 选项
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.signcolumn = "no"
  vim.opt.cursorline = false
  vim.opt.cursorcolumn = false
  vim.opt.colorcolumn = ""
  vim.opt.laststatus = 0

  -- 使用 VSCode 剪贴板
  vim.opt.clipboard = "unnamedplus"
  vim.opt.swapfile = false
  vim.opt.mouse = ""
end

-- ============================================================
-- 返回 VSCode 模式下保留的纯编辑插件
-- 这些插件不会有 UI，只增强文本编辑体验
-- ============================================================

return {
  -- ── flash.nvim: s/S 快速跳转（绝对保留，VSCode 中没有替代品）──
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    cond = function()
      return vim.g.vscode == 1
    end,
    opts = {
      modes = {
        search = { enabled = false }, -- VSCode 内搜索用 Ctrl+F
        char = { enabled = true },
      },
      -- 减少 UI 闪烁
      highlight = { backdrop = false },
    },
  },

  -- ── mini.surround: ys/ds/cs 环绕操作 ──
  {
    "nvim-mini/mini.surround",
    version = false,
    cond = function()
      return vim.g.vscode == 1
    end,
    config = true,
  },

  -- ── mini.ai: 增强文本对象 ia/aa ──
  {
    "nvim-mini/mini.ai",
    version = false,
    cond = function()
      return vim.g.vscode == 1
    end,
    config = true,
  },

  -- ── mini.pairs: 更精准的自动配对 ──
  {
    "nvim-mini/mini.pairs",
    version = false,
    cond = function()
      return vim.g.vscode == 1
    end,
    config = true,
  },

  -- ── mini.comment: gcc/gc 注释 ──
  {
    "nvim-mini/mini.comment",
    version = false,
    cond = function()
      return vim.g.vscode == 1
    end,
    config = true,
  },

  -- ── mini.move: Alt+j/k 整行移动 ──
  {
    "nvim-mini/mini.move",
    version = false,
    cond = function()
      return vim.g.vscode == 1
    end,
    config = true,
  },

  -- ── vim-repeat: 让 . 重复插件操作 ──
  {
    "tpope/vim-repeat",
    cond = function()
      return vim.g.vscode == 1
    end,
  },
}
