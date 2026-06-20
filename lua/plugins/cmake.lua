-- VSCode 模式：构建由 VSCode CMake 扩展处理
if vim.g.vscode then return {} end

return {
  -- cmake-tools 快捷键 + quickfix
  {
    "Civitasv/cmake-tools.nvim",
    keys = {
      { "<leader>cC", "<cmd>CMakeConfigure<CR>", desc = "CMake Configure" },
      { "<leader>cb", "<cmd>CMakeBuild<CR>", desc = "CMake Build" },
      { "<leader>cB", "<cmd>CMakeClean<CR>", desc = "CMake Clean" },
      { "<leader>ce", "<cmd>CMakeRun<CR>", desc = "CMake Run" },
      { "<leader>ct", "<cmd>CMakeTest<CR>", desc = "CMake Test" },
      { "<leader>cs", "<cmd>CMakeStop<CR>", desc = "CMake Stop" },
      { "<leader>cg", "<cmd>CMakeGenerate<CR>", desc = "CMake Generate" },
      { "<leader>cx", "<cmd>CMakeCancel<CR>", desc = "CMake Cancel" },
    },
    opts = {
      quickfix = {
        enabled = true, -- build 错误自动填充 quickfix，[q/]q 跳转
        only_on_failure = false,
      },
    },
  },
}
