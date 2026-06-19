-- opencode.nvim — 直接用，不依赖 tmux
-- opencode.nvim 自带内置面板（toggle），不需要外部 server

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    config = function()
      vim.o.autoread = true

      -- <leader>oa: 提问 opencode
      vim.keymap.set("n", "<leader>oa", function()
        require("opencode").ask("@buffer: ")
      end, { desc = "Ask opencode (buffer)" })

      vim.keymap.set("v", "<leader>oa", function()
        require("opencode").ask("@this: ")
      end, { desc = "Ask opencode (selection)" })

      -- <leader>ot: 打开/关闭 opencode 内置面板
      vim.keymap.set("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })
    end,
  },
}
