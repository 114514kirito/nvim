-- opencode.nvim — tmux server/client 模式
-- key: init() 在插件加载前设 opts；toggle/stop 直接调自定义函数（不在公开 API 中）

local function tmux_window_exists()
  local windows = vim.fn.systemlist({ "tmux", "list-windows", "-F", "#W" })
  return vim.tbl_contains(windows, "opencode")
end

local function toggle()
  if tmux_window_exists() then
    vim.fn.system({ "tmux", "select-window", "-t", "opencode" })
  else
    vim.fn.system({ "tmux", "new-window", "-n", "opencode", "opencode", "serve" })
  end
end

local function start()
  if not tmux_window_exists() then
    vim.fn.system({ "tmux", "new-window", "-dn", "opencode", "opencode", "serve" })
  end
  vim.notify("opencode server starting...", vim.log.levels.INFO)
end

local function stop()
  if tmux_window_exists() then
    vim.fn.system({ "tmux", "kill-window", "-t", "opencode" })
    vim.notify("opencode server stopped", vim.log.levels.INFO)
  end
end

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    init = function()
      -- 必须在插件源码运行前设置，否则 server discovery 找不到
      vim.g.opencode_opts = {
        server = {
          start = start,
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

      vim.keymap.set("n", "<leader>os", start, { desc = "Start opencode server" })
      vim.keymap.set("n", "<leader>ot", toggle, { desc = "Toggle opencode (tmux)" })
      vim.keymap.set("n", "<leader>oK", stop, { desc = "Stop opencode server" })
    end,
  },
}
