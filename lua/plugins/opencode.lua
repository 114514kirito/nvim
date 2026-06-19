-- opencode.nvim — 完整配置
--
-- 使用方法:
--   1. 先按 <leader>oo 在右侧终端启动 opencode（仅第一次需要）
--   2. 按 <leader>oa 向 opencode 提问
--   3. 右侧终端就是 opencode TUI，<C-w>l 切过去直接对话
--   4. 不想要了按 <leader>oq 关掉

local M = {}

M.buf = nil -- opencode 终端 buffer

function M.open()
  -- 检查是否已有 opencode 终端
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    -- 找到包含该 buffer 的窗口并聚焦
    local win = vim.fn.bufwinid(M.buf)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  -- 打开新终端运行 opencode，取其 buffer 引用
  vim.cmd("botright vsplit term://opencode --port")
  M.buf = vim.api.nvim_get_current_buf()
  vim.bo[M.buf].bufhidden = "hide"
  vim.cmd("wincmd p") -- 回到原窗口
  vim.notify("opencode starting... press <leader>oa to ask after ~3s", vim.log.levels.INFO)
end

function M.close()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_delete(M.buf, { force = true })
    M.buf = nil
    vim.notify("opencode closed", vim.log.levels.INFO)
  end
end

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    init = function()
      vim.g.opencode_opts = {
        server = {
          -- opencode 的 ask() 发现没有 server 时会调此函数
          start = function()
            M.open()
          end,
        },
      }
    end,
    config = function()
      vim.o.autoread = true

      -- 提问
      vim.keymap.set("n", "<leader>oa", function()
        require("opencode").ask("@buffer: ")
      end, { desc = "Ask opencode (buffer)" })

      vim.keymap.set("v", "<leader>oa", function()
        require("opencode").ask("@this: ")
      end, { desc = "Ask opencode (selection)" })

      -- 打开/显示 opencode 终端
      vim.keymap.set("n", "<leader>oo", M.open, { desc = "Open opencode terminal" })

      -- 关闭 opencode
      vim.keymap.set("n", "<leader>oq", M.close, { desc = "Quit opencode" })
    end,
  },
}
