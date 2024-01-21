local util = require("conform.util")
local rustfmt = require("conform.formatters.rustfmt")
rustfmt.args = function()
  return { "--edition", "2021", "--emit", "stdout" }
end
local eslint_d = require("conform.formatters.eslint_d")
eslint_d.cwd = util.root_file({
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.json",
  "eslintrc.js",
  "eslintrc.json",
})

local is_available = function(name, bufnr)
  return require("conform").get_formatter_info(name, bufnr).available
end

local eslint_or_prettier_or_lsp = { "eslint_d", "prettierd", "prettier", "lsp" }
local stylua_or_lsp = { "stylua", "lsp" }

require("conform").setup({
  log_level = vim.log.levels.DEBUG,
  formatters_by_ft = {
    javascript = eslint_or_prettier_or_lsp,
    typescriptreact = eslint_or_prettier_or_lsp,
    typescript = eslint_or_prettier_or_lsp,
    json = eslint_or_prettier_or_lsp,
    css = eslint_or_prettier_or_lsp,
    html = eslint_or_prettier_or_lsp,
    lua = { "stylua", "lsp" },
    php = { "csharpier", "lsp" },
    rust = { "rustfmt" },
  },
  format_on_save = {
    -- I recommend these options. See :help conform.format for details.
    lsp_fallback = true,
    timeout_ms = 500,
  },
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })