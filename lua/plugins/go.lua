-- ============================================================
-- Go 后端开发配置
-- 基于 LazyVim extras/lang/go，仅做增量增强
-- 所有设置仅影响 Go 文件，不污染 C/C++/Python
-- ============================================================
if vim.g.vscode then return {} end

return {
  -- ============================================================
  -- 1. gopls 自动启动 + 完整配置
  --    必须在 init 中设置 autocmd，因为 lazy.nvim 的 event 触发
  --    时机太晚。autocmd 直接注册，不依赖 lazy 加载顺序。
  -- ============================================================
  {
    "neovim/nvim-lspconfig",
    lazy = false, -- 确保 init 在启动时执行
    init = function()
      local group = vim.api.nvim_create_augroup("GoSetup", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "go", "gomod", "gowork", "gotmpl" },
        callback = function(args)
          local buf = args.buf

          -- Tab 缩进
          vim.bo[buf].expandtab = false
          vim.bo[buf].tabstop = 4
          vim.bo[buf].shiftwidth = 4

          -- 启动 gopls（如果未启动）
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(buf) then return end
            local clients = vim.lsp.get_clients({ bufnr = buf, name = "gopls" })
            if #clients > 0 then return end

            local fname = vim.api.nvim_buf_get_name(buf)
            local root = vim.fs.dirname(fname)
            local go_mod = vim.fs.find("go.mod", { upward = true, path = root })[1]
            if go_mod then root = vim.fs.dirname(go_mod) end

            vim.lsp.start({
              name = "gopls",
              cmd = { "gopls" },
              root_dir = root,
              single_file_support = true,
              settings = {
                gopls = {
                  gofumpt = true,
                  staticcheck = true,
                  completeUnimported = true,
                  deepCompletion = true,
                  matcher = "Fuzzy",
                  symbolMatcher = "fuzzy",
                  hoverKind = "FullDocumentation",
                  usePlaceholders = false,
                  analyses = {
                    shadow = true,
                    unreachable = true,
                    fillreturns = true,
                    nonewvars = true,
                    deepequalerrors = true,
                    simappends = true,
                    unusedvariable = true,
                    undeclaredname = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                    nilness = true,
                  },
                  codelenses = {
                    generate = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                    run_govulncheck = true,
                  },
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
            })
          end)
        end,
      })
    end,
  },

  -- ============================================================
  -- 2. conform — goimports + gopls 收尾
  -- ============================================================
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = { "goimports", lsp_format = "last" },
      },
    },
  },

  -- ============================================================
  -- 3. gopher.nvim — 代码生成
  -- ============================================================
  {
    "olexsmir/gopher.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    ft = "go",
    build = function() vim.cmd("GoInstallDeps") end,
    config = function()
      require("gopher").setup({
        commands = {
          go = "go", gomodifytags = "gomodifytags", gotests = "gotests",
          impl = "impl", dlv = "dlv",
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

  -- ============================================================
  -- 4. DAP 增强
  -- ============================================================
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VeryLazy",
    opts = {
      enabled = true, enabled_commands = true, commented = true,
      only_first_definition = true, clear_on_continue = true,
      highlight_changed_variables = true, virt_lines = true,
      show_stop_reason = true,
    },
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "VeryLazy",
    opts = { load_breakpoints_event = { "BufReadPost" } },
  },

  -- ============================================================
  -- 5. Mason 工具
  -- ============================================================
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = { ensure_installed = { "gomodifytags", "impl", "gotests", "iferr", "delve" } },
  },
}
