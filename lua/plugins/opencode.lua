-- ============================================
-- opencode.nvim — tmux server/client 模式
-- 参考: patricorgi/dotfiles, nickjvandyke/opencode.nvim
-- ============================================
local opencode

local function load_opencode()
  if opencode then
    return opencode
  end
  require("lazy").load({ plugins = { "opencode.nvim" } })

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

  opencode = require("opencode")
  return opencode
end

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    lazy = true,
    keys = {
      { "<leader>oa", mode = { "n", "v" }, desc = "Ask opencode" },
      { "<leader>ot", desc = "Toggle opencode (tmux)" },
      { "<leader>os", desc = "Start opencode server" },
      { "<leader>oK", desc = "Stop opencode server" },
    },
    config = function()
      vim.o.autoread = true

      vim.keymap.set("n", "<leader>oa", function()
        load_opencode().ask("@buffer: ")
      end, { desc = "Ask opencode (buffer)" })

      vim.keymap.set("v", "<leader>oa", function()
        load_opencode().ask("@this: ")
      end, { desc = "Ask opencode (selection)" })

      vim.keymap.set("n", "<leader>ot", function()
        load_opencode().toggle()
      end, { desc = "Toggle opencode (tmux)" })

      vim.keymap.set("n", "<leader>os", function()
        load_opencode().start()
        vim.notify("opencode server starting...", vim.log.levels.INFO)
      end, { desc = "Start opencode server" })

      vim.keymap.set("n", "<leader>oK", function()
        load_opencode().stop()
        vim.notify("opencode server stopped", vim.log.levels.INFO)
      end, { desc = "Stop opencode server" })
    end,
  },
}
