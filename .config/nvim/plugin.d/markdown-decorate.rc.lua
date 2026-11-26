-- markdown を、notes（~/notes のメモ、notes/lua/notes/decorate.lua）と同じ見た目で
-- 表示する。色は notes の highlight group（notes/lua/notes/theme.lua の Notes*）を
-- そのまま使う。
--
-- notes と違い、記号はどの行でも隠さない（ファイルの文字はすべてそのまま見える）。
-- notes がページの 1 行目（タイトル）の上下に引く線も引かない。見出しの下の線は引く。
--
-- どこが見出しやコードブロックかは treesitter の構文木から読む。行を正規表現で
-- 見ると、コードブロックの中の `#` を見出しと取り違えるため。

local ns = vim.api.nvim_create_namespace("markdown_decorate")

local block_query = vim.treesitter.query.parse("markdown", [[
  (atx_heading) @heading
  (setext_heading) @heading
  (fenced_code_block) @code
  (fenced_code_block_delimiter) @fence
  (info_string) @fence
  (block_quote) @quote
  (block_quote_marker) @quote_marker
  [(list_marker_minus) (list_marker_plus) (list_marker_star) (list_marker_dot) (list_marker_parenthesis)] @list_marker
  (task_list_marker_unchecked) @check
  (task_list_marker_checked) @checked
]])

local inline_query = vim.treesitter.query.parse("markdown_inline", [[
  (strong_emphasis) @NotesStrong
  (emphasis) @NotesItalic
  (strikethrough) @NotesStrike
  (code_span) @code_span
]])

local function hl(buf, r1, c1, r2, c2, group, priority)
  pcall(vim.api.nvim_buf_set_extmark, buf, ns, r1, c1, { end_row = r2, end_col = c2, hl_group = group, priority = priority })
end

-- 見出しの ▌ の本数。`#` の数と同じ（notes の中の `#` 見出しも同じ。notes/lua/notes/decorate.lua の walk）。
local function heading_bars(node)
  local marker = node:child(0)
  local t = marker and marker:type() or ""
  local level = tonumber(t:match("^atx_h(%d)_marker$"))
  if not level then
    -- 下線式の見出し: `===` は `#`、`---` は `##` と同じ
    local underline = node:child(node:child_count() - 1)
    level = underline and underline:type() == "setext_h1_underline" and 1 or 2
  end
  return level
end

local function render(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then
    return
  end
  parser:parse(true)
  parser:for_each_tree(function(tree, ltree)
    local lang = ltree:lang()
    local query = lang == "markdown" and block_query or lang == "markdown_inline" and inline_query or nil
    if not query then
      return
    end
    for id, node in query:iter_captures(tree:root(), buf) do
      local name = query.captures[id]
      local r1, c1, r2, c2 = node:range()
      if name == "heading" then
        -- 下線式の見出しは下の行（=== / ---）まで含む。▌ と線は見出しの文字の行と、その最後の行に付ける。
        local last = c2 == 0 and r2 - 1 or r2
        local line = vim.api.nvim_buf_get_lines(buf, last, last + 1, false)[1] or ""
        hl(buf, r1, c1, last, #line, "NotesHeading")
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, r1, c1, { virt_text = { { ("▌"):rep(heading_bars(node)) .. " ", "NotesHeading" } }, virt_text_pos = "inline", right_gravity = false })
        local first = vim.api.nvim_buf_get_lines(buf, r1, r1 + 1, false)[1] or ""
        local from = (" "):rep(vim.fn.strdisplaywidth(first:sub(1, c1)))
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, last, 0, { virt_lines = { { { from }, { ("─"):rep(300), "NotesHeadingRule" } } } })
      elseif name == "code" then
        local last = c2 == 0 and r2 - 1 or r2
        for row = r1, last do
          pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, 0, { line_hl_group = "NotesCodeGround" })
        end
      elseif name == "fence" then
        hl(buf, r1, c1, r2, c2, "NotesCodeHeader")
      elseif name == "quote" then
        -- 中の強調などの色が勝つよう、ほかより低くする（extmark の既定は 4096、treesitter は 100）。
        hl(buf, r1, c1, r2, c2, "NotesQuote", 200)
      elseif name == "quote_marker" then
        hl(buf, r1, c1, r2, c2, "NotesQuoteBar")
      elseif name == "list_marker" then
        hl(buf, r1, c1, r2, c2, "NotesIndentDot")
      elseif name == "check" or name == "checked" then
        hl(buf, r1, c1, r2, c2, "NotesCheckBox")
        local text = name == "checked" and node:next_named_sibling()
        if text then
          local t1, u1, t2, u2 = text:range()
          hl(buf, t1, u1, t2, u2, "NotesChecked")
        end
      elseif name == "code_span" then
        -- 背景は ` と ` のあいだだけに付ける（notes のインラインコードと同じ）
        local open, close = node:child(0), node:child(node:child_count() - 1)
        if open and close and open:id() ~= close:id() then
          local _, _, o2, oc = open:range()
          local cr, cc = close:range()
          hl(buf, o2, oc, cr, cc, "NotesCodeGround")
          hl(buf, o2, oc, cr, cc, "NotesCode")
        end
      else
        hl(buf, r1, c1, r2, c2, name)
      end
    end
  end)
end

local group = vim.api.nvim_create_augroup("markdown_decorate", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(ev)
    local buf = ev.buf
    -- ファイルだけに付ける。LSP のホバーや補完の説明の小窓（buftype=nofile の一時
    -- バッファ）は数行しかなく、見出しの下の線が読める行を減らすため。
    if vim.bo[buf].buftype ~= "" then
      return
    end
    local pending = false
    vim.api.nvim_clear_autocmds({ group = group, buffer = buf })
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      group = group,
      buffer = buf,
      callback = function()
        if pending then
          return
        end
        pending = true
        vim.schedule(function()
          pending = false
          render(buf)
        end)
      end,
    })
    render(buf)
  end,
})
