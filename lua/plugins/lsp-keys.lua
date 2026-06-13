-- VSCode 模式：LSP 由 VSCode 原生扩展处理，
-- 这里定义的所有快捷键（gd/gi/gr/gh/K）在 VSCode 中均冲突，
-- 因此完全跳过此文件。
if vim.g.vscode then return {} end

-- ============================================================
-- LSP Key Overrides — peek .c implementation
-- ============================================================
-- gd  → 浮窗预览 .c 实现（definition only, 优先 .c, 不跳转）
-- gD  → 跳转到定义
-- gi  → 浮窗预览实现
-- gI  → 跳转到实现
-- gr  → 重命名   gh → 引用   K → 悬浮文档
-- ============================================================

local function normalize(result)
  if not result or vim.isempty(result) then
    return {}
  end
  -- Single Location or LocationLink
  if result.uri then
    return { { uri = result.uri, range = result.targetSelectionRange or result.targetRange or result.range } }
  end
  if result.targetUri then
    return { { uri = result.targetUri, range = result.targetSelectionRange or result.targetRange } }
  end
  -- Array
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

---Prefer .c file from location list, fallback to first
local function prefer_dot_c(locs)
  for _, loc in ipairs(locs) do
    local fname = vim.uri_to_fname(loc.uri)
    if fname:match("%.c$") then
      return loc
    end
  end
  return locs[1]
end

---Peek location in floating window
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
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=/usr/bin/riscv64-linux-gnu-gcc",
          },
        },
        ["*"] = {
          keys = {

            -- gd: Jump to definition (reliable, goes to .c)
            {
              "gd",
              function()
                vim.lsp.buf.definition()
              end,
              desc = "Goto Definition",
            },

            -- gi: Peek implementation (float preview)
            {
              "gi",
              function()
                local client = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })[1]
                if not client then
                  vim.notify("No clangd client found", vim.log.levels.WARN)
                  return
                end
                local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
                client.request("textDocument/implementation", params, function(err, result)
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

            -- gI: Jump to implementation
            {
              "gI",
              function()
                vim.lsp.buf.implementation()
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
