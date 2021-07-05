set rtp +=~/.vim
set rtp+=/path/to/lldb.nvim
set rtp+=~/src/vim/dps-heloworld
source ~/dotfiles/.config/nvim/vim-settings.vim

if has('vim_starting')
  set nocompatible
endif

" this setting must write before polyglot is loaded
let g:polyglot_disabled = ['markdown']

source ~/dotfiles/.config/nvim/plugins.vim

let g:vim_json_syntax_conceal = 0
let g:vim_vue_plugin_load_full_syntax = 1

source ~/dotfiles/.config/nvim/ultisnips.vim
source ~/dotfiles/.config/nvim/quickrun.vim
source ~/dotfiles/.config/nvim/emmet.vim
source ~/dotfiles/.config/nvim/colors.vim
source ~/dotfiles/.config/nvim/visual-multi.vim
source ~/dotfiles/.config/nvim/supertab.vim
source ~/dotfiles/.config/nvim/defx.vim
source ~/dotfiles/.config/nvim/easymotion.vim
source ~/dotfiles/.config/nvim/memo.vim
source ~/dotfiles/.config/nvim/tcomment.vim
source ~/dotfiles/.config/nvim/eskk.vim
source ~/dotfiles/.config/nvim/denite.vim
source ~/dotfiles/.config/nvim/gina.vim
source ~/dotfiles/.config/nvim/tagalong.vim
source ~/dotfiles/.config/nvim/winresizer.vim
source ~/dotfiles/.config/nvim/ale.vim
" source ~/dotfiles/.config/nvim/coc.vim

" autocmd User EasyMotionPromptBegin silent! CocDisable
" autocmd User EasyMotionPromptEnd   silent! CocEnable

" autocmd CursorHold * silent call CocActionAsync('highlight')

" autocmd  User eskk-enable-pre  silent! CocDisable
" autocmd  User eskk-disable-post silent! CocEnable

if(has('nvim'))
  :luafile ~/dotfiles/.config/nvim/lspconfig.lua
  :luafile ~/dotfiles/.config/nvim/lspinstall.lua
  :luafile ~/dotfiles/.config/nvim/compe.lua
  :luafile ~/dotfiles/.config/nvim/lspsaga.lua
  source ~/dotfiles/.config/nvim/lspsaga.vim
  :luafile ~/dotfiles/.config/nvim/formatter.lua
end
