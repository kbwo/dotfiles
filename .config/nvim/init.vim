source ~/dotfiles/.config/nvim/base.vim

" this setting must write before polyglot is loaded
let g:polyglot_disabled = ['markdown']

source ~/dotfiles/.config/nvim/installer.vim
source ~/dotfiles/.config/nvim/plugins.vim

let g:vim_json_syntax_conceal = 0
let g:vim_vue_plugin_load_full_syntax = 1

source ~/dotfiles/.config/nvim/plugin-config/colors.vim
source ~/dotfiles/.config/nvim/plugin-config/ultisnips.vim
source ~/dotfiles/.config/nvim/plugin-config/quickrun.vim
source ~/dotfiles/.config/nvim/plugin-config/emmet.vim
source ~/dotfiles/.config/nvim/plugin-config/visual-multi.vim
source ~/dotfiles/.config/nvim/plugin-config/supertab.vim
source ~/dotfiles/.config/nvim/plugin-config/defx.vim
source ~/dotfiles/.config/nvim/plugin-config/memo.vim
source ~/dotfiles/.config/nvim/plugin-config/tcomment.vim
source ~/dotfiles/.config/nvim/plugin-config/eskk.vim
source ~/dotfiles/.config/nvim/plugin-config/denite.vim
source ~/dotfiles/.config/nvim/plugin-config/gina.vim
source ~/dotfiles/.config/nvim/plugin-config/tagalong.vim
source ~/dotfiles/.config/nvim/plugin-config/winresizer.vim
source ~/dotfiles/.config/nvim/lsp/coc/coc.vim

if(has('nvim'))
source ~/dotfiles/.config/nvim/plugin-config/hop.lua
  " :luafile ~/dotfiles/.config/nvim/plugin-config/treesitter.lua
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspconfig.lua
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspinstall.lua
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/compe.lua
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspsaga.lua
  " source ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspsaga.vim
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/formatter.lua
  " source ~/dotfiles/.config/nvim/lsp/nvim-lsp/compe.vim
  " source ~/dotfiles/.config/nvim/lsp/nvim-lsp/ale.vim
end
