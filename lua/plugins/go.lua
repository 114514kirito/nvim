-- ============================================================
-- Go 后端开发配置
-- 基于 LazyVim extras/lang/go，仅做增量增强
-- 所有设置仅影响 Go 文件，不污染 C/C++/Python
-- ============================================================
if vim.g.vscode then return {} end

return {
  -- ═══════════════════════════════════════════════════════════
  -- 1. gopls — 在 LazyVim 默认之上叠加分析器 + 补全微调
  --    关键: LazyVim 已设 gofumpt/codelenses/hints/nilness/unusedparams/
  --    unusedwrite/useany/staticcheck/completeUnimported/usePlaceholders/
  --    directoryFilters/init_options。这里的 analyses 等字段会
  --    与 LazyVim 深度合并 (vim.tbl_deep_extend)，不会覆盖。
  --    注意: 不要写 setup = function() end，否则会覆盖 LazyVim
  --    的 semanticTokens workaround!
  -- ═══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          single_file_support = true,
          settings = {
            gopls = {
              -- 追加的分析器（与 LazyVim 的合并）
              analyses = {
                shadow = true,
                unreachable = true,
                fillreturns = true,
                nonewvars = true,
                deepequalerrors = true,
                simappends = true,
                unusedvariable = true,
                undeclaredname = true,
              },
              -- 补全增强
              completeUnimported = true,
              completionDocumentation = true,
              deepCompletion = true,
              matcher = "Fuzzy",
              symbolMatcher = "fuzzy",
              hoverKind = "FullDocumentation",
              usePlaceholders = false,
              diagnosticsDelay = "500ms",
              -- Inlay hints
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
  -- 2. conform — goimports + gopls 收尾
  --    保存时: goimports 整理 import → gopls 最终格式化
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
  -- 3. gopher.nvim — struct tag / 接口实现 / if err / 测试桩
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
  -- 4. DAP 增强 — 行内变量值 + 持久断点
  -- ═══════════════════════════════════════════════════════════
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VeryLazy",
    opts = {
      enabled = true,
      enabled_commands = true,
      commented = true,
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

  -- ═══════════════════════════════════════════════════════════
  -- 5. Mason 工具补装
  -- ═══════════════════════════════════════════════════════════
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
  -- 6. Go 文件用 tab 缩进（官方标准）
  -- ═══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    init = function()
      local group = vim.api.nvim_create_augroup("go_ft_settings", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
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
