-- opencode.nvim — tmux server/client 模式
-- 关键：vim.g.opencode_opts 必须在插件加载前通过 init() 设置

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    -- init 在插件加载前运行，保证 opts 先于 opencode 的 setup()
    init = function()
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
    },
    config = function()
      vim.o.autoread = true
    end,
  },
}
