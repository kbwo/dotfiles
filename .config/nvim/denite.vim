call denite#custom#alias('source', 'file/rec/git', 'file/rec')
call denite#custom#var('file/rec/git', 'command',
      \ ['rg', '--files', '--hidden', '--glob', '!.git', '--color', 'never'])
call denite#custom#var('file/rec', 'command',
      \ ['rg', '--files', '--hidden','--no-ignore', '--glob', '!.git', '--color', 'never'])
call denite#custom#var('grep', {
      \ 'command': ['rg', '--threads', '1'],
      \ 'recursive_opts': [],
      \ 'final_opts': [],
      \ 'separator': ['--'],
      \ 'default_opts': ['--smart-case', '--vimgrep', '--no-heading'],
      \ })
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])
call denite#custom#var('buffer', 'date_format', '')
call denite#custom#filter('matcher/clap',
      \ 'clap_path', expand('~/.vim/plugged/vim-clap'))
call denite#custom#source('file/rec', 'matchers', [
      \ 'matcher/clap',
      \ ])
call denite#custom#source('file/rec/git', 'matchers', [
      \ 'matcher/clap',
      \ ])

nmap <c-p> :Denite file/rec/git<CR>
nmap <Leader>p :Denite file/rec<CR>
nmap <Leader>d :Denite directory_rec<CR>
nmap <Leader>r :<C-u>Denite grep:. -no-empty<CR>
nmap <Leader>gb :<C-u>DeniteGitto gitto/branch<CR>

autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
        \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> <Leader>t
        \ denite#do_map('do_action', 'tabopen')
  nnoremap <silent><buffer><expr> <Leader>v
        \ denite#do_map('do_action', 'vsplit')
  nnoremap <silent><buffer><expr> <Leader>s
        \ denite#do_map('do_action', 'split')
  nnoremap <silent><buffer><expr> <Leader>d
        \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
        \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
        \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
        \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> m
        \ denite#do_map('toggle_select').'j'
endfunction
