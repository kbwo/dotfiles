source ~/dotfiles/.config/nvim/vim-settings.vim

" this setting must write before polyglot is loaded
let g:polyglot_disabled = ['markdown']

source ~/dotfiles/.config/nvim/plugins.vim

let g:vim_json_syntax_conceal = 0
let g:vim_vue_plugin_load_full_syntax = 1

source ~/dotfiles/.config/nvim/plugins/colors.vim
source ~/dotfiles/.config/nvim/plugins/ultisnips.vim
source ~/dotfiles/.config/nvim/plugins/quickrun.vim
source ~/dotfiles/.config/nvim/plugins/emmet.vim
source ~/dotfiles/.config/nvim/plugins/visual-multi.vim
source ~/dotfiles/.config/nvim/plugins/supertab.vim
source ~/dotfiles/.config/nvim/plugins/defx.vim
source ~/dotfiles/.config/nvim/plugins/easymotion.vim
source ~/dotfiles/.config/nvim/plugins/memo.vim
source ~/dotfiles/.config/nvim/plugins/tcomment.vim
source ~/dotfiles/.config/nvim/plugins/eskk.vim
source ~/dotfiles/.config/nvim/plugins/denite.vim
source ~/dotfiles/.config/nvim/plugins/gina.vim
source ~/dotfiles/.config/nvim/plugins/tagalong.vim
source ~/dotfiles/.config/nvim/plugins/winresizer.vim
source ~/dotfiles/.config/nvim/lsp/coc/coc.vim

" if(has('nvim'))
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspconfig.lua
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspinstall.lua
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/compe.lua
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspsaga.lua
  " source ~/dotfiles/.config/nvim/lsp/nvim-lsp/lspsaga.vim
  " :luafile ~/dotfiles/.config/nvim/lsp/nvim-lsp/formatter.lua
  " source ~/dotfiles/.config/nvim/lsp/nvim-lsp/compe.vim
  " source ~/dotfiles/.config/nvim/lsp/nvim-lsp/ale.vim
" end
