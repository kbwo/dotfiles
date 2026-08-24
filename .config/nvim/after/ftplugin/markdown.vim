" 字下げはスペースではなくタブを使う。
"
" after 側に置いているのは、$VIMRUNTIME/ftplugin/markdown.vim が expandtab を
" 立てるため。ftplugin/markdown.vim（after でないほう）はそれより先に読まれる
" ので、あちらに書くと上書きされて効かない。
setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=4

nnoremap <buffer> <silent> <Leader>mp :MarkdownPreview<CR>
nmap <buffer> <silent> <A--> yi-
