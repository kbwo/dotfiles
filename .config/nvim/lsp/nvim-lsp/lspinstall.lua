require'lspinstall'.setup()

local required_servers = {
  'go',
  'angular',
  'bash',
  'cpp',
  'css',
  'dockerfile',
  'graphql',
  'html',
  'json',
  'kotlin',
  'lua',
  'php',
  'python',
  'rust',
  'typescript',
  'vim',
  'vue',
  'yaml',
  'deno',
  'efm',
}

local installed_servers = require'lspinstall'.installed_servers()
for _, server in pairs(required_servers) do
  if not vim.tbl_contains(installed_servers, server) then
    require'lspinstall'.install_server(server)
  end
end

local servers = require'lspinstall'.installed_servers()
for _, server in pairs(servers) do
  require'lspconfig'[server].setup{}
end

require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end
