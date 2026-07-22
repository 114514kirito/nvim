-- VSCode 模式：这些 UI 插件（lualine, bufferline, indent-blankline, rainbow-delimiters）
-- 在 VSCode 中完全由 VSCode 自身 UI 替代，无需加载
if vim.g.vscode then return {} end

return {
  -- 主题：终端半透 + 实色底 — 侧边栏透出终端，编辑区不透明保证阅读体验
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = false,           -- 编辑区不透明，注释/代码高亮清晰
      styles = {
        sidebars = "transparent",    -- 侧边栏（文件树、诊断列表）透出终端质感
        floats = "transparent",      -- 浮窗半透（hover、补全菜单）
      },
      on_highlights = function(hl, colors)
        -- 注释用更亮的颜色，在 dark terminal 中一目了然
        hl.Comment = { fg = "#8B9DC3", italic = true }
      end,
    },
  },

  -- 状态栏：跟随 tokyonight
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- bufferline：极简标签
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },

  -- 缩进线
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      scope = { enabled = true, show_start = false },
      indent = { char = "▏" },
    },
  },

  -- 括号彩虹色
  {
    "HiPhish/rainbow-delimiters.nvim",
  },
}
