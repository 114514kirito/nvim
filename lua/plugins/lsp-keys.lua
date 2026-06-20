-- VSCode 模式：LSP 由 VSCode 原生扩展处理
if vim.g.vscode then return {} end

-- ============================================================
-- LSP Key Overrides — 通用 preview/peek
-- ============================================================
-- gd  → 跳转到定义
-- gi  → 浮窗预览实现（所有 LSP 通用，不限于 clangd）
-- gI  → 跳转到实现
-- gr  → 重命名   gh → 引用   K → 悬浮文档
-- ============================================================

local function normalize(result)
  if not result or vim.isempty(result) then
    return {}
  end
  if result.uri then
    return { { uri = result.uri, range = result.targetSelectionRange or result.targetRange or result.range } }
  end
  if result.targetUri then
    return { { uri = result.targetUri, range = result.targetSelectionRange or result.targetRange } }
  end
  if result[1] then
    local out = {}
    for _, item in ipairs(result) do
      if item.uri then
        out[#out + 1] = { uri = item.uri, range = item.targetSelectionRange or item.targetRange or item.range }
      elseif item.targetUri then
        out[#out + 1] = { uri = item.targetUri, range = item.targetSelectionRange or item.targetRange }
      end
    end
    return out
  end
  return {}
end

local function peek_one(loc)
  vim.lsp.util.preview_location(loc, {
    border = "rounded",
    max_width = math.floor(vim.o.columns * 0.65),
    max_height = math.floor(vim.o.lines * 0.80),
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    opts_extend = { "servers.*.keys" },
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            -- 允许查询所有 gcc-compatible driver 以获取多平台系统头文件
            -- (RISC-V / x86 / ARM 等), 单个项目可通过 .clangd 文件覆盖
            "--query-driver=**",
          },
        },
        ["*"] = {
          keys = {
            -- gd: Jump to definition (auto-center)
            {
              "gd",
              function()
                vim.lsp.buf.definition()
                vim.cmd("normal! zz")
              end,
              desc = "Goto Definition",
            },

            -- gi: Peek implementation (all LSPs, not just clangd)
            {
              "gi",
              function()
                local params = vim.lsp.util.make_position_params(0)
                vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result)
                  if err then
                    vim.notify("LSP error: " .. vim.inspect(err), vim.log.levels.ERROR)
                    return
                  end
                  local locs = normalize(result)
                  if #locs == 0 then
                    vim.notify("No implementation found", vim.log.levels.WARN)
                  elseif #locs == 1 then
                    peek_one(locs[1])
                  else
                    Snacks.picker.lsp_implementations()
                  end
                end)
              end,
              desc = "Peek Implementation",
            },

            -- gI: Jump to implementation (auto-center)
            {
              "gI",
              function()
                vim.lsp.buf.implementation()
                vim.cmd("normal! zz")
              end,
              desc = "Goto Implementation",
            },

            -- gr: Rename
            {
              "gr",
              function()
                vim.lsp.buf.rename()
              end,
              desc = "Rename",
              nowait = true,
            },

            -- gh: References
            {
              "gh",
              function()
                vim.lsp.buf.references()
              end,
              desc = "References",
            },

            -- K: Enhanced hover with border
            {
              "K",
              function()
                vim.lsp.buf.hover({
                  border = "rounded",
                  max_width = math.floor(vim.o.columns * 0.5),
                  max_height = math.floor(vim.o.lines * 0.4),
                })
              end,
              desc = "Enhanced Hover",
            },
          },
        },
      },
    },
  },
}
