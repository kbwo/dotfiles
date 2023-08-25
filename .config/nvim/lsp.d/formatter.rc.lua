-- Prettier function for formatter
local prettier = function()
  return {
    exe = "prettier",
    args = {
      "--config-precedence",
      "prefer-file",
      -- you can add more global setup here
      "--stdin-filepath",
      vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
    },
    stdin = true,
    try_node_modules = true,
  }
end

require('formatter').setup({
  logging = true,
  log_level = vim.log.levels.DEBUG,
  filetype = {
    typescriptreact = { prettier },
    javascriptreact = { prettier },
    javascript = { prettier },
    typescript = { prettier },
    json = { prettier },
    jsonc = { prettier },
    html = { prettier },
    css = { prettier },
    scss = { prettier },
    -- graphql = { prettier },
    -- markdown = { prettier },
    -- vue = { prettier },
    -- astro = { prettier },
    -- yaml = { prettier },
    rust = {
      -- Rustfmt
      function()
        return {
          exe = "rustfmt",
          args = { "--emit=stdout" },
          stdin = true
        }
      end
    },
    lua = {
      -- luafmt
      function()
        return {
          exe = "luafmt",
          args = { "--indent-count", 2, "--stdin" },
          stdin = true
        }
      end
    }
  }
})
vim.api.nvim_exec([[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.jsx,*.ts,*.tsx,*.rs,*.lua,*.css,*.scss :FormatWrite
augroup END
]], true)
