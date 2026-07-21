-- ============================================================
-- Go 后端开发配置
-- 基础：LazyVim extras/lang/go（gopls/delve/gofumpt/goimports/neotest/golangci-lint）
-- 增强：gopher.nvim 代码生成 / 更多 gopls 分析器 / DAP launch 配置 / 键位
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
        "delve",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════
  -- gopls 增强（叠加 LazyVim 默认值）
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
                fieldalignment = false,
              },
              completeUnimported = true,
              completionDocumentation = true,
              deepCompletion = true,
              matcher = "Fuzzy",
              hoverKind = "FullDocumentation",
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
  -- DAP — Go 调试 launch 配置（adapter 由 nvim-dap-go 自动注册）
  -- ═══════════════════════════════════════════════════════════
  {
    "mfussenegger/nvim-dap",
    optional = true,
    -- 用 init 追加，不用 config 覆盖（dap.lua 已有 C/C++ 配置）
    init = function()
      local group = vim.api.nvim_create_augroup("go_dap_setup", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "DapSetup",
        callback = function()
          local ok, dap = pcall(require, "dap")
          if not ok then return end
          if not dap.adapters.go then return end

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
  -- neotest-golang 键位 (which-key: <leader>tg)
  -- ═══════════════════════════════════════════════════════════
  {
    "nvim-neotest/neotest",
    optional = true,
    keys = {
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
