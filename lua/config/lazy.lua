local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Python LSP: use basedpyright (modern fork with better type checking)
vim.g.lazyvim_python_lsp = "basedpyright"

-- VSCode 模式检测
require("config.vscode")

require("lazy").setup({
  spec = {
    -- LazyVim 核心
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- 用户自定义插件
    { import = "plugins" },

    -- 语言 / UI Extras（仅在终端模式下加载）
    { import = "lazyvim.plugins.extras.lang.clangd",        enabled = not vim.g.vscode },
    { import = "lazyvim.plugins.extras.lang.cmake",         enabled = not vim.g.vscode },
    { import = "lazyvim.plugins.extras.lang.go",            enabled = not vim.g.vscode },
    { import = "lazyvim.plugins.extras.lang.python",        enabled = not vim.g.vscode },
    { import = "lazyvim.plugins.extras.lang.json",          enabled = not vim.g.vscode },
    { import = "lazyvim.plugins.extras.ui.smear-cursor",    enabled = not vim.g.vscode },
    { import = "lazyvim.plugins.extras.ui.mini-indentscope", enabled = not vim.g.vscode },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
