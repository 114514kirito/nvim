-- VSCode 模式：这些 UI 插件（lualine, bufferline, indent-blankline, rainbow-delimiters）
-- 在 VSCode 中完全由 VSCode 自身 UI 替代，无需加载
if vim.g.vscode then return {} end

return {
  -- 主题：少量透明保留质感，但主体不透明保证注释/代码高亮清晰可读
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = false,           -- 主背景不透明，注释清晰可见
      styles = {
        sidebars = "transparent",    -- 侧边栏半透（nvim-tree、trouble 等）
        floats = "transparent",      -- 浮窗半透（hover、补全菜单等）
      },
      on_colors = function(colors)
        -- 提升注释亮度，防止透明背景下看不清
        colors.Comment = { fg = "#8b9dc3" }
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
