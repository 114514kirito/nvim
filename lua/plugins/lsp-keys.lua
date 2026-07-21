-- VSCode 模式：LSP 由 VSCode 原生扩展处理
if vim.g.vscode then return {} end

-- ============================================================
-- LSP 配置 — clangd 命令行 + 文档高亮关闭 + K 映射覆写
-- gh/gd 全局映射见 config/keymaps.lua
-- ============================================================

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- 关闭 LSP document_highlight（CursorHold 时自动高亮所有引用）
      document_highlight = { enabled = false },
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=**",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
    },
  },

  -- 覆写 LazyVim 的 buffer-local K（LazyVim 默认 hover 无 border，这里加 border）
  -- 用 LspAttach + vim.schedule 确保在 LazyVim 之后执行
  -- 注意：用 init 而非 config，否则会覆盖 LazyVim 的默认 config 导致所有 LSP 无法启动
  {
    "neovim/nvim-lspconfig",
    init = function()
      local group = vim.api.nvim_create_augroup("user_lsp_overrides", { clear = true })

      -- LSP 格式化（<leader>cf 被编译运行占用，这里用 <leader>cF）
      vim.keymap.set({ "n", "v" }, "<leader>cF", function()
        vim.lsp.buf.format({ async = true })
      end, { desc = "LSP Format" })

      -- nvim 0.12 timing workaround:
      -- vim.lsp.enable() 在当前 buffer 的 FileType 已触发之后才被调用，
      -- 导致首次打开 C 文件时 clangd 不会自动启动。这里延迟补一个启动。
      vim.api.nvim_create_autocmd("BufReadPost", {
        group = group,
        pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc", "*.hh" },
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then return end
            if #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then return end
            local root = vim.fs.root(bufnr, { ".git", "Makefile", "compile_commands.json", ".clangd" })
            if not root then return end
            vim.lsp.start({
              name = "clangd",
              cmd = { "clangd" },
              root_dir = root,
            }, { bufnr = bufnr })
          end)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then return end
            vim.keymap.set("n", "K", function()
              vim.lsp.buf.hover({
                border = "rounded",
                max_width = math.floor(vim.o.columns * 0.5),
                max_height = math.floor(vim.o.lines * 0.4),
              })
            end, { buffer = bufnr, desc = "Enhanced Hover" })
          end)
        end,
      })
    end,
  },
}
