if empty(glob('~/.config/nvim/skk/SKK-JISYO.L'))
  silent !curl -fLo ~/.config/nvim/skk/SKK-JISYO.L --create-dirs
        \ http://openlab.jp/skk/skk/dic/SKK-JISYO.L
endif

imap <C-j> <Plug>(skkeleton-toggle)
cmap <C-j> <Plug>(skkeleton-toggle)

function! s:skkeleton_init() abort
  call skkeleton#config({
        \ 'globalDictionaries': [['~/.config/nvim/skk/SKK-JISYO.L', 'euc-jp']],
        \ 'userDictionary': '~/.config/nvim/skk/user.dict',
        \ 'markerHenkan': '»',
        \ 'markerHenkanSelect': '«',
        \ 'showCandidatesCount': 1,
        \ })
  call skkeleton#register_kanatable('rom', {
        \ 'pc': ['・'],
        \ })
endfunction
augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END

function! s:skkeleton_show_mode() abort
  let l:mode = skkeleton#mode()
  if l:mode ==# ''
    return
  endif
  let l:label = get({'hira':'かな','kata':'カナ','hankata':'ｶﾅ','zenkaku':'全角','abbrev':'abbrev'}, l:mode, l:mode)
  set noshowmode
  redraw
  echohl ModeMsg
  echo '-- INSERT (' . l:label . ') --'
  echohl None
endfunction

function! s:skkeleton_clear_mode() abort
  set showmode
  echo ''
  redraw
endfunction

let g:skkeleton_enabled = v:false
augroup skkeleton-mode-display
  autocmd!
  autocmd User skkeleton-enable-post,skkeleton-mode-changed
        \ let g:skkeleton_enabled = v:true | call s:skkeleton_show_mode()
  autocmd User skkeleton-disable-post
        \ let g:skkeleton_enabled = v:false | call s:skkeleton_clear_mode()
augroup END
