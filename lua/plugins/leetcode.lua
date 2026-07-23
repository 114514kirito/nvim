-- ============================================
-- leetcode.nvim: 终端刷题
-- 依赖 nui.nvim + plenary.nvim（已安装）
-- 使用 snacks.nvim 作为 picker（LazyVim 预装）
-- 使用 tree-sitter-html 解析题目（LazyVim 预装）
-- ============================================
if vim.g.vscode then return {} end

return {
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- snacks / telescope / treesitter 在 LazyVim 中已预装
    },
    opts = {
      arg = "leetcode.nvim",
      lang = "cpp",

      --- 编辑器
      editor = {
        fold_imports = true,          -- 折叠 #include / using，聚焦核心逻辑
        reset_previous_code = true,   -- 每题从空白模板开始
      },

      --- 题目描述面板
      description = {
        position = "left",
        width = "40%",
        show_stats = true,
      },

      --- 运行/提交控制台
      console = {
        open_on_runcode = true,
        dir = "row",
        size = { width = "90%", height = "75%" },
        result = { size = "60%" },
        testcase = { size = "40%" },
      },

      --- 非独立模式：不需要空 buffer list 即可启动
      plugins = {
        non_standalone = true,
      },

      --- 问题列表缓存（7 天更新一次）
      cache = {
        update_interval = 60 * 60 * 24 * 7,
      },

      --- C++ 注入：预置万能头文件 + std 命名空间
      injector = {
        ["cpp"] = {
          imports = function()
            return { "#include <bits/stdc++.h>", "using namespace std;" }
          end,
        },
      },

      --- 中国区支持 — leetcode.cn
      cn = {
        enabled = true,
      },
      keys = {
        toggle = { "q", "<Esc>" },
        confirm = { "<CR>" },
        reset_testcases = { "r" },
        use_testcase = { "U" },
        focus_testcases = { "H" },
        focus_result = { "L" },
      },
    },

    --- 全局快捷键（<leader>L 前缀，不会与 LSP/LazyVim 内置键位冲突）
    keys = {
      { "<leader>Ll", "<cmd>Leet<CR>",        desc = "LeetCode 面板" },
      { "<leader>Ld", "<cmd>Leet daily<CR>",   desc = "每日一题" },
      { "<leader>Lr", "<cmd>Leet random<CR>",  desc = "随机一题" },
      { "<leader>Ls", "<cmd>Leet list<CR>",    desc = "搜索题目" },
      { "<leader>Lt", "<cmd>Leet run<CR>",     desc = "运行测试" },
      { "<leader>LS", "<cmd>Leet submit<CR>",  desc = "提交代码" },
      { "<leader>LT", "<cmd>Leet tabs<CR>",    desc = "切换题目标签" },
      { "<leader>Lg", "<cmd>Leet lang<CR>",    desc = "切换语言" },
    },
  },
}
