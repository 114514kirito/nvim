# 💤 LazyVim — 个人 Neovim 配置文档

> 基于 [LazyVim](https://github.com/LazyVim/LazyVim) v8，面向 C/C++ · Go · Python 开发。
> 按 `<Space>` 键弹出 which-key 菜单，所有快捷键均可由此发现。

---

## ⌨️ 快捷键层次结构 / Keymap Hierarchy

> **阅读指南** Reading Guide：
> - `〈leader〉` = `<Space>`（空格键）
> - `n` = Normal 普通模式，`i` = Insert 插入模式，`v` = Visual 可视模式，`x` = Visual/Select 可视
> - 标注 ⭐ 的为本配置自定义覆盖的键位
> - 按下 `<Space>` 后会弹出 which-key 菜单，按分类字母进入子菜单

---

### 🔹 `<Space>` 菜单（which-key 弹出）

按下空格键后，which-key 显示出以下分类：

```
〈leader〉
├── b     Buffer         缓冲区
├── c     Code           代码 (LSP)
├── f     Find/File      查找/文件
├── g     Git            Git 版本控制
├── s     Search         搜索/符号
├── t     Terminal       终端/切换
├── w     Window         窗口管理
├── x     Diagnostics    诊断/Trouble
├── h     Help           帮助
├── n     Notifications  通知
├── q     Quit/Session   退出/会话
├── u     UI             界面切换
└── m     Mason          LSP 工具管理
```

---

### 🔹 `<Space> c` — Code 代码 (LSP) / 代码动作

| 按键 Key | 功能 (中文) | Function (English) | 模式 |
|----------|-------------|-------------------|------|
| `<leader>ca` | 代码动作 | Code Action | n, x |
| `<leader>cA` | 源动作 | Source Action | n |
| `<leader>cr` | 重命名 ⭐ | Rename | n |
| `<leader>cR` | 重命名文件 | Rename File | n |
| `<leader>cl` | LSP 信息 | Lsp Info | n |
| `<leader>co` | 整理导入 | Organize Imports | n |
| `<leader>cc` | 执行代码透镜 | Run Codelens | n, x |
| `<leader>cC` | 刷新代码透镜 | Refresh Codelens | n |
| `<leader>ch` | C/C++ 源文件/头文件切换 | Switch Source/Header | n |
| `<leader>cv` | Python 虚拟环境选择 | Select VirtualEnv | n |

---

### 🔹 `<Space> f` — Find/File 查找/文件

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>ff` | 查找文件 | Find Files |
| `<leader>fF` | 在当前目录查找 | Find in CWD |
| `<leader>fr` | 最近文件 | Recent Files |
| `<leader>fg` | 查找 Git 文件 | Find Git Files |
| `<leader>fb` | 查找缓冲区 | Find Buffers |
| `<leader>fw` | 当前词 Grep | Grep Word |
| `<leader>fW` | 目录 Grep | Grep CWD |
| `<leader>fc` | 查找配置 | Find Config |
| `<leader>fh` | 查找帮助 | Find Help |
| `<leader>fk` | 快捷键列表 | Keymaps |
| `<leader>fm` | Man 手册 | Man Pages |
| `<leader>f`  | 智能查找 (Snacks) | Smart Find |

---

### 🔹 `<Space> g` — Git 版本控制

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>gg` | LazyGit 面板 | Lazygit |
| `<leader>gb` | 行归属 | Git Blame |
| `<leader>gB` | 浏览仓库 | Browse Repo |
| `<leader>gd` | 差异对比 | Git Diff |
| `<leader>gh` | 暂存块 | Stage Hunk |
| `<leader>gu` | 取消暂存块 | Unstage Hunk |
| `<leader>gs` | 暂存 | Stage |
| `<leader>gR` | 重置 | Reset |

---

### 🔹 `<Space> s` — Search 搜索/符号

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>ss` | 缓冲区符号 | Symbols (Buffer) |
| `<leader>sS` | 工作区符号 | Symbols (Workspace) |
| `<leader>sw` | 搜索光标词 | Grep Word (Buffer) |
| `<leader>sW` | 搜索光标词 (全部) | Grep Word (Workspace) |

---

### 🔹 `<Space> w` — Window 窗口管理

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>wh` | 移至左侧窗口 | Move Left |
| `<leader>wj` | 移至下方窗口 | Move Down |
| `<leader>wk` | 移至上方窗口 | Move Up |
| `<leader>wl` | 移至右侧窗口 | Move Right |
| `<leader>wv` | 垂直分割 | Vertical Split |
| `<leader>ws` | 水平分割 | Horizontal Split |
| `<leader>wc` | 关闭窗口 | Close Window |
| `<leader>w=` | 均分窗口 | Equalize |
| `<C-w>e` | 均分窗口 ⭐ | Equalize (自定义) |

---

### 🔹 `<Space> x` — Diagnostics 诊断

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>xx` | Trouble 面板切换 | Trouble Toggle |
| `<leader>xl` | 位置列表 | Location List |
| `<leader>xq` | Quickfix 列表 | Quickfix List |

---

### 🔹 `<Space> b` — Buffer 缓冲区

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>bb` | 切换缓冲区 | Switch Buffer |
| `<leader>bd` | 删除缓冲区 | Delete Buffer |
| `<leader>bp` | 固定缓冲区 | Pin Buffer |
| `<leader>bP` | 取消固定 | Unpin Buffer |
| `<leader>bo` | 关闭其他缓冲区 | Close Others |
| `<leader>bl` | 关闭左侧缓冲区 | Close Left |
| `<leader>br` | 关闭右侧缓冲区 | Close Right |
| `<leader>be` | 缓冲区浏览器 | Buffer Explorer |

---

### 🔹 `<Space> t` — Terminal/Toggle 终端/切换

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>tt` | 终端切换 | Toggle Terminal |
| `<leader>tf` | 浮动终端 | Float Terminal |
| `<leader>tu` | UI 切换 | Toggle UI |
| `<leader>tn` | 通知 | Notifications |
| `<leader>t`  | 终端 (root) | Terminal (root) |

---

### 🔹 `<Space> h` / `<Space> n` / `<Space> q` / `<Space> m`

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>h` | 帮助页面 | Help |
| `<leader>n` | 通知历史 | Notifications |
| `<leader>q` | 退出/恢复会话 | Quit / Session |
| `<leader>cm` | Mason (LSP 工具管理) | Mason |

---

### 🔹 `g` 前缀 — Go To 跳转

按下 `g` 后 which-key 显示跳转子菜单：

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `gd` ⭐ | 悬浮窗预览定义 | Peek Definition (floating preview) |
| `gD` ⭐ | 直接跳转到定义 | Goto Definition (direct jump) |
| `gr` ⭐ | 重命名符号 | Rename Symbol |
| `gh` ⭐ | 查找引用 | Find References |
| `gI` | 跳转到实现 | Goto Implementation |
| `gy` | 跳转到类型定义 | Goto Type Definition |
| `gK` | 签名帮助 | Signature Help |
| `gf` | 打开光标下的文件 | Open File Under Cursor |
| `gx` | 打开光标下的 URL | Open URL Under Cursor |
| `gc` | 注释切换 (行/块) | Toggle Comment |
| `gcc` | 注释当前行 | Comment Line |
| `gb` | 缓冲区选择器 | Buffer Picker (Snacks) |
| `g=` | 格式化缓冲区 | Format Buffer |
| `g.` | 转到最后修改位置 | Go to Last Change |
| `g;` | 转到更早修改位置 | Go to Older Change |
| `g,` | 转到较新修改位置 | Go to Newer Change |

---

### 🔹 `[` / `]` 前缀 — 导航 / Navigation

按下 `[` 或 `]` 后 which-key 显示导航子菜单：

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `[d` / `]d` | 上一个/下一个诊断 | Prev/Next Diagnostic |
| `[e` / `]e` | 上一个/下一个错误 | Prev/Next Error |
| `[w` / `]w` | 上一个/下一个警告 | Prev/Next Warning |
| `[t` / `]t` | 上一个/下一个标签页 | Prev/Next Tab |
| `[b` / `]b` | 上一个/下一个缓冲区 | Prev/Next Buffer |
| `[q` / `]q` | 上一个/下一个 Quickfix | Prev/Next Quickfix |
| `[f` / `]f` | 上一个/下一个文件 | Prev/Next File |
| `[[` / `]]` | 上一个/下一个引用 | Prev/Next Reference (Snacks.words) |
| `[<Space>` / `]<Space>` | 上方/下方插入空行 | Add Blank Line Above/Below |

---

### 🔹 `z` 前缀 — 折叠 / Folding

按下 `z` 后 which-key 显示折叠子菜单：

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `zo` | 展开折叠 | Open Fold |
| `zc` | 关闭折叠 | Close Fold |
| `za` | 切换折叠 | Toggle Fold |
| `zR` | 展开所有折叠 | Open All Folds |
| `zM` | 关闭所有折叠 | Close All Folds |
| `zv` | 展开当前行折叠 | Open Fold for Current Line |
| `zj` / `zk` | 下一个/上一个折叠 | Next/Previous Fold |

---

### 🔹 `<C-w>` 前缀 — 窗口子模式 / Window Sub-mode

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<C-w>h/j/k/l` | 方向移动窗口 | Move Window |
| `<C-w>v` | 垂直分割 | Vertical Split |
| `<C-w>s` | 水平分割 | Horizontal Split |
| `<C-w>c` | 关闭窗口 | Close Window |
| `<C-w>e` ⭐ | 均分窗口 | Equalize Windows |

---

### 🔹 通用快捷键 / General Keymaps

| 按键 Key | 功能 (中文) | Function (English) | 模式 |
|----------|-------------|-------------------|------|
| `<Esc>` ⭐ | 清除搜索高亮 | Clear Search Highlight | n |
| `0` ⭐ | 跳至第一个非空白字符 | First Non-whitespace Char | n |
| `^` ⭐ | 跳至行首第 0 列 | Column 0 (Beginning of Line) | n |
| `<C-h/j/k/l>` | 窗口间移动 | Move Between Windows | n |
| `<C-Up/Down/Left/Right>` | 调整窗口大小 | Resize Windows | n |
| `<C-s>` | 保存文件 | Save File | n, i |
| `<C-/>` | 注释切换 | Toggle Comment | n, x |
| `<C-f>` / `<C-b>` | 向下/向上翻页 | Page Down/Up | n |
| `<C-d>` / `<C-u>` | 向下/向上翻半页 | Half-Page Down/Up | n |

---

### 🔹 补全快捷键 / Completion Keymaps (blink.cmp)

| 按键 Key | 菜单可见时 (Visible) | 菜单不可见时 (Hidden) |
|----------|---------------------|----------------------|
| `<Tab>` ⭐ | 确认当前选中项 (Confirm) | snippet 前进 / AI 接受 / 缩进 |
| `<S-Tab>` ⭐ | 选择上一项 (Select Prev) | snippet 后退 / fallback |
| `<Enter>` | 确认选中 | 换行 |
| `<C-y>` | 选择并确认 | — |
| `<C-n>` / `<C-p>` | 下一项 / 上一项 | — |
| `<C-b>` / `<C-f>` | 文档上/下滚动 | — |
| `<C-Space>` | 手动触发补全 | 手动触发补全 |

---

### 🔹 调试快捷键 / Debug Keymaps (nvim-dap)

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>db` | 断点切换 | Toggle Breakpoint |
| `<leader>dB` | 条件断点 | Conditional Breakpoint |
| `<leader>dc` | 继续执行 | Continue |
| `<leader>do` | 单步跳过 | Step Over |
| `<leader>di` | 单步进入 | Step Into |
| `<leader>dO` | 单步跳出 | Step Out |
| `<leader>dq` | 停止调试 | Terminate Session |
| `<leader>dt` | 调试面板切换 | Toggle DAP UI |
| `<leader>dPt` | 调试当前方法 (Python) | Debug Method (Python) |
| `<leader>dPc` | 调试当前类 (Python) | Debug Class (Python) |

---

### 🔹 测试快捷键 / Test Keymaps (neotest)

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>tt` | 运行最近测试 | Run Nearest Test |
| `<leader>tT` | 运行当前文件测试 | Run Test File |
| `<leader>tr` | 运行全部测试 | Run All Tests |
| `<leader>ts` | 测试摘要 | Test Summary |
| `<leader>to` | 测试输出 | Test Output |

---

### 🔹 Snacks 特殊功能 / Snacks Special Features

| 按键 Key | 功能 (中文) | Function (English) |
|----------|-------------|-------------------|
| `<leader>gb` | Snacks 缓冲区选择器 | Buffer Picker |
| `<leader>gf` | Snacks 文件选择器 | File Picker |
| `<leader>gg` | Snacks Git 浏览器 | Git Browser |
| `<leader>gs` | Snacks 搜索 | Search |
| `<leader>gw` | Snacks Grep | Grep |
| `<leader>z` | Snacks Zen 模式 | Zen Mode |

---

## ⚙️ 配置架构 / Configuration Architecture

```
~/.config/nvim/
├── init.lua                              → 入口: require("config.lazy")
├── lazyvim.json                          → Extras 启用记录
├── lazy-lock.json                        → 插件版本锁 (auto-generated)
├── stylua.toml                           → Lua 格式化: 4空格缩进
└── lua/
    ├── config/
    │   ├── lazy.lua                      → ★ 核心: bootstrap + extras 导入
    │   ├── options.lua                   → Neovim 选项 (4空格缩进/现代UI)
    │   ├── keymaps.lua                   → 全局快捷键覆盖
    │   └── autocmds.lua                  → 自动命令 (RISC-V .s → asm)
    └── plugins/
        ├── lsp.lua                       → ★ LSP 键位覆盖: gd悬浮预览/gD跳转
        ├── cmp.lua                       → ★ 补全: blink.cmp Tab=确认
        ├── indent.lua                    → treesitter 缩进 (C/C++例外)
        ├── python.lua                    → Python: basedpyright + ruff
        └── example.lua.disabled          → 参考代码 (不加载)
```

### 已启用的 LazyVim Extras / Enabled Extras

| Extra | 作用 |
|-------|------|
| `lang.clangd` | C/C++ LSP + clangd_extensions + codelldb |
| `lang.cmake` | CMake LSP + cmake-tools.nvim |
| `lang.go` | Go LSP (gopls) + delve + neotest + golangci-lint |
| `lang.python` | Python LSP (basedpyright) + ruff + venv-selector + neotest |
| `lang.json` | JSON LSP + SchemaStore |
| `ui.smear-cursor` | 光标平滑动画 / Smooth cursor animation |
| `ui.mini-indentscope` | 缩进范围可视化 / Indent scope indicator |

### 语言工具栈 / Language Tool Stack

| 语言 | LSP | Formatter | Linter | Debugger | Test Runner |
|------|-----|-----------|--------|----------|-------------|
| **C/C++** | clangd | clangd | clangd | codelldb | — |
| **Go** | gopls | gofumpt/goimports | golangci-lint | delve | neotest-golang |
| **Python** | basedpyright | ruff_format | ruff | debugpy | neotest-python |

### 本配置自定义覆盖项 / Custom Overrides

| 文件 | 覆盖内容 |
|------|---------|
| `plugins/lsp.lua` | `gd`→悬浮预览, `gD`→直接跳转, `gr`→重命名, `gh`→引用, `K`→圆角hover |
| `plugins/cmp.lua` | blink.cmp: `<Tab>`=确认补全, `<S-Tab>`=上一项 |
| `plugins/indent.lua` | treesitter indent 全局启用, C/C++ 禁用 |
| `plugins/python.lua` | basedpyright 工作区诊断 + 自动导入 + 标准类型检查 |
| `config/keymaps.lua` | `0`/`^` 互换, `<C-w>e`=均分窗口, `<Esc>`=清除高亮 |
| `config/options.lua` | 4空格缩进, scrolloff=8, cursorline行号高亮, signcolumn固定 |
| `config/lazy.lua` | Python LSP 设为 basedpyright (替代 pyright) |

---

## 🛠️ 日常命令 / Daily Commands

| 命令 | 作用 |
|------|------|
| `:Lazy` | 插件管理面板 |
| `:Lazy sync` | 同步安装/更新所有插件 |
| `:LazyExtras` | 浏览/切换 LazyVim Extras |
| `:Mason` | Mason LSP/工具管理 |
| `:LspInfo` | 查看 LSP 客户端状态 |
| `:checkhealth` | 健康检查 |
| `:e $MYVIMRC` | 打开配置文件目录 |

---

## 🎨 主题 / Colorscheme

默认使用 **tokyonight** (LazyVim 内置)。
可通过 `:LazyExtras` 浏览安装 catppuccin 等主题 extra。

---

*最后更新: 2026-06-10 · LazyVim v8 · 基于 Claude Code 审查修复*
