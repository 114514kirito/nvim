-- opencode.nvim — tmux 模式 + nvim 终端双模式
-- 默认 tmux；如果没有 tmux session，fallback 到 nvim 内置终端
--
-- <leader>oo  打开/切换到 opencode（tmux 优先）
-- <leader>oa  提问（buffer/selection）
-- <leader>oq  关闭 opencode

local has_tmux = vim.fn.executable("tmux") == 1

local function tmux_running()
  if not has_tmux then return false end
  local ok, result = pcall(vim.fn.systemlist, { "tmux", "list-sessions" })
  return ok and #result > 0
end

local function tmux_window_exists()
  local windows = vim.fn.systemlist({ "tmux", "list-windows", "-F", "#W" })
  return vim.tbl_contains(windows, "opencode")
end

local M = {}
M._nvim_term_buf = nil -- 记录 nvim 终端模式的 opencode buffer

function M.open()
  if tmux_running() then
    if tmux_window_exists() then
      vim.fn.system({ "tmux", "select-window", "-t", "opencode" })
    else
      vim.fn.system({ "tmux", "new-window", "-n", "opencode", "opencode", "--port" })
      vim.notify("opencode started in tmux window 'opencode'", vim.log.levels.INFO)
    end
  else
    -- fallback: nvim 内置终端
    vim.cmd("botright vsplit term://opencode --port")
    M._nvim_term_buf = vim.api.nvim_get_current_buf()
    vim.cmd("wincmd p")
    vim.notify("opencode started in nvim terminal", vim.log.levels.INFO)
  end
end

function M.close()
  -- nvim 终端模式：关闭 opencode 终端 buffer 和窗口
  if M._nvim_term_buf and vim.api.nvim_buf_is_valid(M._nvim_term_buf) then
    local wins = vim.fn.win_findbuf(M._nvim_term_buf)
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
    M._nvim_term_buf = nil
    vim.notify("opencode nvim terminal closed", vim.log.levels.INFO)
  end
  -- tmux 模式
  if tmux_running() and tmux_window_exists() then
    vim.fn.system({ "tmux", "kill-window", "-t", "opencode" })
    vim.notify("opencode tmux window closed", vim.log.levels.INFO)
  end
end

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    init = function()
      vim.g.opencode_opts = {
        server = {
          start = function()
            M.open()
          end,
        },
      }
    end,
    config = function()
      vim.o.autoread = true

      vim.keymap.set("n", "<leader>oa", function()
        require("opencode").ask("@buffer: ")
      end, { desc = "Ask opencode (buffer)" })

      vim.keymap.set("v", "<leader>oa", function()
        require("opencode").ask("@this: ")
      end, { desc = "Ask opencode (selection)" })

      vim.keymap.set("n", "<leader>oo", M.open, { desc = "Open opencode (tmux/nvim)" })
      vim.keymap.set("n", "<leader>oq", M.close, { desc = "Close opencode" })
    end,
  },
}
