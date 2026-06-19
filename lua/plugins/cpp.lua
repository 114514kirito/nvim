-- VSCode 模式：VSCode 有内置单词高亮和头文件切换
if vim.g.vscode then return {} end

return {
  -- header/source float preview + clangd switch
  {
    "neovim/nvim-lspconfig",
    config = function()
      local function float_peek(filepath)
        local buf = vim.fn.bufadd(filepath)
        vim.fn.bufload(buf)
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].readonly = true

        local w = math.floor(vim.o.columns * 0.80)
        local h = math.floor(vim.o.lines * 0.80)
        local col = math.floor((vim.o.columns - w) / 2)
        local row = math.floor((vim.o.lines - h) / 2)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = w,
          height = h,
          col = col,
          row = row,
          style = "minimal",
          border = "rounded",
          title = " " .. vim.fn.fnamemodify(filepath, ":t") .. " ",
          title_pos = "center",
        })

        vim.keymap.set("n", "q", function()
          if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
          if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        end, { buffer = buf, desc = "Close preview" })
      end

      local function find_counterpart()
        local name = vim.fn.expand("%:t:r")
        local current = vim.fn.expand("%:t")
        local dir = vim.fn.expand("%:p:h")
        local exts = { "h", "hh", "hpp", "hxx", "cc", "cpp", "cxx", "c" }

        local candidates = {}
        for _, ext in ipairs(exts) do
          local f = name .. "." .. ext
          if f ~= current and vim.fn.filereadable(dir .. "/" .. f) == 1 then
            table.insert(candidates, dir .. "/" .. f)
          end
        end

        if #candidates == 1 then
          float_peek(candidates[1])
        elseif #candidates > 1 then
          vim.ui.select(candidates, {
            prompt = "Peek header/source:",
            format_item = function(item) return vim.fn.fnamemodify(item, ":t") end,
          }, function(choice)
            if choice then float_peek(choice) end
          end)
        else
          vim.notify("No counterpart found", vim.log.levels.WARN)
        end
      end

      vim.keymap.set("n", "<leader>ch", find_counterpart, { desc = "Peek header/source" })
      vim.keymap.set("n", "<A-o>", "<cmd>ClangdSwitchSourceHeader<CR>", { desc = "Switch header/source" })
    end,
  },

  -- Word highlight (vim-illuminate)
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure({ delay = 200 })
    end,
  },
}
