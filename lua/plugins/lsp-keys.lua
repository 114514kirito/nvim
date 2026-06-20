-- VSCode 模式：LSP 由 VSCode 原生扩展处理
if vim.g.vscode then return {} end

-- ============================================================
-- LSP 配置 — clangd 命令行
-- keymaps (gd/gi/gh/K) 通过 autocmds.lua 的 LspAttach 设置
-- ============================================================

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=**",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
    },
  },
}
