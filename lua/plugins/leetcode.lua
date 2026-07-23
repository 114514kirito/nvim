-- ============================================
-- leetcode.nvim: 终端刷题
-- 依赖 nui.nvim + plenary.nvim（已安装）
-- 使用 snacks.nvim 作为 picker（LazyVim 预装）
-- 使用 tree-sitter-html 解析题目（LazyVim 预装）
--
-- 两种启动方式：
--   独立模式:   终端执行 nvim leetcode.nvim（纯净刷题区）
--   非独立模式: 在已有 nvim 中 <leader>lc 或 :Leet
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
        width = "42%",
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
      --
      -- ⚠️ 注意：injector 中 imports 支持 function 形式，
      --    但 before / after 只能用纯 string 或 string[]，
      --    源码 Question:inject() 不会调用 function！
      --    注入部分在 LeetCode 提交时自动忽略。
      -- ============================================================
      injector = {
        -- C++：万能头 + std 命名空间（通过 imports）
        ["cpp"] = {
          imports = function()
            return {
              "#include <bits/stdc++.h>",
              "using namespace std;",
            }
          end,
        },

        -- Go：补齐 package main + 常用 import 块
        --     before 被注入到 // @leet start 之前，gopls 不再报错
        ["golang"] = {
          before = {
            "package main",
            "",
            "import (",
            '\t"container/heap"',
            '\t"container/list"',
            '\t"math"',
            '\t"math/bits"',
            '\t"sort"',
            '\t"strconv"',
            '\t"strings"',
            ")",
          },
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
      -- ============================================================
      theme = {
        easy = { fg = "#4fd6be", bold = true },
        medium = { fg = "#ffc777", bold = true },
        hard = { fg = "#ff757f", bold = true },
        code = { italic = true },
        header = { bold = true },
        followup = { bold = true },
        link = { underline = true },
        example = { italic = true },
        constraints = {},
        normal = {},
        alt = {},
      },

      -- ============================================================
      -- 钩子：进入/打开题目时自动执行
      -- ============================================================
      hooks = {
        ["enter"] = {
          function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
          end,
        },

        ["question_enter"] = {
          function(q)
            local desc_win = q.description and q.description.winid
            if desc_win and vim.api.nvim_win_is_valid(desc_win) then
              vim.wo[desc_win].foldcolumn = "0"
              vim.wo[desc_win].colorcolumn = ""
              vim.wo[desc_win].cursorline = false
              vim.wo[desc_win].cursorcolumn = false
              vim.wo[desc_win].smoothscroll = true
            end
          end,
        },
      },
    },

    -- ============================================================
    -- 全局快捷键（<leader>t 前缀，t = 刷题）
    -- <leader>t 没有任何冲突，完全空闲
    -- ============================================================
    keys = {
      { "<leader>to", "<cmd>Leet<CR>",              desc = "LeetCode 面板 (Open)" },
      { "<leader>td", "<cmd>Leet daily<CR>",         desc = "每日一题 (Daily)" },
      { "<leader>tr", "<cmd>Leet random<CR>",        desc = "随机一题 (Random)" },
      { "<leader>ts", "<cmd>Leet list<CR>",          desc = "搜索题目 (Search)" },
      { "<leader>tt", "<cmd>Leet run<CR>",           desc = "运行测试 (Test)" },
      { "<leader>tS", "<cmd>Leet submit<CR>",        desc = "提交代码 (Submit)" },
      { "<leader>tT", "<cmd>Leet tabs<CR>",          desc = "切换标签 (Tabs)" },
      { "<leader>tg", "<cmd>Leet lang<CR>",          desc = "切换语言 (lanG)" },
      { "<leader>tD", "<cmd>Leet desc toggle<CR>",   desc = "切换题目描述 (Desc)" },
      { "<leader>tC", "<cmd>Leet console<CR>",       desc = "打开控制台 (Console)" },
    },
  },
}
