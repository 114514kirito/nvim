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
    vim.cmd("wincmd p")
    vim.notify("opencode started in nvim terminal", vim.log.levels.INFO)
  end
end

function M.close()
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
