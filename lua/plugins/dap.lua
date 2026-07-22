-- VSCode 模式：调试由 VSCode 原生 DAP 处理，nvim-dap 无需加载
if vim.g.vscode then return {} end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<F5>", desc = "Continue / Start" },
      { "<S-F5>", desc = "Terminate" },
      { "<F8>", desc = "REPL Toggle" },
      { "<F9>", desc = "Toggle Breakpoint" },
      { "<F10>", desc = "Step Over" },
      { "<F11>", desc = "Step Into" },
      { "<F12>", desc = "Step Out" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- ============================================================
      -- 1. DAP UI 布局
      -- ============================================================
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.50 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.60 },
              { id = "console", size = 0.40 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })

      -- 调试启动 → 打开 UI；终止/退出 → 关闭
      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      -- ============================================================
      -- 2. Adapters: codelldb + cpptools (C/C++)
      -- ============================================================
      local mason_dir = vim.fn.stdpath("data") .. "/mason/packages"

      local function check_adapter(name, path)
        if vim.fn.filereadable(path) == 1 then return true end
        vim.notify(
          string.format("DAP: %s not installed.\nRun :MasonInstall %s", name, name),
          vim.log.levels.ERROR,
          { title = "DAP Adapter Missing" }
        )
        return false
      end

      local codelldb_path = mason_dir .. "/codelldb/extension/adapter/codelldb"
      if check_adapter("codelldb", codelldb_path) then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = { command = codelldb_path, args = { "--port", "${port}" } },
        }
      end

      local cppdbg_path = mason_dir .. "/cpptools/extension/debugAdapters/bin/OpenDebugAD7"
      if check_adapter("cpptools", cppdbg_path) then
        dap.adapters.cppdbg = {
          id = "cppdbg",
          type = "executable",
          command = cppdbg_path,
          options = { detached = false },
        }
      end

      -- ============================================================
      -- 3. Go adapter: 手动注册 Delve（保险，即使 nvim-dap-go 未 setup 也能用）
      -- ============================================================
      local dlv_path = mason_dir .. "/delve/dlv"
      if vim.fn.filereadable(dlv_path) == 1 then
        dap.adapters.go = function(callback, config)
          local host = config.host or "127.0.0.1"
          local port = config.port or "38697"
          callback({
            type = "server",
            host = host,
            port = port,
            executable = {
              command = dlv_path,
              args = { "dap", "-l", host .. ":" .. port },
            },
          })
        end
      end

      -- ============================================================
      -- 4. Launch 配置 (C/C++)
      -- ============================================================
      local function pick_binary()
        return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
      end

      dap.configurations.c = dap.configurations.c or {}
      dap.configurations.cpp = dap.configurations.cpp or {}
      vim.list_extend(dap.configurations.c, {
        {
          name = "Launch (codelldb)", type = "codelldb", request = "launch",
          program = pick_binary, cwd = "${workspaceFolder}", stopOnEntry = true,
        },
        {
          name = "Launch (cppdbg / GDB)", type = "cppdbg", request = "launch",
          program = pick_binary, cwd = "${workspaceFolder}", stopAtEntry = true,
        },
        {
          name = "Launch with args (codelldb)", type = "codelldb", request = "launch",
          program = pick_binary, cwd = "${workspaceFolder}", stopOnEntry = true,
          args = function()
            local raw = vim.fn.input("Args: ") return vim.split(raw, " ")
          end,
        },
        {
          name = "Attach (codelldb)", type = "codelldb", request = "attach",
          pid = function() return tonumber(vim.fn.input("PID: ")) end,
          cwd = "${workspaceFolder}",
        },
      })
      if not dap.configurations.cpp or #dap.configurations.cpp == 0 then
        dap.configurations.cpp = dap.configurations.c
      end

      -- Go 调试配置（手动注册，不依赖 nvim-dap-go 的 setup）
      dap.configurations.go = dap.configurations.go or {}
      local go_existing = {}
      for _, c in ipairs(dap.configurations.go) do go_existing[c.name] = true end
      if not go_existing["Debug Package"] then
        vim.list_extend(dap.configurations.go, {
          {
            type = "go", name = "Debug Package", request = "launch",
            program = "${fileDirname}",
          },
          {
            type = "go", name = "Debug File", request = "launch",
            program = "${file}",
          },
          {
            type = "go", name = "Debug Test", request = "launch",
            mode = "test", program = "${fileDirname}",
          },
        })
      end

      -- ============================================================
      -- 5. 快捷键
      --    F5: session 不存在 → 弹出选择 → 启动
      --        session 存在   → continue（继续到下一断点）
      -- ============================================================
      vim.keymap.set("n", "<F5>", function()
        if dap.session() then
          dap.continue()
        else
          dap.continue()
        end
      end, { desc = "Start / Continue" })
      vim.keymap.set("n", "<S-F5>", dap.terminate, { desc = "Terminate" })
      vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out" })

      vim.keymap.set("n", "<F8>", function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dap-repl" then
            dap.repl.close()
            return
          end
        end
        dap.repl.open()
      end, { desc = "REPL Toggle" })

      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle UI" })
    end,
  },
}
