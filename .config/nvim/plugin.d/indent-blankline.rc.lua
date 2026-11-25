vim.opt.list = true
vim.opt.listchars:append("space:⋅")

-- notes のページ（notes/lua/notes/decorate.lua）は、インデントを自分で点として描くので、
-- 縦線のガイドがその点に重ならないよう除く。リストの値は既定の除外先に足される。
require("ibl").setup({
	exclude = { filetypes = { "notes" } },
})
