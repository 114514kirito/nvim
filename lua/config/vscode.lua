-- ============================================================
-- VSCode 模式检测工具
-- 在 VSCode 中运行时 vim.g.vscode == 1
-- 本模块提供统一的判断函数，供各插件文件使用
-- ============================================================

-- 判断是否在 VSCode 中运行
function _G.is_vscode()
  return vim.g.vscode == 1
end

-- 如果是在 VSCode 中，禁用 LazyVim 自带的 UI 相关自动命令
-- 这些在 VSCode 中完全不需要
if _G.is_vscode() then
  -- 禁用 LazyVim 的自动括号/引号配对（VSCode 已处理）
  vim.g.lazyvim_autopairs = false

  -- 禁用 LazyVim 的 UI 相关功能
  vim.g.lazyvim_ui_disable = true

  -- 关闭原生行号样式，让 VSCode 接管
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.signcolumn = "no"
  vim.opt.cursorline = false
end
