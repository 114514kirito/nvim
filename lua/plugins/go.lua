-- ============================================================
-- Go 后端开发配置
-- 基础架构由 LazyVim extras/lang/go 提供
-- 本文件仅做增强，所有设置仅影响 Go 文件
-- 参考: chaozwn/astronvim_user (AstroNvim v5 Go config)
-- ============================================================
if vim.g.vscode then return {} end

return {
  -- ═══════════════════════════════════════════════════════════
  -- 1. gopls — 在 LazyVim 基础上追加分析器 + 补全微调
  --    LazyVim 已设: gofumpt/staticcheck/codelenses/hints/nilness/unusedparams/unusedwrite/useany
  --    这里追加: shadow/unreachable/fillreturns/nonewvars/deepequalerrors/simappends/unusedvariable/undeclaredname
  -- ═══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          single_file_support = true,
          -- 关键: 保持 init_options，否则 LazyVim semanticTokens 会被覆盖
          init_options = {
            semanticTokens = true,
          },
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
                undeclaredname = true,
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
          -- 必须保留 LazyVim 的 semanticTokens workaround
          setup = function(_, _)
            -- 由 LazyVim 的 setup 处理
          end,
        },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════
  -- 2. conform — goimports + gopls 收尾
  --    参考 chaozwn: lsp_format="last" 确保 goimports 分组后 gopls 最终格式化
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
  -- 3. gopher.nvim — 代码生成
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
  -- 4. DAP 增强：行内变量值 + 持久断点
  --    (adapter + launch configs 由 LazyVim Go extra + dap-go 处理)
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
  -- 5. panic stack trace → 源码跳转
  --    在终端/REPL 中看到 /path/to/file.go:123 时按 <leader>gj 跳转
  --    (不用 gd 是为了不覆盖 LSP 的 gd 跳转定义)
  -- ═══════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    init = function()
      local group = vim.api.nvim_create_augroup("go_term_jump", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "toggleterm",
        callback = function(args)
          vim.keymap.set("n", "<leader>gj", function()
            local line = vim.api.nvim_get_current_line()
            -- 匹配 go 编译器输出: file.go:123 或 /absolute/path/file.go:123
            local patterns = {
              "([%w_/%.%-]+%.go):(%d+)",     -- 带路径
              "([%w_]+%.go):(%d+)",           -- 仅文件名
            }
            for _, pat in ipairs(patterns) do
              local filepath, lnr = line:match(pat)
              if filepath and lnr then
                if vim.fn.filereadable(filepath) == 1 then
                  vim.cmd("e " .. filepath)
                elseif vim.fn.filereadable(vim.fn.getcwd() .. "/" .. filepath) == 1 then
                  vim.cmd("e " .. vim.fn.getcwd() .. "/" .. filepath)
                else
                  vim.cmd("e " .. filepath) -- 让 vim 报 "new file" 提示
                end
                vim.api.nvim_win_set_cursor(0, { tonumber(lnr), 0 })
                return
              end
            end
            vim.notify("No 'file.go:line' pattern on this line", vim.log.levels.INFO)
          end, { buffer = args.buf, desc = "Go: Jump to source from stack trace" })
        end,
      })
    end,
  },

  -- ═══════════════════════════════════════════════════════════
  -- 6. Mason 补装工具
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
  -- 7. Go 文件缩进：tab（官方标准）
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
