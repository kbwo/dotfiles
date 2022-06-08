" plugin
call plug#begin(expand('~/.vim/plugged'))
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'ervandew/supertab'
Plug 'mattn/emmet-vim'
Plug 'SirVer/ultisnips'
Plug 'tomtom/tcomment_vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'glidenote/memolist.vim'
Plug 'tyru/eskk.vim'
Plug 'tyru/open-browser.vim'
Plug 'simeji/winresizer'
Plug 'AndrewRadev/tagalong.vim'
Plug 'vim-denops/denops.vim'
Plug 'lambdalisue/gina.vim'
Plug 'lambdalisue/guise.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install()}}
Plug 'machakann/vim-sandwich'
Plug 'kbwo/ddu-source-coc'
Plug 'Shougo/ddu.vim'
Plug 'Shougo/ddu-ui-ff'
Plug 'Shougo/ddu-source-file_rec'
Plug 'Shougo/ddu-filter-matcher_substring'
Plug 'Shougo/ddu-kind-file'
Plug 'shun/ddu-source-rg'
Plug 'yuki-yano/ddu-filter-fzf'
Plug 'shun/ddu-source-buffer'
Plug 'matsui54/ddu-source-file_external'
Plug 'dhruvasagar/vim-table-mode', { 'for': ['markdown']}
Plug 'wakatime/vim-wakatime'
Plug 'udalov/kotlin-vim'
Plug 'kchmck/vim-coffee-script'
Plug 'thosakwe/vim-flutter'
Plug 'lambdalisue/fern.vim'
Plug 'Bakudankun/BackAndForward.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'skanehira/denops-docker.vim'
" Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
if has('nvim')
  Plug 'antoinemadec/FixCursorHold.nvim'
  Plug 'phaazon/hop.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'lukas-reineke/indent-blankline.nvim'
  Plug 'rebelot/kanagawa.nvim'
  if executable("yarn")
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
  else
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
  endif

  " ===== nvim-lsp ==========
  " Plug 'neovim/nvim-lspconfig'
  " Plug 'kabouzeid/nvim-lspinstall'
  " Plug 'hrsh7th/nvim-compe'
  " Plug 'glepnir/lspsaga.nvim'
  " Plug 'mhartington/formatter.nvim'
  " ===== nvim-lsp ==========
else
  Plug 'roxma/nvim-yarp'
  Plug 'ghifarit53/tokyonight-vim'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()

function! s:load_configurations() abort
  for path in glob('~/dotfiles/.config/nvim/plugin.d/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
  if(has('nvim'))
    for path in glob('~/dotfiles/.config/nvim/plugin.d/*.lua', 1, 1, 1)
      execute printf('source %s', fnameescape(path))
    endfor
  end
endfunction

call s:load_configurations()
