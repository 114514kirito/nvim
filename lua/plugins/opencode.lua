-- opencode.nvim — tmux server/client 模式
-- keys: 直接定义处理函数（lazy.nvim 自动管理激活/which-key）
-- config: 仅做一次性初始化

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    keys = {
      {
        "<leader>oa",
        function()
          require("opencode").ask("@buffer: ")
        end,
        mode = "n",
        desc = "Ask opencode (buffer)",
      },
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ")
        end,
        mode = "v",
        desc = "Ask opencode (selection)",
      },
      {
        "<leader>ot",
        function()
          require("opencode").toggle()
        end,
        desc = "Toggle opencode (tmux)",
      },
      {
        "<leader>os",
        function()
          require("opencode").start()
          vim.notify("opencode server starting...", vim.log.levels.INFO)
        end,
        desc = "Start opencode server",
      },
      {
        "<leader>oK",
        function()
          require("opencode").stop()
          vim.notify("opencode server stopped", vim.log.levels.INFO)
        end,
        desc = "Stop opencode server",
      },
    },
    config = function()
      vim.o.autoread = true
      vim.g.opencode_opts = {
        server = {
          cmd = "opencode",
          start = function()
            vim.fn.system({ "tmux", "new-window", "-dn", "opencode", "opencode", "serve" })
          end,
          stop = function()
            vim.fn.system({ "tmux", "kill-window", "-t", "opencode" })
          end,
          toggle = function()
            local windows = vim.fn.systemlist({ "tmux", "list-windows", "-F", "#W" })
            if vim.tbl_contains(windows, "opencode") then
              vim.fn.system({ "tmux", "select-window", "-t", "opencode" })
            else
              vim.fn.system({ "tmux", "new-window", "-n", "opencode", "opencode", "serve" })
            end
          end,
        },
      }
    end,
  },
}
