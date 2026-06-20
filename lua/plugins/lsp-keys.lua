-- VSCode 模式：LSP 由 VSCode 原生扩展处理
if vim.g.vscode then return {} end

-- ============================================================
-- LSP 配置：clangd 命令行 + 独有的 LSP keymaps
-- gd / gI / K / gr 等由 LazyVim 原生提供，这里不覆盖
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
            "--query-driver=**",
          },
        },
        ["*"] = {
          keys = {
            -- gi: 浮窗预览实现（LazyVim 未提供此功能）
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

            -- gh: 查看引用（LazyVim 用 gR，这里补充一个备选）
            {
              "gh",
              function()
                vim.lsp.buf.references()
              end,
              desc = "References",
            },
          },
        },
      },
    },
  },
}
