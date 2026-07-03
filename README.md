# Neovim 配置

> LazyVim v8 · C/C++ · Go · Python

## 快捷键

`<leader>` = `<Space>`，按空格弹出 which-key 菜单。

### LSP / 跳转

| 键 | 功能 |
|---|------|
| `gd` | 跳转到定义 |
| `gh` | 查找引用 |
| `gi` | 预览实现（单结果浮窗，多结果 picker）|
| `K` | 浮动文档（圆角）|
| `<leader>cF` | LSP 格式化 |
| `<leader>cr` | 重命名符号 |

### C/C++ 专项

| 键 | 功能 |
|---|------|
| `<leader>cf` | 单文件编译+运行（gcc/g++ -g -Wall -fsanitize）|
| `<leader>cp` | 预览头文件/源文件 |
| `<leader>ch` | 切换 .h / .c（clangd）|

### Debug（nvim-dap）

| 键 | 功能 |
|---|------|
| `<F5>` | 启动 / 继续 |
| `<S-F5>` | 停止 |
| `<F9>` | 断点切换 |
| `<F10>` | 单步跳过 |
| `<F11>` | 单步进入 |
| `<F12>` | 单步跳出 |
| `<F8>` | REPL 开关 |
| `<leader>db` | 断点切换 |
| `<leader>dc` | 运行/继续 |
| `<leader>do` | 单步跳出 |
| `<leader>dO` | 单步跳过 |
| `<leader>di` | 单步进入 |
| `<leader>dt` | 停止 |
| `<leader>dl` | 运行上次 |
| `<leader>du` | DAP UI 开关 |
| `<leader>dB` | 条件断点 |
| `<leader>dr` | REPL 切换 |

### CMake

| 键 | 功能 |
|---|------|
| `<leader>cC` | Configure |
| `<leader>cb` | Build |
| `<leader>ce` | Run |
| `<leader>ct` | Test |
| `<leader>cs` | Stop |

### Git（gitsigns）

| 键 | 功能 |
|---|------|
| `]c` / `[c` | 下一/上一 hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hb` | Blame |
| `<leader>hd` | Diff |

### 终端

| 键 | 功能 |
|---|------|
| `<leader>ft` | 浮动终端（项目根目录）|

### opencode.nvim

| 键 | 功能 |
|---|------|
| `<leader>oo` | 打开 opencode |
| `<leader>oa` | 提问（buffer/selection）|
| `<leader>oq` | 关闭 opencode |

### 折叠（nvim-ufo）

| 键 | 功能 |
|---|------|
| `zR` | 展开全部 |
| `zM` | 折叠全部 |
| `zK` | 预览折叠内容 |

### 左手键盘

| 键 | 功能 |
|---|------|
| `jk` / `jj` | Escape（插入模式）|
| `<C-s>` | 保存 |
| `<C-q>` | 关闭窗口 |
| `<leader>nh` | 清除搜索高亮 |

### 补全（blink.cmp）

| 键 | 效果 |
|---|------|
| `<Tab>` | snippet 前进 → 确认补全 → C/C++ 缩进对齐 → fallback |
| `<Enter>` / `<C-y>` | 确认当前项 |

## Extras 已启用

`lang.clangd` · `lang.cmake` · `lang.go` · `lang.python` · `lang.json` · `lang.java` · `lang.markdown` · `dap.core` · `ui.smear-cursor` · `ui.mini-indentscope`

## 语言工具栈

| 语言 | LSP | Formatter | Linter | Debugger |
|------|-----|-----------|--------|----------|
| C/C++ | clangd | clangd | clangd | codelldb / cppdbg |
| Go | gopls | gofumpt | golangci-lint | delve |
| Python | basedpyright | ruff | ruff | debugpy |

## 架构

```
~/.config/nvim/
├── init.lua
├── lazyvim.json / lazy-lock.json / stylua.toml
└── lua/
    ├── config/
    │   ├── lazy.lua          # 核心：插件 + extras 导入
    │   ├── options.lua       # 4 空格缩进、scrolloff 等
    │   ├── keymaps.lua       # 全局键位覆盖 (gh/gd/K/gi)
    │   ├── autocmds.lua      # 自动命令
    │   └── vscode.lua        # VSCode 模式检测
    └── plugins/
        ├── lsp-keys.lua      # clangd 配置 + LSP 键位
        ├── cmp.lua           # blink.cmp Tab 行为
        ├── dap.lua           # C/C++ DAP 适配器 + F 键
        ├── gdb.lua           # nvim-gdb 集成
        ├── cmake.lua         # cmake-tools.nvim
        ├── cpp.lua           # 编译运行 + 头文件预览
        ├── python.lua        # basedpyright 配置
        ├── gitsigns.lua      # Git 标记
        ├── markdown.lua      # Markdown 预览
        ├── fold.lua          # nvim-ufo 折叠
        ├── indent.lua        # treesitter 缩进
        ├── opencode.lua      # opencode.nvim
        ├── trouble.lua       # 诊断面板
        ├── snacks-ext.lua    # Snacks 扩展
        ├── ui.lua            # 主题 + lualine + bufferline
        └── vscode.lua        # VSCode 模式插件过滤
```

## 日常命令

| 命令 | 用途 |
|------|------|
| `:Lazy` | 插件管理 |
| `:LazyExtras` | 浏览/切换 extras |
| `:Mason` | LSP/工具管理 |
| `:checkhealth` | 健康检查 |

---

*LazyVim v8 · 2026-07-04*
