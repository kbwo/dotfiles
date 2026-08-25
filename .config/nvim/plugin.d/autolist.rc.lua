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

-- カーソル行が属するリスト（入れ子の項目や、マーカーの無い継続行＝項目の続き
-- として字下げされた行も含めた、ひとつながりの範囲）を調べる。markdown でない
-- ときや、カーソルがリストの行にないときは nil。
--
-- 「どこまでが 1 つのリストか」の判定は autolist が持っているもの
-- （autolist.block）をそのまま使い、ここには書かない。コードブロックや引用の
-- 中での振る舞いを、ほかのリスト操作と食い違わせないため。
local function cursor_list()
  local bufnr = vim.api.nvim_get_current_buf()
  local opts = require('autolist.config').get(bufnr)
  if not opts then
    return nil
  end
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local block = require('autolist.block').find(bufnr, lnum, opts)
  if not block then
    return nil
  end
  return { bufnr = bufnr, opts = opts, lnum = lnum, block = block }
end

-- 指定した行へ飛ぶ。飛ぶ前の位置を jumplist に積んで <C-o> で戻れるようにし、
-- 行頭の空白の後ろ（本文の先頭）にカーソルを置く。G などの行単位の移動と同じ。
local function jump_to_line(lnum)
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  vim.cmd('normal! ^')
end

-- カーソルのあるリストの最後の行へ移動する。項目を書き足すときに末尾へ下りる
-- 操作で、`}`（次の空行まで）や `G`（ファイル末尾）では行き過ぎたり足りなかったり
-- するため。
local function goto_list_last_line()
  local list = cursor_list()
  if not list then
    return
  end
  jump_to_line(list.block.last)
end

-- カーソル行をリストの末尾に複製して、そこへ移動する。doing list で「今日も
-- 続ける」項目を、済んだ行を履歴として上に残したまま下へ持っていくための操作。
--
-- 複製する行がチェック済みのチェックボックス項目のときは、末尾に置くほうだけ
-- チェックを外し、行末の終了時刻 (end: ...) も落とす。これからやり直す項目で
-- あって、済んだ印も終えた時刻も前の行のものだから。元の行はそのまま残す。
--
-- 連番は振り直さない。番号付きのリストでは複製した行と番号が重なるので、
-- 揃えたいときは <leader>lr（連番の振り直し）を明示的に呼ぶ。
local function copy_line_to_list_end()
  local list = cursor_list()
  if not list then
    return
  end
  local lineparse = require('autolist.line')
  local line = vim.api.nvim_buf_get_lines(list.bufnr, list.lnum - 1, list.lnum, false)[1]
  local parsed = lineparse.parse(line, list.opts)
  if parsed.checkbox and parsed.checkbox ~= list.opts.checkbox.unchecked then
    parsed.checkbox = list.opts.checkbox.unchecked
    -- 終了時刻の書き方を知っているのは base.vim なので、そこの関数を通して
    -- 落とす。ここにパターンを書き写さない。
    parsed.content = vim.fn.MemoClearEndTime(parsed.content)
    line = lineparse.render(parsed)
  end
  local at = list.block.last
  vim.api.nvim_buf_set_lines(list.bufnr, at, at, false, { line })
  jump_to_line(at + 1)
end

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

    -- o / O で行を足したときも、改行と同じようにマーカーを置く。下に足した
    -- ときは番号が 1 つ進み、上に足したときは元の項目の番号を引き継ぐ。
    -- autolist が扱わない行では nil が返るので、素の o / O をそのまま流す。
    -- <CR> と違って <Plug> を展開する必要がないため remap は要らない。
    vim.keymap.set('n', 'o', function()
      return require('autolist').o() or 'o'
    end, { buffer = event.buf, expr = true, desc = 'autolist: 下に項目を足す' })
    vim.keymap.set('n', 'O', function()
      return require('autolist').shift_o() or 'O'
    end, { buffer = event.buf, expr = true, desc = 'autolist: 上に項目を足す' })

    -- normal モードの <CR> でチェックボックスを切り替える。
    -- 直接 toggle_checkbox() を呼ばず base.vim の MemoToggleCheckbox() を通すのは、
    -- ~/memo 配下では切り替えと同時に終了時刻を行末へ書き足すため。
    -- チェックボックスを持たない行では偽が返るので、そのときは <CR> 本来の
    -- 動作（次の行の先頭へ）を流す。'n' フラグは再マップしない指定で、これが
    -- ないとこのマッピング自身に戻って無限に回る。
    vim.keymap.set('n', '<CR>', function()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      if vim.fn.MemoToggleCheckbox(lnum, lnum) == 0 then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
      end
    end, { buffer = event.buf, desc = 'autolist: チェックボックス切り替え' })

    -- 連番の振り直しは明示操作のときだけ走る（自動整形はしない）。
    map('n', '<leader>lr', '<Cmd>AutolistRenumber<CR>', '連番を振り直す')
    -- こちらも終了時刻の記録を通したいので MemoToggleCheckbox() を呼ぶ。
    map('n', '<leader>lc', '<Cmd>call MemoToggleCheckbox(line("."), line("."))<CR>', 'チェックボックス切り替え')
    map('x', '<leader>lc', [[:<C-u>call MemoToggleCheckbox(line("'<"), line("'>"))<CR>]], 'チェックボックス切り替え（範囲）')
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

    -- リストの末尾へ移動。下向きの移動である j に合わせる。
    map('n', '<leader>lj', goto_list_last_line, 'リストの最後の行へ移動')
    -- この行をリストの末尾へ複製して移動。コピーなので y。
    map('n', '<leader>ly', copy_line_to_list_end, 'この行をリストの末尾に複製して移動')
  end,
})
