-- ============================================
-- leetcode.nvim: 终端刷题 · 纯 C++
-- 快捷键：<leader>t 前缀，无冲突
-- ============================================
if vim.g.vscode then return {} end

local leet_arg = "leetcode.nvim"

--- 热注入翻译表（不改动插件源码）
--- 格式：English (中文) — 专业名词保留英文
local function inject_translations()
  local ok, mod = pcall(require, "leetcode.translator")
  if not ok then return end
  local i = 1
  while true do
    local name, val = debug.getupvalue(mod, i)
    if not name then break end
    if name == "_ENV" then
      local j = 1
      while true do
        local _, env = debug.getupvalue(val, j)
        if not env then break end
        if type(env) == "table" and env["problems"] == "题库" then
          -- 菜单
          env["problems"] = "题库 (Problems)"
          env["statistics"] = "统计 (Statistics)"
          env["cache"] = "缓存 (Cache)"
          env["exit"] = "退出 (Exit)"
          env["back"] = "后退 (Back)"
          env["menu"] = "菜单 (Menu)"
          env["loading..."] = "加载中... (Loading)"
          env["update"] = "更新 (Update)"
          env["list"] = "列表 (List)"
          env["random"] = "随机 (Random)"
          env["daily"] = "每日 (Daily)"
          env["sign in"] = "登录 (Sign In)"
          env["sign in (by cookie)"] = "Cookie 登录"
          env["signed in as"] = "已登录 (Signed in as)"
          env["delete / sign out"] = "删除 / 退出登录"
          env["sign-in successful"] = "登录成功"
          env["sign-in failed"] = "登录失败"
          env["enter cookie"] = "输入 Cookie"
          env["you're now signed out"] = "已退出登录"
          env["run"] = "运行 (Run)"
          env["submit"] = "提交 (Submit)"
          env["result"] = "执行结果 (Result)"
          env["topics"] = "相关标签 (Topics)"
          env["hints"] = "提示 (Hints)"
          env["beats"] = "击败 (Beats)"
          env["session"] = "进度 (Session)"

          -- 题目描述
          env["premium"] = "Premium (会员)"
          env["similar questions"] = "相似题目 (Similar Questions)"
          env["no similar questions available"] = "无相似题目"
          env["no topics available"] = "无相关标签"
          env["no hints available"] = "无提示"
          env["question is for premium users only"] = "Premium 专属题目"
          env["drawn question is for premium users only. please try again"] = "Premium 专属题目，请重试"
          env["please verify your email address in order to use your account"] = "请先验证邮箱"
          env["question info"] = "题目信息"
          env["select a question"] = "选择题目"
          env["no questions opened"] = "无已打开题目"
          env["no current question found"] = "未找到当前题目"

          -- 数据 — 专业名词保留
          env["runtime"] = "Runtime (运行时间)"
          env["runtime error"] = "Runtime Error"
          env["memory"] = "Memory (内存)"
          env["testcases"] = "Test Cases (测试用例)"
          env["testcases passed"] = " 个 test cases 通过"
          env["input"] = "Input (输入)"
          env["output"] = "Output (输出)"
          env["expected"] = "Expected (预期)"
          env["stdout"] = "Stdout (标准输出)"
          env["beats"] = "击败 (Beats)"
          env["of"] = " / "
          env["submissions"] = "过去一年提交 (Submissions)"
          env["active days"] = "累计提交天数 (Active Days)"
          env["max streak"] = "最长连续 (Max Streak)"

          -- 难度
          env["all"] = "All (所有)"
          env["easy"] = "Easy (简单)"
          env["medium"] = "Medium (中等)"
          env["hard"] = "Hard (困难)"

          -- 判题状态
          env["accepted"] = "Accepted (通过)"
          env["wrong answer"] = "Wrong Answer (错误)"
          env["compile error"] = "Compile Error (编译错误)"
          env["time limit exceeded"] = "TLE (超时)"
          env["output limit exceeded"] = "OLE (超过输出)"
          env["memory limit exceeded"] = "MLE (超过内存)"
          env["invalid testcase"] = "Invalid Testcase"

          -- 判题进度
          env["pending…"] = "Pending… (排队中)"
          env["judging…"] = "Judging… (判题中)"
          env["finished"] = "Finished (完成)"
          env["failed"] = "Failed (失败)"

          env["skills"] = "技能 (Skills)"
          env["languages"] = "语言 (Languages)"
          env["available languages"] = "可用语言"
          env["language already set to"] = "语言已设为"
          env["use testcase"] = "添加到 Test Cases"
          env["last executed input"] = "最后执行 input"
          env["reset"] = "重置"
          env["invalid"] = "无效"
          env["more challenges"] = "更多挑战"
          env["you have attempted to run code too soon"] = "提交太频繁，请稍候"
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
    -- 独立模式: nvim leetcode.nvim → 立即加载
    -- 非独立模式: :Leet 或 <leader>t 懒加载
    lazy = leet_arg ~= vim.fn.argv(0, -1),
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",            -- 终端图片渲染 (KGP)
      "folke/snacks.nvim",         -- snacks.image fallback
    },

    config = function(_, opts)
      -- 初始化 3rd/image.nvim（leetcode.nvim 用这个渲染题目图片）
      -- backend=kitty 通过 KGP 协议在 Kitty/Ghostty 终端显示图片
      pcall(function()
        require("image").setup({
          backend = "kitty",
          processor = "magick_cli",             -- magick_rock 与 IM6 兼容性差, 用 CLI
          integrations = {
            markdown = { enabled = true },
            html = { enabled = true },
          },
          max_height_window_percentage = 50,
        })
      end)
      -- 同时也启动 snacks.image 作为 fallback
      pcall(function()
        require("snacks").image.setup({})
      end)
      require("leetcode").setup(opts)
      inject_translations()
    end,

    opts = {
      arg = "leetcode.nvim",
      lang = "cpp", -- 纯 C++，不用 Go

      cn = {
        enabled = true,
        translator = true,
        translate_problems = true,
      },

      editor = {
        fold_imports = true,
        reset_previous_code = true,
      },

      description = {
        position = "left",
        width = "42%",
        show_stats = true,
      },

      console = {
        open_on_runcode = true,
        dir = "row",
        size = { width = "90%", height = "75%" },
        result = { size = "60%" },
        testcase = { size = "40%" },
      },

      image_support = true,           -- 终端内渲染题目图片 (KGP)

      plugins = { non_standalone = true },
      cache = { update_interval = 60 * 60 * 24 * 7 },

      -- 只保留 C++ 万能头注入
      injector = {
        ["cpp"] = {
          imports = function()
            return { "#include <bits/stdc++.h>", "using namespace std;" }
          end,
        },
      },

      -- 插件内部快捷键 — 不动你的 Shift+H/L
      keys = {
        toggle = { "q", "<Esc>" },
        confirm = { "<CR>" },
        reset_testcases = "r",
        use_testcase = "U",
        focus_testcases = "<C-h>",  -- Ctrl+h 切到用例面板（不抢 H）
        focus_result = "<C-l>",     -- Ctrl+l 切到结果面板（不抢 L）
      },

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

      hooks = {
        -- 进入 LeetCode 面板时
        ["enter"] = {
          function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
          end,
        },

        -- 打开题目时：修复空格问题 + 美化描述窗口
        ["question_enter"] = {
          function(q)
            -- 修复 1：题目 buffer 打开后强制回到 normal 模式，
            -- 否则 <Space> 无法作为 leader 使用
            vim.schedule(function()
              local current_win = vim.api.nvim_get_current_win()
              -- 如果焦点在题目 buffer 的窗口
              if q.winid and vim.api.nvim_win_is_valid(q.winid) then
                vim.api.nvim_set_current_win(q.winid)
                if vim.api.nvim_get_mode().mode == "i" then
                  vim.cmd("stopinsert")
                end
                vim.api.nvim_set_current_win(current_win)
              end
            end)

            -- 修复 2：每道题的 tab page 独立关闭，不会嵌套
            --     退出时只关当前题目的 tab，默认行为已正确
            --     $tabe 在 create_buffer() 中创建，
            --     WinClosed → _unmount → tabpage 自然退出

            -- 描述面板窗口优化
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

    -- 全局快捷键：<leader>t
    keys = {
      { "<leader>to", "<cmd>Leet<CR>",                     desc = "LeetCode (Open)" },
      { "<leader>td", "<cmd>Leet daily<CR>",                desc = "每日一题 (Daily)" },
      { "<leader>tr", "<cmd>Leet random<CR>",               desc = "随机一题 (Random)" },
      { "<leader>ts", "<cmd>Leet list<CR>",                 desc = "搜索题目 (Search)" },
      { "<leader>th", group = "分类刷题" },
      { "<leader>the", "<cmd>Leet list difficulty=easy<CR>",    desc = "简单 (Easy)" },
      { "<leader>thm", "<cmd>Leet list difficulty=medium<CR>",  desc = "中等 (Medium)" },
      { "<leader>thh", "<cmd>Leet list difficulty=hard<CR>",    desc = "困难 (Hard)" },
      { "<leader>tha", "<cmd>Leet list status=notac<CR>",       desc = "已尝试未通过" },
      { "<leader>thc", "<cmd>Leet list status=ac<CR>",          desc = "已完成" },
      { "<leader>tht", "<cmd>Leet list status=todo<CR>",        desc = "待做" },
      { "<leader>tt", "<cmd>Leet run<CR>",                  desc = "运行测试 (Test)" },
      { "<leader>tS", "<cmd>Leet submit<CR>",               desc = "提交代码 (Submit)" },
      { "<leader>tT", "<cmd>Leet tabs<CR>",                 desc = "切换标签 (Tabs)" },
      { "<leader>tg", "<cmd>Leet lang<CR>",                 desc = "切换语言 (lanG)" },
      { "<leader>tD", "<cmd>Leet desc toggle<CR>",          desc = "切换描述 (Desc)" },
      { "<leader>tC", "<cmd>Leet console<CR>",              desc = "控制台 (Console)" },
    },
  },
}
