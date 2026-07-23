-- ============================================
-- leetcode.nvim: 终端刷题
-- 依赖 nui.nvim + plenary.nvim（已安装）
-- 使用 snacks.nvim 作为 picker（LazyVim 预装）
-- 使用 tree-sitter-html 解析题目（LazyVim 预装）
--
-- 两种启动方式：
--   独立模式:   终端执行 nvim leetcode.nvim（纯净刷题区）
--   非独立模式: 在已有 nvim 中 <leader>to 或 :Leet
-- ============================================
if vim.g.vscode then return {} end

local leet_arg = "leetcode.nvim"

--- 扩展翻译表（专业名词保留英文，括号内为中文说明）
--- 在插件加载后通过 debug.setupvalue 热注入，不修改任何第三方文件
local function extend_translator()
  local ok, translator = pcall(require, "leetcode.translator")
  if not ok then return end

  -- 找到 translator 模块里含翻译表的 upvalue
  local i = 1
  while true do
    local name, value = debug.getupvalue(translator, i)
    if not name then break end
    if name == "_ENV" then
      -- 扫描 _ENV 里的 translate 表
      local j = 1
      while true do
        local env_name, env_val = debug.getupvalue(value, j)
        if not env_name then break end
        if type(env_val) == "table" and env_val["problems"] == "题库" then
          -- 找到了！合并翻译
          env_val["delete / sign out"] = "删除 / 退出登录 (Delete / Sign out)"
          env_val["sign in (by cookie)"] = "Cookie 登录 (Sign in by Cookie)"
          env_val["enter cookie"] = "输入 Cookie (Enter Cookie)"
          env_val["sign-in successful"] = "登录成功 (Sign-in Successful)"
          env_val["sign-in failed"] = "登录失败 (Sign-in Failed)"
          env_val["signed in as"] = "已登录 (Signed in as)"
          env_val["of"] = "/ (of)"
          env_val["runtime"] = "Runtime (运行时间)"
          env_val["runtime error"] = "Runtime Error (运行错误)"
          env_val["memory"] = "Memory (内存)"
          env_val["testcases"] = "Test Cases (测试用例)"
          env_val["testcases passed"] = " 个 test cases 通过"
          env_val["last executed input"] = "最后执行 input (Last Executed Input)"
          env_val["input"] = "Input (输入)"
          env_val["output"] = "Output (输出)"
          env_val["expected"] = "Expected (预期输出)"
          env_val["stdout"] = "Stdout (标准输出)"
          env_val["question is for premium users only"] = "Premium 专属题目"
          env_val["premium"] = "Premium (会员)"
          env_val["you have attempted to run code too soon"] = "提交太频繁，请稍候重试"
          env_val["similar questions"] = "相似题目 (Similar Questions)"
          env_val["no similar questions available"] = "无相似题目"
          env_val["no topics available"] = "无相关标签"
          env_val["no hints available"] = "无提示"
          env_val["drawn question is for premium users only. please try again"] = "Premium 专属题目，请重试"
          env_val["please verify your email address in order to use your account"] = "请先验证邮箱"
          env_val["use testcase"] = "添加到 Test Cases (Use Testcase)"
          env_val["available languages"] = "可用语言 (Available Languages)"
          env_val["languages"] = "语言 (Languages)"
          env_val["language already set to"] = "语言已设为 (Language Set)"
          env_val["skills"] = "技能 (Skills)"
          env_val["reset"] = "重置 (Reset)"
          env_val["question info"] = "题目信息 (Question Info)"
          env_val["select a question"] = "选择题目 (Select)"
          env_val["no questions opened"] = "无已打开题目"
          env_val["no current question found"] = "未找到当前题目"
          env_val["you're now signed out"] = "已退出登录"
          env_val["submissions"] = "过去一年提交 (Submissions)"
          env_val["active days"] = "累计提交天数 (Active Days)"
          env_val["max streak"] = "最长连续 (Max Streak)"
          env_val["more challenges"] = "更多挑战 (More Challenges)"
          env_val["session"] = "进度 (Session)"
          env_val["invalid"] = "无效 (Invalid)"

          -- 难度 — 专业名词保留英文
          env_val["all"] = "All (所有)"
          env_val["easy"] = "Easy (简单)"
          env_val["medium"] = "Medium (中等)"
          env_val["hard"] = "Hard (困难)"

          -- 判题状态
          env_val["accepted"] = "Accepted (通过)"
          env_val["wrong answer"] = "Wrong Answer (解答错误)"
          env_val["compile error"] = "Compile Error (编译出错)"
          env_val["time limit exceeded"] = "TLE (超时)"
          env_val["output limit exceeded"] = "OLE (超输出限制)"
          env_val["memory limit exceeded"] = "MLE (超内存)"
          env_val["invalid testcase"] = "Invalid Testcase (无效用例)"

          -- 判题进度
          env_val["pending…"] = "Pending… (排队中)"
          env_val["judging…"] = "Judging… (判题中)"
          env_val["finished"] = "Finished (完成)"
          env_val["failed"] = "Failed (失败)"
          break
        end
        j = j + 1
      end
      break
    end
    i = i + 1
  end
end

--- 无需修改插件源码即可汉化菜单按钮
--- MenuButton:init() 会调用 t(text) 翻译按钮文字
local function add_menu_button_translations()
  local ok, translator = pcall(require, "leetcode.translator")
  if not ok then return end

  local i = 1
  while true do
    local name, value = debug.getupvalue(translator, i)
    if not name then break end
    if name == "_ENV" then
      local j = 1
      while true do
        local env_name, env_val = debug.getupvalue(value, j)
        if not env_name then break end
        if type(env_val) == "table" and env_val["problems"] == "题库" then
          env_val["problems"] = "题库 (Problems)"
          env_val["statistics"] = "统计 (Statistics)"
          env_val["cache"] = "缓存 (Cache)"
          env_val["exit"] = "退出 (Exit)"
          env_val["back"] = "后退 (Back)"
          env_val["menu"] = "菜单 (Menu)"
          env_val["loading..."] = "加载中... (Loading)"
          env_val["update"] = "更新 (Update)"
          env_val["list"] = "列表 (List)"
          env_val["random"] = "随机 (Random)"
          env_val["daily"] = "每日 (Daily)"
          env_val["sign in"] = "登录 (Sign In)"
          env_val["run"] = "运行 (Run)"
          env_val["submit"] = "提交 (Submit)"
          env_val["result"] = "执行结果 (Result)"
          env_val["topics"] = "相关标签 (Topics)"
          env_val["hints"] = "提示 (Hints)"
          env_val["beats"] = "击败 (Beats)"
          break
        end
        j = j + 1
      end
      break
    end
    i = i + 1
  end
end

return {
  {
    "kawre/leetcode.nvim",
    lazy = leet_arg ~= vim.fn.argv(0, -1),
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },

    --- 插件加载后热注入翻译，不修改第三方源码
    config = function(plugin, opts)
      require("leetcode").setup(opts)
      extend_translator()
      add_menu_button_translations()
    end,

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
