-- VSCode 模式：Python LSP 由 VSCode 的 basedpyright/pylance 扩展处理
if vim.g.vscode then return {} end

-- ============================================
-- Python: basedpyright + ruff
-- LazyVim Python extra 已提供: venv-selector, dap-python, neotest
-- ruff LSP 自带 formatting + diagnostics，无需额外 conform/lint 配置
-- ============================================
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                autoImportCompletions = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "standard",
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
      },
    },
  },
}
