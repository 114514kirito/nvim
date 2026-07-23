-- ============================================
-- leetcode.nvim: 终端刷题
-- 依赖 nui.nvim + plenary.nvim（已安装）
-- 使用 snacks.nvim 作为 picker（LazyVim 预装）
-- 使用 tree-sitter-html 解析题目（LazyVim 预装）
--
-- 两种启动方式：
--   独立模式:   终端执行 nvim leetcode.nvim（纯净刷题区）
--   非独立模式: 在已有 nvim 中 <leader>Ll 或 :Leet
-- ============================================
if vim.g.vscode then return {} end

local leet_arg = "leetcode.nvim"

return {
  {
    "kawre/leetcode.nvim",
    lazy = leet_arg ~= vim.fn.argv(0, -1),
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },

    ---@type lc.UserConfig
    opts = {
      arg = "leetcode.nvim",
      lang = "cpp",

      -- ============================================================
      -- 中国区 — leetcode.cn
      -- ============================================================
      cn = {
        enabled = true,
        translator = true,          -- 开启中文翻译
        translate_problems = true,  -- 翻译题目标题 + 描述
      },

      -- ============================================================
      -- 编辑器行为
      -- ============================================================
      editor = {
        fold_imports = true,          -- 折叠 #include / using
        reset_previous_code = true,   -- 每题从空白模板开始
      },

      -- ============================================================
      -- 题目描述面板
      -- ============================================================
      description = {
        position = "left",
        width = "42%",               -- 略宽，更好地展示长题目
        show_stats = true,
      },

      -- ============================================================
      -- 运行/提交控制台
      -- ============================================================
      console = {
        open_on_runcode = true,
        dir = "row",
        size = { width = "90%", height = "75%" },
        result = { size = "60%" },
        testcase = { size = "40%" },
      },

      -- ============================================================
      -- 插件模式
      -- ============================================================
      plugins = {
        non_standalone = true,
      },

      -- ============================================================
      -- 问题列表缓存
      -- ============================================================
      cache = {
        update_interval = 60 * 60 * 24 * 7,
      },

      -- ============================================================
      -- 代码注入：LSP 静默 + 开箱即用
      -- 注入部分在 LeetCode 提交时自动忽略
      -- ============================================================
      injector = {
        ["cpp"] = {
          imports = function()
            return {
              "#include <bits/stdc++.h>",
              "using namespace std;",
            }
          end,
        },
        ["golang"] = {
          before = function()
            return {
              "package main",
              "",
              'import "math"',
              'import "sort"',
              'import "strconv"',
              'import "strings"',
              'import "container/heap"',
              'import "container/list"',
              'import "math/bits"',
            }
          end,
        },
      },

      -- ============================================================
      -- 键盘映射（题目内）
      -- ============================================================
      keys = {
        toggle = { "q", "<Esc>" },
        confirm = { "<CR>" },
        reset_testcases = { "r" },
        use_testcase = { "U" },
        focus_testcases = { "H" },
        focus_result = { "L" },
      },

      -- ============================================================
      -- 主题：适配 tokyonight
      -- 覆盖描述面板中的各元素颜色，提升阅读体验
      -- ============================================================
      theme = {
        -- 难度标签：更鲜明的配色
        easy = { fg = "#4fd6be", bold = true },
        medium = { fg = "#ffc777", bold = true },
        hard = { fg = "#ff757f", bold = true },

        -- 代码块背景：与 Normal 背景融合（避免补丁感）
        code = { italic = true },

        -- 标题/输入输出标签
        header = { bold = true },
        followup = { bold = true },

        -- 链接样式
        link = { underline = true },

        -- 例题 <pre> 背景
        example = { italic = true },

        -- 约束条件
        constraints = {},

        -- 正常文字 / 次要文字（继承 colorscheme）
        normal = {},
        alt = {},
      },

      -- ============================================================
      -- 钩子：进入/离开/打开题目时自动执行
      -- ============================================================
      hooks = {
        -- 进入插件时
        ["enter"] = {
          function()
            -- 隐藏行号、状态栏，最大化沉浸感
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
          end,
        },

        -- 打开题目时：美化描述窗口
        ["question_enter"] = {
          function(q)
            -- 描述面板窗口优化（smooth scrolling + 无折叠列）
            local desc_win = q.description and q.description.winid
            if desc_win and vim.api.nvim_win_is_valid(desc_win) then
              vim.wo[desc_win].foldcolumn = "0"
              vim.wo[desc_win].colorcolumn = ""
              vim.wo[desc_win].cursorline = false
              vim.wo[desc_win].cursorcolumn = false
              -- smooth scroll
              vim.wo[desc_win].smoothscroll = true
            end
          end,
        },
      },
    },

    -- ============================================================
    -- 全局快捷键（<leader>L 前缀）
    -- ============================================================
    keys = {
      { "<leader>Ll", "<cmd>Leet<CR>",        desc = "LeetCode 面板" },
      { "<leader>Ld", "<cmd>Leet daily<CR>",   desc = "每日一题" },
      { "<leader>Lr", "<cmd>Leet random<CR>",  desc = "随机一题" },
      { "<leader>Ls", "<cmd>Leet list<CR>",    desc = "搜索题目" },
      { "<leader>Lt", "<cmd>Leet run<CR>",     desc = "运行测试" },
      { "<leader>LS", "<cmd>Leet submit<CR>",  desc = "提交代码" },
      { "<leader>LT", "<cmd>Leet tabs<CR>",    desc = "切换标签" },
      { "<leader>Lg", "<cmd>Leet lang<CR>",    desc = "切换语言" },
      { "<leader>LD", "<cmd>Leet desc toggle<CR>", desc = "切换题目描述" },
      { "<leader>LC", "<cmd>Leet console<CR>", desc = "打开控制台" },
    },
  },
}
