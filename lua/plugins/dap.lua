-- VSCode 模式：调试由 VSCode 原生 DAP 处理，nvim-dap 无需加载
if vim.g.vscode then return {} end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    -- lazy-load: 首次按下任一 F 键时加载
    keys = {
      { "<F5>", desc = "DAP: Start / Continue" },
      { "<S-F5>", desc = "DAP: Terminate" },
      { "<F8>", desc = "DAP: REPL Toggle" },
      { "<F9>", desc = "DAP: Toggle Breakpoint" },
      { "<F10>", desc = "DAP: Step Over" },
      { "<F11>", desc = "DAP: Step Into" },
      { "<F12>", desc = "DAP: Step Out" },
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

      -- 调试启动时自动打开 UI，终止/退出时自动关闭
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
      -- 2. Adapters: 手动指定 Mason 安装的 codelldb + cpptools 路径
      -- ============================================================
      local mason_dir = vim.fn.stdpath("data") .. "/mason/packages"

      local function check_adapter(name, path)
        if vim.fn.filereadable(path) == 1 then
          return true
        end
        vim.notify(
          string.format("DAP: %s not installed.\nRun :MasonInstall %s to install it.", name, name),
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
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
          },
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
      -- 3. Launch 配置 (C/C++)
      -- .vscode/launch.json 现在由 nvim-dap 自动按需读取，无需手动加载
      -- ============================================================

      local function pick_binary()
        return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
      end

      dap.configurations.c = dap.configurations.c or {}
      dap.configurations.cpp = dap.configurations.cpp or {}
      vim.list_extend(dap.configurations.c, {
        {
          name = "Launch (codelldb)",
          type = "codelldb",
          request = "launch",
          program = pick_binary,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
        },
        {
          name = "Launch (cppdbg / GDB)",
          type = "cppdbg",
          request = "launch",
          program = pick_binary,
          cwd = "${workspaceFolder}",
          stopAtEntry = true,
        },
        {
          name = "Launch with args (codelldb)",
          type = "codelldb",
          request = "launch",
          program = pick_binary,
          args = function()
            local raw = vim.fn.input("Args: ")
            return vim.split(raw, " ")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
        },
        {
          name = "Attach (codelldb)",
          type = "codelldb",
          request = "attach",
          pid = function()
            return tonumber(vim.fn.input("PID: "))
          end,
          cwd = "${workspaceFolder}",
        },
      })
      -- cpp 与 c 共享同一套默认配置（若 launch.json 未单独定义 cpp）
      if not dap.configurations.cpp or #dap.configurations.cpp == 0 then
        dap.configurations.cpp = dap.configurations.c
      end

      -- ============================================================
      -- 4. 快捷键 — 经典 F 键区
      -- ============================================================
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start / Continue" })
      vim.keymap.set("n", "<S-F5>", dap.terminate, { desc = "Terminate" })
      vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out" })

      -- F8: REPL 开关 — 打开/关闭交互控制台，用于输入 -exec 等 GDB/LLDB 原生命令
      vim.keymap.set("n", "<F8>", function()
        local repl_open = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dap-repl" then
            repl_open = true
            break
          end
        end
        if repl_open then
          dap.repl.close()
        else
          dap.repl.open()
        end
      end, { desc = "REPL Toggle" })

      -- 辅助快捷键 (保留给不需要 F 键的场景)
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle UI" })
    end,
  },
}
