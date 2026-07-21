-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Go: gopls 自动启动（必须在 lazy.setup 之后注册 autocmd）
-- LazyVim extras/lang/go 有时会因加载时序不起作用，这是保险措施
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("GoAutoStart", { clear = true }),
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function(args)
    local buf = args.buf
    -- Tab 缩进
    vim.bo[buf].expandtab = false
    vim.bo[buf].tabstop = 4
    vim.bo[buf].shiftwidth = 4
    -- 启动 gopls
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      if #vim.lsp.get_clients({ bufnr = buf, name = "gopls" }) > 0 then return end
      local root = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
      local go_mod = vim.fs.find("go.mod", { upward = true, path = root })[1]
      if go_mod then root = vim.fs.dirname(go_mod) end
      vim.lsp.start({
        name = "gopls",
        cmd = { "gopls" },
        root_dir = root,
        single_file_support = true,
      })
    end)
  end,
})
