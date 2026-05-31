packadd vim-jetpack

call jetpack#begin(expand('~/.vim/jetpack'))
Jetpack 'tani/vim-jetpack', {'opt': 1, 'commit': '56558f41c2148120b94526e5c8e46f172864b990'} "bootstrap

Jetpack 'nvim-lua/plenary.nvim', {'commit': '74b06c6c75e4eeb3108ec01852001636d85a932b'}
Jetpack 'nvim-lualine/lualine.nvim', {'commit': '131a558e13f9f28b15cd235557150ccb23f89286'}
Jetpack 'tpope/vim-surround', {'commit': '3d188ed2113431cf8dac77be61b842acb64433d9'}
Jetpack 'mattn/emmet-vim', {'commit': '92ef2f74f4093edc99db5e9e4cf7e40116a85bd6'}
Jetpack 'JoosepAlviste/nvim-ts-context-commentstring', {'commit': '6141a40173c6efa98242dc951ed4b6f892c97027'}
Jetpack 'numToStr/Comment.nvim', {'commit': 'e30b7f2008e52442154b66f7c519bfd2f1e32acb'}
Jetpack 'Raimondi/delimitMate', {'commit': 'becbd2d353a2366171852387288ebb4b33a02487'}
Jetpack 'tpope/vim-dadbod', {'commit': '6d1d41da4873a445c5605f2005ad2c68c99d8770'}
Jetpack 'kristijanhusak/vim-dadbod-ui', {'commit': '07e92e22114cc5b1ba4938d99897d85b58e20475'}
" Jetpack 'tyru/eskk.vim'
Jetpack 'sontungexpt/url-open', {'commit': 'dce2a9bc51e4885ea80ca03da5b4d0f719aaf820'}
Jetpack 'simeji/winresizer', {'commit': '299076f7f79e2e2f7706b2dfacbb3c074ce53257'}
Jetpack 'windwp/nvim-ts-autotag', {'commit': '88c1453db4ba7dd24131086fe51fdf74e587d275'}
Jetpack 'vim-denops/denops.vim', {'commit': '1df7a022d6e9cb3f6a3db43235e0f174ccd79e03'}
Jetpack 'kbwo/vim-gin', { 'branch': 'fix/wworktree', 'commit': 'd93a18d36f027775ce441e25bd39f5579463f57a'}
" Jetpack 'lambdalisue/gin.vim'
Jetpack 'machakann/vim-sandwich', {'commit': '74cf93d58ccc567d8e2310a69860f1b93af19403'}
Jetpack 'lambdalisue/fern.vim', {'commit': 'b4520a50d8df51969838d35eb07f797e2785b234'}
Jetpack 'lambdalisue/vim-fern-hijack', {'commit': 'f65524899231b15528066744e714fb344abf0892'}
Jetpack 'Bakudankun/BackAndForward.vim', {'commit': '09c067217d408b99e8b2b2ccc4170ac32daef934'}
Jetpack 'nvim-lua/plenary.nvim', {'commit': '74b06c6c75e4eeb3108ec01852001636d85a932b'}
Jetpack 'Exafunction/codeium.vim', { 'branch': 'main', 'commit': '3c0a4f8a7be75113a6e19be13b7cc37210d6e26a' }
Jetpack 'echasnovski/mini.diff', {'commit': '117c301374ab8546891e2b34f63885ea83527432'}
Jetpack 'NvChad/nvim-colorizer.lua', {'commit': '5cfe7fffbd01e17b3c1e14af85d5febdef88bd8c'}
Jetpack 'rebelot/kanagawa.nvim', {'commit': 'bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3'}
Jetpack 'smoka7/hop.nvim', {'commit': '707049feaca9ae65abb3696eff9aefc7879e66aa'}
Jetpack 'yorickpeterse/nvim-window', {'commit': '48e44d492d2adaf9aac72a0f4ff21d6caae1b6a2'}
Jetpack 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'branch': 'master', 'commit': 'cf12346a3414fa1b06af75c79faebe7f76df080a'}
Jetpack 'apple/pkl-neovim', {'commit': '6067ca1424d851a3ce93b0429e23e3e13a8ee6e6'}
" Jetpack 'shellRaining/hlchunk.nvim'
Jetpack 'lukas-reineke/indent-blankline.nvim', {'commit': 'd28a3f70721c79e3c5f6693057ae929f3d9c0a03'}
Jetpack 'andrewferrier/debugprint.nvim', {'commit': '54c74749fb299bafbae818f775243be776663420'}
Jetpack 'akinsho/toggleterm.nvim', {'commit': '9a88eae817ef395952e08650b3283726786fb5fb'}
Jetpack 'jedrzejboczar/possession.nvim', {'commit': 'fbea95b16c284727bc8deff2c3780a73efcdaca6'}
Jetpack 'chenasraf/text-transform.nvim', {'commit': '335b3ad36d8b276b7b56028108d32b1c91f26d76'}

" Jetpack 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
"
Jetpack 'kbwo/vim-shareedit', {'commit': 'fa8f369904fa0bf6bc7686b62a83ebb60c6d1553'}

" ddu
" Jetpack 'kbwo/ddu-source-coc'
Jetpack 'Shougo/ddu.vim', {'commit': '823f029b9c4fe4df98d2a3209f2a1a35937858a0'}
Jetpack 'Shougo/ddu-ui-ff', {'commit': '861fd4e2491ab66d486ba97a515d2138418b40fb'}
Jetpack 'Shougo/ddu-source-file_rec', {'commit': '81fb15d9fa49e36de528a784ef0e1655a137d273'}
Jetpack 'Shougo/ddu-filter-matcher_substring', {'commit': '661e9383d9cdd7e4f07e5c3f4ce7e675e8cb38b3'}
Jetpack 'Shougo/ddu-kind-file', {'commit': '162dcd350cbea0cfa4556121ae6ee9ef4d7eeb71'}
Jetpack 'kbwo/ddu-source-rg', { 'branch': 'no-hl', 'commit': 'c5083c657dbd9f8eaa8072b41ca268ab2ed8218e' }
Jetpack 'yuki-yano/ddu-filter-fzf', {'commit': 'e968510d192260264cbd99431a2060fe9eb5f0ae'}
Jetpack 'shun/ddu-source-buffer', {'commit': '1238c09bccb1d4814f36d83ef864cbb2b2ca9895'}
Jetpack 'matsui54/ddu-source-file_external', {'commit': '62b0fb4623ad07d549e8269ef4f51f09cf1b7500'}
Jetpack 'kbwo/ddu-source-lsp', { 'branch': 'fix/method-support', 'commit': '79f7061d54af6b071f58300cde07bbaa365d5a90' }
Jetpack 'kamecha/ddu-source-window', {'commit': '308730e870978d4d29b2fea79332b3c3cfd15a8c'}
Jetpack 'nekowasabi/ddu-source-git-worktree', {'commit': '45bb22e71e383eecd18ff2599f3e70b4d4c995e0'}

Jetpack 'jake-stewart/multicursor.nvim', {'commit': '704b99f10a72cc05d370cfeb294ff83412a8ab55'}

" formatter
Jetpack 'stevearc/conform.nvim', {'commit': 'dca1a190aa85f9065979ef35802fb77131911106'}
Jetpack 'kbwo/indent-o-matic', {'commit': '987dd8e05b4aa5b09e12be221b09d71dd0014306'}

" neovim lsp
Jetpack 'neovim/nvim-lspconfig', {'commit': '36bb266b006b570889f092d57dffad635741c122'}
Jetpack 'williamboman/mason.nvim', {'commit': 'e54f5bf5f12c560da31c17eee5b3e1bd369f3ff9'}
Jetpack 'williamboman/mason-lspconfig.nvim', {'commit': 'eaa34887d444cb002e1b165fac399ae4bbc771f7'}
Jetpack 'WhoIsSethDaniel/mason-tool-installer.nvim', {'commit': '443f1ef8b5e6bf47045cb2217b6f748a223cf7dc'}
Jetpack 'neovim/nvim-lspconfig', {'commit': '36bb266b006b570889f092d57dffad635741c122'}
Jetpack 'kyoh86/climbdir.nvim', {'commit': '30231f24b9262ffb13fd278c3ad29821045937c4'}
" language specific improvement
Jetpack 'mrcjkb/rustaceanvim', {'commit': 'f2f0c1231a5b019dbc1fd6dafac1751c878925a3'}
Jetpack 'pmizio/typescript-tools.nvim', {'commit': 'c2f5910074103705661e9651aa841e0d7eea9932'}
" Jetpack 'kbwo/testing-ls.nvim'
" Jetpack 'copilotlsp-nvim/copilot-lsp'
Jetpack 'folke/sidekick.nvim', {'commit': '208e1c5b8170c01fd1d07df0139322a76479b235'}

" neovim lsp ui
" dependency
Jetpack 'MunifTanjim/nui.nvim', {'commit': 'de740991c12411b663994b2860f1a4fd0937c130'}
" notification
Jetpack 'j-hui/fidget.nvim', {'commit': '889e2e96edef4e144965571d46f7a77bcc4d0ddf'}
" Jetpack 'rcarriga/nvim-notify'
" code action
Jetpack 'aznhe21/actions-preview.nvim', {'commit': '0ac9c2aa3cfc8c885321c0862b50b6b1c3392405'}
Jetpack 'Sebastian-Nielsen/better-type-hover', {'commit': 'c91a5406775f9379a1abc16a869935beba13cfc2'}
" outline
Jetpack 'stevearc/aerial.nvim', {'commit': '645d108a5242ec7b378cbe643eb6d04d4223f034'}

Jetpack 'hrsh7th/nvim-cmp', {'commit': 'a1d504892f2bc56c2e79b65c6faded2fd21f3eca'}
Jetpack 'hrsh7th/vim-vsnip', {'commit': '9bcfabea653abdcdac584283b5097c3f8760abaa'}
Jetpack 'hrsh7th/cmp-vsnip', {'commit': '989a8a73c44e926199bfd05fa7a516d51f2d2752'}
Jetpack 'hrsh7th/vim-vsnip-integ', {'commit': 'c7c93934dece8315db3649bdc6898b76358a8b8d'}
Jetpack 'hrsh7th/cmp-nvim-lsp', {'commit': 'cbc7b02bb99fae35cb42f514762b89b5126651ef'}
Jetpack 'hrsh7th/cmp-nvim-lsp-signature-help', {'commit': 'fd3e882e56956675c620898bf1ffcf4fcbe7ec84'}
Jetpack 'hrsh7th/cmp-nvim-lsp-document-symbol', {'commit': 'f94f7ba948e32cd302caba1c2ca3f7c697fb4fcf'}
Jetpack 'hrsh7th/cmp-emoji', {'commit': 'e8398e2adf512a03bb4e1728ca017ffeac670a9f'}
Jetpack 'hrsh7th/cmp-path', {'commit': 'c642487086dbd9a93160e1679a1327be111cbc25'}
Jetpack 'hrsh7th/cmp-buffer', {'commit': 'b74fab3656eea9de20a9b8116afa3cfc4ec09657'}
Jetpack 'hrsh7th/cmp-calc', {'commit': '5947b412da67306c5b68698a02a846760059be2e'}
Jetpack 'f3fora/cmp-spell', {'commit': '694a4e50809d6d645c1ea29015dad0c293f019d6'}
" dictionary 使っている状態でバッファが増えると何故かterminalがめちゃくちゃ重くなる
" Jetpack 'uga-rosa/cmp-dictionary'
Jetpack 'kristijanhusak/vim-dadbod-completion', {'commit': 'a8dac0b3cf6132c80dc9b18bef36d4cf7a9e1fe6'}
Jetpack 'ray-x/cmp-treesitter', {'commit': '958fcfa0d8ce46d215e19cc3992c542f576c4123'}

" Jetpack 'copilotlsp-nvim/copilot-lsp'

" Jetpack 'Shougo/ddc.vim'
" Jetpack 'Shougo/ddc-ui-native'
" Jetpack 'Shougo/ddc-source-around'
" Jetpack 'Shougo/ddc-filter-matcher_head'
" Jetpack 'Shougo/ddc-filter-sorter_rank'
" Jetpack 'Shougo/ddc-source-lsp'
" Jetpack 'LumaKernel/ddc-source-file'
" Jetpack 'tani/ddc-fuzzy'
" Jetpack 'matsui54/denops-popup-preview.vim'
" Jetpack 'matsui54/ddc-source-buffer'
" Jetpack 'gamoutatsumi/ddc-emoji'
" Jetpack 'Shougo/ddc-source-input'
" Jetpack 'matsui54/ddc-source-dictionary'
" Jetpack 'kristijanhusak/vim-dadbod-completion'
"

Jetpack 'anuvyklack/middleclass', {'commit': '9fab4d5bca67262614960960ca35c4740eb2be2c'}
Jetpack 'anuvyklack/windows.nvim', {'commit': 'c7492552b23d0ab30325e90b56066ec51242adc8'}

Jetpack 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'], 'commit': 'a923f5fc5ba36a3b17e289dc35dc17f66d0548ee'}

Jetpack 'monaqa/dial.nvim', {'commit': 'f2634758455cfa52a8acea6f142dcd6271a1bf57'}
Jetpack 'petertriho/nvim-scrollbar', {'commit': 'f8e87b96cd6362ef8579be456afee3b38fd7e2a8'}
Jetpack 'kbwo/list.nvim', {'commit': '0e9a261e6fc64e753c2e41c3b905dabe8079a22a'}

Jetpack 'kana/vim-textobj-user', {'commit': '41a675ddbeefd6a93664a4dc52f302fe3086a933'}
Jetpack 'coachshea/vim-textobj-markdown', {'commit': '9cba182b2c30afc982ace0deb1200cc394799799'}

call jetpack#end()

function! LoadConfigurations(directory) abort
  for path in glob(a:directory . '/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
  if(has('nvim'))
    for path in glob(a:directory . '/*.lua', 1, 1, 1)
      execute printf('source %s', fnameescape(path))
    endfor
  end
endfunction

call LoadConfigurations('~/dotfiles/.config/nvim/plugin.d')


autocmd BufEnter term:// startinsert
