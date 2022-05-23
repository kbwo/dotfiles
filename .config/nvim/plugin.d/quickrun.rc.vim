nnoremap <Leader>go :QuickRun<CR>
nnoremap <C-U>qr :QuickRun<CR>
let g:quickrun_config={'*': {'split': ''}}
let g:quickrun_config.cpp = {
      \   'command': 'g++',
      \   'cmdopt': '-std=c++11'
      \ }
