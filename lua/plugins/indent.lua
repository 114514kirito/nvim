-- VSCode 模式：缩进由 VSCode 处理
if vim.g.vscode then return {} end

-- ============================================
-- 缩进: 基于 treesitter 缩进，仅为有问题的语言禁用
-- ============================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = {
        enable = true,
        disable = { "c", "cpp" },
      },
    },
  },
}
