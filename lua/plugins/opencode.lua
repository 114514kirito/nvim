-- opencode.nvim — 最简配置
-- ask() 会自动发现/启动 server（通过 vim.g.opencode_opts.server.start）
-- 不需要手动管理 server

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    init = function()
      vim.g.opencode_opts = {
        server = {
          -- ask() 触发时，如果没有 server，自动调用此函数启动
          start = function()
            vim.cmd("botright vsplit term://opencode --port")
            vim.cmd("wincmd p")
          end,
        },
      }
    end,
    config = function()
      vim.o.autoread = true

      -- 提问（自动启动 server）
      vim.keymap.set("n", "<leader>oa", function()
        require("opencode").ask("@buffer: ")
      end, { desc = "Ask opencode (buffer)" })

      vim.keymap.set("v", "<leader>oa", function()
        require("opencode").ask("@this: ")
      end, { desc = "Ask opencode (selection)" })
    end,
  },
}
