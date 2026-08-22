-- autolist: markdown のリストの体裁（マーカー・連番・インデント・
-- チェックボックス）を保つ。runtimepath は plugins.vim で追加している。
--
-- このプラグインはキーマップを一切定義しないので、割り当てはここで行う。
-- 各機能は「自分が処理したか」を返すので、処理しなかったときの動作は
-- 呼び出し側が決められる。
--
-- <Tab> / <S-Tab> はここには書かない。nvim-cmp が自分のマッピング表で
-- 握っており、ここでバッファローカルに張ると markdown で cmp の候補選択が
-- 効かなくなるため。cmp 側（lsp.d/cmp.rc.lua）から autolist を呼んでいる。

require('autolist').setup()

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  group = vim.api.nvim_create_augroup('autolist_rc', { clear = true }),
  callback = function(event)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = 'autolist: ' .. desc })
    end

    -- <CR> は delimitMate が <Plug>delimitMateCR を張っている。autolist が
    -- 扱わない行（リスト以外、継続行、コードブロック内）では delimitMate に
    -- そのまま渡す。expr マッピングは既定で戻り値を再マップしないので、
    -- <Plug> を展開させるために remap = true が要る。
    vim.keymap.set('i', '<CR>', function()
      return require('autolist').cr() or '<Plug>delimitMateCR'
    end, { buffer = event.buf, expr = true, remap = true, desc = 'autolist: 改行' })

    -- normal モードの <CR> でチェックボックスを切り替える。チェックボックスを
    -- 持たない行では toggle_checkbox() が偽を返すので、そのときは <CR> 本来の
    -- 動作（次の行の先頭へ）を流す。'n' フラグは再マップしない指定で、これが
    -- ないとこのマッピング自身に戻って無限に回る。
    vim.keymap.set('n', '<CR>', function()
      if not require('autolist').toggle_checkbox() then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
      end
    end, { buffer = event.buf, desc = 'autolist: チェックボックス切り替え' })

    -- 連番の振り直しは明示操作のときだけ走る（自動整形はしない）。
    map('n', '<leader>lr', '<Cmd>AutolistRenumber<CR>', '連番を振り直す')
    map('n', '<leader>lc', '<Cmd>AutolistToggleCheckbox<CR>', 'チェックボックス切り替え')
    map('x', '<leader>lc', ':AutolistToggleCheckbox<CR>', 'チェックボックス切り替え（範囲）')
    -- マーカーの種類（チェックボックスの有無を含む）を並び順で回す。
    -- 小文字が次の種別、大文字が前の種別。u は同じ階層の兄弟だけ、i は親子も
    -- 含めたブロック全体。入れ子では階層ごとに違うマーカーにしたいことがある
    -- ため、範囲を選べるようにしてある。
    map('n', '<A-u>', '<Cmd>AutolistCycleMarkersSiblings<CR>', '種別を次へ（兄弟のみ）')
    map('n', '<A-U>', '<Cmd>AutolistCycleMarkersSiblings!<CR>', '種別を前へ（兄弟のみ）')
    map('n', '<A-i>', '<Cmd>AutolistCycleMarkersBlock<CR>', '種別を次へ（親子も含める）')
    map('n', '<A-I>', '<Cmd>AutolistCycleMarkersBlock!<CR>', '種別を前へ（親子も含める）')

    -- 字下げだけで階層を書いた平文をリストにする。書き換える範囲を推測しない
    -- 作りなので、normal は 1 行、visual は選択範囲に対して働く。
    map('n', '<leader>ll', '<Cmd>AutolistMakeList<CR>', 'この行をリストにする')
    vim.keymap.set('x', '<leader>ll', ':AutolistMakeList<CR>', {
      buffer = event.buf,
      desc = 'autolist: 選択範囲をリストにする',
    })

    -- normal モードからのインデント操作。insert 側は cmp 経由の <Tab>。
    map('n', '<leader>l.', '<Cmd>AutolistIndent<CR>', '1 段下げる')
    map('n', '<leader>l,', '<Cmd>AutolistDedent<CR>', '1 段上げる')
  end,
})
