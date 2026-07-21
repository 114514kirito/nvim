-- ============================================================
-- Go 后端开发配置
-- 基础：LazyVim extras/lang/go（gopls/delve/gofumpt/goimports/neotest/golangci-lint）
-- 增强：
--   参考 chaozwn/astronvim_user 的优秀实践：
--   - cmp-go-pkgs: import 路径补全
--   - nvim-dap-virtual-text: 调试时行内变量值
--   - persistent-breakpoints: 断点跨会话保存
--   - Test Watch 模式: 文件变化自动重跑测试
--   - preview_stack_trace: panic 堆栈跳转源码
--   - conform lsp_format="last": gopls 收尾格式化
--   加 gopher.nvim 代码生成 / 更多 gopls 分析器 / DAP launch 配置 / 键位
-- 所有设置仅 Go 文件类型生效，不影响 C/C++、Python 等
-- ============================================================
if vim.g.vscode then return {} end

return {
  -- ═══════════════════════════════════════════════════════════
  -- Mason 工具补装
  -- ═══════════════════════════════════════════════════════════
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = { ensure_installed = { "gopls" } },
  },
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "gomodifytags",
        "impl",
        "gotests",
        "iferr",
        "delve",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════
  -- gopls 增强（叠加 LazyVim 默认值）
  --   参考 chaozwn: diagnosticsDelay / undeclaredname / unusedwrite
  -- ═══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          single_file_support = true,
          settings = {
            gopls = {
              analyses = {
                shadow = true,
                unreachable = true,
                fillreturns = true,
                nonewvars = true,
                deepequalerrors = true,
                simappends = true,
                unusedvariable = true,
                unusedwrite = true,
                undeclaredname = true,
                useany = true,
                fieldalignment = false,
              },
              completeUnimported = true,
              completionDocumentation = true,
              deepCompletion = true,
              matcher = "Fuzzy",
              symbolMatcher = "fuzzy",
              hoverKind = "FullDocumentation",
              usePlaceholders = false,
              diagnosticsDelay = "500ms",
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════
  -- conform — goimports + gopls 收尾（参考 chaozwn: lsp_format="last"）
  -- ═══════════════════════════════════════════════════════════
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = { "goimports", lsp_format = "last" },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════
  -- (已移除 cmp-go-pkgs — 依赖 nvim-cmp，与 blink.cmp 不兼容。
  --  gopls 自身已提供 import 路径补全，无需额外插件。)

  -- ═══════════════════════════════════════════════════════════
  -- gopher.nvim — 代码生成（struct tag / 接口实现 / if err / 测试桩）
  -- ═══════════════════════════════════════════════════════════
  {
    "olexsmir/gopher.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "go",
    build = function()
      vim.cmd("GoInstallDeps")
    end,
    config = function()
      require("gopher").setup({
        commands = {
          go = "go",
          gomodifytags = "gomodifytags",
          gotests = "gotests",
          impl = "impl",
          dlv = "dlv",
        },
      })
    end,
    keys = {
      { "<leader>gj", "<cmd>GoAddTag json<CR>", ft = "go", desc = "Add json tag" },
      { "<leader>gb", "<cmd>GoAddTag bson<CR>", ft = "go", desc = "Add bson tag" },
      { "<leader>gy", "<cmd>GoAddTag yaml<CR>", ft = "go", desc = "Add yaml tag" },
      { "<leader>gr", "<cmd>GoRemoveTag<CR>",   ft = "go", desc = "Remove struct tags" },
      { "<leader>gi", "<cmd>GoImpl<CR>",        ft = "go", desc = "Generate interface impl" },
      { "<leader>ge", "<cmd>GoIfErr<CR>",       ft = "go", desc = "if err != nil snippet" },
      { "<leader>gt", "<cmd>GoGenTest<CR>",     ft = "go", desc = "Generate tests" },
    },
  },

  -- ═══════════════════════════════════════════════════════════
  -- DAP 增强：nvim-dap-virtual-text + persistent-breakpoints
  --   参考: chaozwn/astronvim_user dap.lua
  -- ═══════════════════════════════════════════════════════════
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VeryLazy",
    opts = {
      commented = true,
      enabled = true,
      enabled_commands = true,
      only_first_definition = true,
      clear_on_continue = true,
      highlight_changed_variables = true,
      all_frames = false,
      virt_lines = true,
      show_stop_reason = true,
    },
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "VeryLazy",
    opts = {
      load_breakpoints_event = { "BufReadPost" },
    },
  },
  -- Go DAP: adapter 由 nvim-dap-go 自动注册，这里追加 launch 配置
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      -- persistent breakpoints: 用 <leader>db 替代 F9（跨语言统一）
      local group = vim.api.nvim_create_augroup("go_dap_enhance", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "DapSetup",
        callback = function()
          local ok, dap = pcall(require, "dap")
          if not ok or not dap.adapters.go then return end

          dap.configurations.go = dap.configurations.go or {}
          local existing = {}
          for _, c in ipairs(dap.configurations.go) do
            existing[c.name] = true
          end

          local cfgs = {
            {
              type = "go", name = "Go: Debug Package",
              request = "launch", program = "${fileDirname}",
            },
            {
              type = "go", name = "Go: Debug File",
              request = "launch", program = "${file}",
            },
            {
              type = "go", name = "Go: Debug Test (package)",
              request = "launch", mode = "test", program = "${fileDirname}",
            },
            {
              type = "go", name = "Go: Debug Test (function)",
              request = "launch", mode = "test", program = "${fileDirname}",
              args = { "-test.run", "TestFunc" },
            },
          }

          for _, c in ipairs(cfgs) do
            if not existing[c.name] then
              table.insert(dap.configurations.go, c)
            end
          end
        end,
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════
  -- panic stack trace 跳转 — gd 在终端/REPL 中解析文件:行号并跳转
  --   参考: chaozwn/astronvim_user pack-go.lua preview_stack_trace
  -- ═══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    init = function()
      local go_term_group = vim.api.nvim_create_augroup("go_term_stacktrace", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = go_term_group,
        pattern = { "dap-repl", "toggleterm" },
        callback = function(args)
          vim.keymap.set("n", "gd", function()
            local line = vim.api.nvim_get_current_line()
            -- go test panic:  /path/to/file.go:123
            -- go runtime:     file.go:123
            local patterns = {
              "([^%s]+%.go):(%d+)",
              "([%w_/%.%-]+%.go):(%d+)",
            }
            for _, pat in ipairs(patterns) do
              local filepath, line_nr = line:match(pat)
              if filepath and line_nr then
                vim.cmd("e " .. filepath)
                vim.api.nvim_win_set_cursor(0, { tonumber(line_nr), 0 })
                return
              end
            end
            vim.notify("No file:line pattern found on this line", vim.log.levels.INFO)
          end, { buffer = args.buf, desc = "Jump to source (stack trace)" })
        end,
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════
  -- neotest 增强 — 添加 Test Watch + 跳转失败测试
  --   参考: chaozwn/astronvim_user neotest.lua
  -- ═══════════════════════════════════════════════════════════
  {
    "nvim-neotest/neotest",
    optional = true,
    keys = {
      -- 测试运行
      { "<leader>tg", group = "go test", icon = "" },
      { "<leader>tgr", function()
          require("neotest").run.run()
        end, ft = "go", desc = "Run nearest" },
      { "<leader>tgf", function()
          require("neotest").run.run(vim.fn.expand("%"))
        end, ft = "go", desc = "Run file" },
      { "<leader>tgp", function()
          require("neotest").run.run({ suite = true })
        end, ft = "go", desc = "Run suite" },
      { "<leader>tgs", function()
          require("neotest").summary.toggle()
        end, ft = "go", desc = "Toggle summary" },
      { "<leader>tgd", function()
          require("neotest").run.run({ strategy = "dap" })
        end, ft = "go", desc = "Debug test" },
      { "<leader>tgo", function()
          require("neotest").output.open()
        end, ft = "go", desc = "Output hover" },
      { "<leader>tgO", function()
          require("neotest").output_panel.toggle()
        end, ft = "go", desc = "Output panel" },
      -- Test Watch（文件变化自动重跑）
      { "<leader>tgw", group = "watch", icon = "" },
      { "<leader>tgwt", function()
          require("neotest").watch.toggle()
        end, ft = "go", desc = "Toggle watch test" },
      { "<leader>tgwf", function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end, ft = "go", desc = "Watch file" },
      { "<leader>tgws", function()
          require("neotest").watch.stop()
        end, ft = "go", desc = "Stop all watches" },
    },
  },

  -- ═══════════════════════════════════════════════════════════
  -- Go 文件类型设置：tab 缩进（Go 官方标准）
  -- ═══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    init = function()
      local go_group = vim.api.nvim_create_augroup("go_file_ft", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = go_group,
        pattern = { "go", "gomod", "gowork", "gotmpl" },
        callback = function()
          vim.bo.expandtab = false
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
        end,
      })
    end,
  },
}
