-- VSCode 模式：VSCode 有内置单词高亮和头文件切换
if vim.g.vscode then return {} end

return {
  -- header/source float preview
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

        -- 收集所有候选文件（同级目录 + 常见子目录 + 父目录）
        local candidates = {}

        local function scan_directory(search_dir)
          for _, ext in ipairs(exts) do
            local f = search_dir .. "/" .. name .. "." .. ext
            if f ~= (dir .. "/" .. current) and vim.fn.filereadable(f) == 1 then
              candidates[#candidates + 1] = f
            end
          end
        end

        -- 1. 同级目录
        scan_directory(dir)

        -- 2. 常见子目录 (include/  src/  inc/  source/)
        for _, sub in ipairs({ "include", "src", "inc", "source", "headers" }) do
          local d = dir .. "/" .. sub
          if vim.fn.isdirectory(d) == 1 then scan_directory(d) end
        end

        -- 3. 父目录下的常见子目录（处理 include/ 和 src/ 平级的情况）
        local parent = vim.fn.fnamemodify(dir, ":h")
        for _, sub in ipairs({ "include", "src", "inc", "source", "headers" }) do
          local d = parent .. "/" .. sub
          if d ~= dir and vim.fn.isdirectory(d) == 1 then scan_directory(d) end
        end

        -- 4. 父目录本身
        scan_directory(parent)

        -- 去重
        local seen = {}
        local unique = {}
        for _, c in ipairs(candidates) do
          if not seen[c] then
            seen[c] = true
            unique[#unique + 1] = c
          end
        end

        if #unique == 1 then
          float_peek(unique[1])
        elseif #unique > 1 then
          vim.ui.select(unique, {
            prompt = "Peek header/source:",
            format_item = function(item) return vim.fn.fnamemodify(item, ":t") end,
          }, function(choice)
            if choice then float_peek(choice) end
          end)
        else
          vim.notify("No counterpart found", vim.log.levels.WARN)
        end
      end

      vim.keymap.set("n", "<leader>cp", find_counterpart, { desc = "Peek header/source" })
    end,
  },

  -- Word highlight (vim-illuminate)
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure({ delay = 200 })
    end,
  },

  -- 单文件 C/C++ 编译运行 (<leader>cR)
  {
    "neovim/nvim-lspconfig",
    keys = {
      {
        "<leader>cR",
        function()
          local file = vim.fn.expand("%:p")
          local out = vim.fn.expand("%:p:r")
          local ft = vim.bo.filetype
          if ft ~= "c" and ft ~= "cpp" then
            vim.notify("Not a C/C++ file", vim.log.levels.WARN)
            return
          end
          local cc = ft == "c" and "gcc" or "g++"
          local flags = "-g -Wall -Wextra -Wpedantic -fsanitize=address,undefined"
          local cmd = string.format(
            "%s %s -o %s %s && echo '=== BUILD OK ===' && %s",
            cc,
            flags,
            vim.fn.shellescape(out),
            vim.fn.shellescape(file),
            vim.fn.shellescape(out)
          )
          vim.cmd("botright 12split term://" .. cmd)
        end,
        desc = "Compile & Run (C/C++)",
      },
    },
  },
}
