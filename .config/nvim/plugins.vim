" plugin
call plug#begin(expand('~/.vim/plugged'))
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
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
" Plug 'lambdalisue/gin.vim'
Plug 'lambdalisue/guise.vim'
" Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install()}}
Plug 'machakann/vim-sandwich'
" Plug 'kbwo/ddu-source-coc'
Plug 'Shougo/ddu.vim'
Plug 'Shougo/ddu-ui-ff', { 'commit': '2b9f9f9c36ee734dc13659c2829a2893b716ef5a'}
Plug 'Shougo/ddu-source-file_rec'
Plug 'Shougo/ddu-filter-matcher_substring'
Plug 'Shougo/ddu-kind-file'
Plug 'shun/ddu-source-rg'
Plug 'yuki-yano/ddu-filter-fzf'
Plug 'shun/ddu-source-buffer'
Plug 'matsui54/ddu-source-file_external'
Plug 'dhruvasagar/vim-table-mode', { 'for': ['markdown']}
Plug 'udalov/kotlin-vim'
Plug 'kchmck/vim-coffee-script'
Plug 'thosakwe/vim-flutter'
Plug 'lambdalisue/fern.vim'
Plug 'Bakudankun/BackAndForward.vim'
Plug 'skanehira/denops-docker.vim'
" Plug 'github/copilot.vim'
Plug '~/go/src/github.com/kbwo/rustrekker/rs_module'
Plug 'Exafunction/codeium.vim'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'lewis6991/gitsigns.nvim'
if has('nvim')
  Plug 'nvim-lua/plenary.nvim'
  Plug 'rebelot/kanagawa.nvim'

  Plug 'antoinemadec/FixCursorHold.nvim'
  Plug 'phaazon/hop.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  " Plug 'nvim-treesitter/nvim-treesitter-context'

  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'WhoIsSethDaniel/mason-tool-installer.nvim'
  Plug 'neovim/nvim-lspconfig'

  Plug 'simrat39/rust-tools.nvim'
  Plug 'mhartington/formatter.nvim'
  Plug 'j-hui/fidget.nvim', { 'tag': 'legacy' }

  Plug 'mfussenegger/nvim-dap'

	Plug 'ray-x/navigator.lua'
	Plug 'ray-x/guihua.lua', {'do': 'cd lua/fzy && make' }

  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
  Plug 'hrsh7th/cmp-nvim-lsp-document-symbol'
  Plug 'hrsh7th/cmp-emoji'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-calc'
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
  Plug 'uga-rosa/cmp-dictionary'

  Plug 'uga-rosa/ddu-source-lsp'

  Plug 'lukas-reineke/indent-blankline.nvim'
  Plug 'rest-nvim/rest.nvim'
  if executable("yarn")
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
  else
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
  endif

else
  Plug 'ghifarit53/tokyonight-vim'
endif

call plug#end()

let g:vsnip_snippet_dir = "~/dotfiles/.config/nvim/snippets"
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

function! s:load_configurations(directory) abort
  for path in glob(a:directory . '/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
  if(has('nvim'))
    for path in glob(a:directory . '/*.lua', 1, 1, 1)
      execute printf('source %s', fnameescape(path))
    endfor
  end
endfunction

call s:load_configurations('~/dotfiles/.config/nvim/plugin.d')
call s:load_configurations('~/dotfiles/.config/nvim/lsp.d')

