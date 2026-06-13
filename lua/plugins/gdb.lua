-- VSCode 模式：VSCode 自带调试 UI，nvim-gdb 无需加载
if vim.g.vscode then return {} end

return {
  {
    "sakhnik/nvim-gdb",
    build = "./install.sh",
    config = function()
      vim.g.nvim_gdb_use_neovim_terminal = true
      vim.g.nvim_gdb_make_edits_read_only = true

      -- 把 F 键映射清空，避免和 nvim-dap 冲突
      -- 在 GDB 窗口里直接用原生命令: n/s/c/fin/bt/until
      vim.g.nvimgdb_key_continue = ""
      vim.g.nvimgdb_key_next = ""
      vim.g.nvimgdb_key_step = ""
      vim.g.nvimgdb_key_finish = ""
      vim.g.nvimgdb_key_until = ""
      vim.g.nvimgdb_key_breakpoint = ""
      vim.g.nvimgdb_key_frameup = ""
      vim.g.nvimgdb_key_framedown = ""
      vim.g.nvimgdb_key_eval = ""
    end,
  },
}
