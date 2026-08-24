let b:delimitMate_expand_cr = 2
let b:delimitMate_expand_inside_quotes = 1
let b:delimitMate_expand_space = 0
let b:delimitMate_nesting_quotes = ['`']

" 字下げの設定はここではなく after/ftplugin/markdown.vim にある。このファイル
" より後に読まれる $VIMRUNTIME/ftplugin/markdown.vim が expandtab を立てるので、
" ここに書いても上書きされて効かない。

" `#todo` のような、`#` で始まる分類用のラベル（タグ）に色を付ける。色そのもの
" は plugin.d/kanagawa.rc.lua の overrides で MarkdownTag として定義している。
"
" treesitter のハイライトクエリでは実現できない。markdown_inline の構文木では
" 段落の中身が丸ごと 1 個の inline ノードになり、`#` の 1 文字ぶんしか独立した
" ノードにならないため、ノード単位でしか色を割り当てられないクエリでは `#todo`
" 全体を塗れない。markdown では treesitter ハイライトが有効で 'syntax' は空だが、
" syntax の項目を直接定義すること自体はでき、タグの位置には treesitter の
" キャプチャが無いので上書きもされない。
"
" 何をタグと見なすかは補完側（plugin.d/lsp.d/cmp.rc.lua の markdown_tag ソース）
" にも書いてあり、定義が 2 箇所に分かれている。条件は揃えてあるが、コード
" ブロックの扱いだけは違う。補完側は ``` の中を読み飛ばすのに対し、syntax match
" では行をまたぐ状態を持てないので除外できず、コードブロック内のコメント記号に
" も色が付く。memo 用途では実害がないため許容している。
"
" パターンの条件は、行頭または空白の直後にある `#` で（`C#` や `page#anchor` の
" ような単語途中の `#` を除くため）、そのあとに英数字・`_`・`/`・`-` または
" マルチバイト文字（`[^\x00-\x7f]`）が 1 文字以上続くもの。`#` の直後に空白が来る
" 見出しはこの条件から外れる。パターン自体が `/` を含むので、区切り文字には `,`
" を使っている。
"
" 定義をこの場で実行せず、いったんイベントループに戻してから行っているのは、
" FileType の処理の中で nvim-treesitter が vim.treesitter.start() を呼び、その中で
" 'syntax' が空にされるため。'syntax' を設定すると syn clear が走るので、ftplugin
" の時点で定義しても消えてしまう（after/ftplugin に置いても同じく消える）。
" vim.schedule() で FileType の処理が一通り終わったあとまで遅らせると残る。
"
" 遅らせるぶん、コールバックが動くときにはカレントバッファが別のものに変わって
" いる可能性があるので、bufnr を捕まえて nvim_buf_call でそのバッファに入り直す。
" `:e` などで再読み込みされたときに同じ項目が二重に定義されないよう、先に消す。
lua << EOF
local bufnr = vim.api.nvim_get_current_buf()
vim.schedule(function()
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd([[silent! syntax clear MarkdownTag]])
		vim.cmd([[syntax match MarkdownTag ,\%(^\|\s\)\zs#\%([[:alnum:]_/-]\|[^\x00-\x7f]\)\+,]])
	end)
end)
EOF
