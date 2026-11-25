-- lua/notes/paste.lua against the stderr-blog code it ports (tools/cosense/editor/input.js
-- `transformPaste`): the same texts pasted at the same places of the same pages, by both.
-- The texts are hand-picked ones (Markdown, URLs of every kind, plain lines) and the
-- pages under a directory, each pasted whole. Exits non-zero, listing the first differences.
--
-- usage: nvim -l tests/paste_diff.lua <stderr-blog repo> [pages dir]
local here = vim.fs.dirname(vim.fs.normalize(arg[0]))
vim.opt.rtp:prepend(vim.fs.dirname(here))
local paste = require("notes.paste")

local repo = assert(arg[1], "usage: nvim -l paste_diff.lua <stderr-blog repo> [pages dir]")
local pages_dir = arg[2] or (repo .. "/src/content/pages")

-- Where to paste: a page, and the cursor's place in it as (line, the text before the cursor on it).
local PAGE = table.concat({
  "タイトル",
  "ふつうの行",
  "    ",
  " 箇条書き",
  "> 引用の行",
  " > 字下げした引用",
  "code:main.ts",
  " const a = 1;",
  " const b = 2;",
  "table:表",
  " a\tb",
  "$ ls -la",
  "[リンク] と `コード` の行",
  "1. 番号",
  "",
}, "\n")
local PLACES = {
  { 1, "タイトル" },
  { 2, "ふつうの行" },
  { 2, "ふつう" },
  { 2, "" },
  { 3, "  " },
  { 3, "    " },
  { 4, " 箇条書き" },
  { 5, "> 引用の行" },
  { 6, " > 字下げした引用" },
  { 7, "code:main.ts" },
  { 8, " const a = 1;" },
  { 9, " " },
  { 11, " a\tb" },
  { 12, "$ ls" },
  { 13, "[" },
  { 13, "[リンク" },
  { 13, "[リンク] と `" },
  { 14, "1. 番号" },
  { 15, "" },
}

local TEXTS = {
  "ひとこと",
  "1 行目\n2 行目",
  "1 行目\r\n2 行目\r\n",
  "a\n\n\nb",
  "# 見出し\n## 小見出し\n本文 **太字** と ~~消し~~\n- 項目\n  - 子の項目\n    * 孫\n1. 番号\n+ 足し",
  "| a | b |\n|---|:-:|\n| 1 | 2 |\n\n| c |\n| 3 |",
  "```ts\nconst x = 1;\n\n```\n```\nplain\n```",
  "- [リンク](https://example.com/a) と ![画像](https://example.com/b.png)\n- x",
  "> 引用\n- 箇条書き",
  "code:x\n- y",
  "https://example.com/a.png",
  "https://example.com/A.JPEG?x=1",
  "https://example.com/movie.mp4",
  "https://www.youtube.com/watch?v=abc",
  "https://youtu.be/abc",
  "https://gyazo.com/0123456789abcdef0123456789abcdef",
  "https://open.spotify.com/track/1",
  "https://www.google.com/maps/place/Tokyo+Tower/@35.6585805,139.7454329,17z/data=x",
  "https://www.google.co.jp/maps/@-35.5,-139.25,12.5z",
  "https://example.com/%E3%81%82%20b%2Fc",
  "https://example.com/%E3%81",
  "https://example.com/plain",
  "http://localhost:39321/__cosense/Neovim_%E3%81%AE%E8%A8%AD%E5%AE%9A",
  "http://localhost:39321/__cosense/search?q=x",
  "http://localhost:39321/__cosense/",
  "https://example.com/a.png\n\nhttps://example.com/b\n",
  " https://example.com/a.png ",
  "https://example.com/a.png と文字",
  "",
  "\n",
}

local function split_at(lnum, before)
  local lines = vim.split(PAGE, "\n", { plain = true })
  local head = table.concat(vim.list_slice(lines, 1, lnum - 1), "\n") .. (lnum > 1 and "\n" or "") .. before
  return lines, head, PAGE:sub(#head + 1)
end

local cases = {}
for _, place in ipairs(PLACES) do
  for _, text in ipairs(TEXTS) do
    cases[#cases + 1] = { place = place, text = text }
  end
end
-- Every page, pasted whole on an ordinary line, on an indent-only line and into the code block.
for _, file in ipairs(vim.fn.globpath(pages_dir, "**/*.txt", false, true)) do
  local text = table.concat(vim.fn.readfile(file, "b"), "\n")
  for _, place in ipairs({ PLACES[2], PLACES[5], PLACES[8], PLACES[11] }) do
    cases[#cases + 1] = { place = place, text = text, file = file }
  end
end

local input = {}
for i, c in ipairs(cases) do
  local _, head, tail = split_at(c.place[1], c.place[2])
  input[i] = vim.json.encode({ before = head, after = tail, text = c.text })
end
local result = vim.system({ "node", here .. "/paste_reference.mjs", repo }, { stdin = table.concat(input, "\n") .. "\n", text = true }):wait()
assert(result.code == 0, result.stderr)
local want = vim.split(vim.trim(result.stdout), "\n", { plain = true })
assert(#want == #cases, ("input.js answered %d of %d cases"):format(#want, #cases))

local failures = {}
for i, c in ipairs(cases) do
  local lines = split_at(c.place[1], c.place[2])
  local got = paste.transform(lines, c.place[1], #c.place[2], c.text)
  local expected = vim.json.decode(want[i])
  if got ~= expected and #failures < 10 then
    failures[#failures + 1] = ("paste of %s at line %d after %q\n  input.js: %s\n  lua:      %s"):format(
      c.file or vim.inspect(c.text), c.place[1], c.place[2], vim.inspect(expected), vim.inspect(got))
  end
end
if #failures > 0 then
  io.stderr:write(table.concat(failures, "\n") .. "\n")
  os.exit(1)
end
print(("paste.lua agrees with input.js on %d pastes"):format(#cases))
