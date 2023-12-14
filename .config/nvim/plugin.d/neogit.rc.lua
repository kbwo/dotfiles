-- init.lua
local neogit = require('neogit')
neogit.setup {
}

-- set mapping of :Neogit cwd=%:p:h<CR>
vim.keymap.set('n', 'gns', ':Neogit cwd=%:p:h<CR>')
