-- ~/notes: a card list of the notes, search and page operations (notes/lua/notes/).
vim.opt.runtimepath:append(vim.fn.expand("~/dotfiles/.config/nvim/notes"))
require("notes").setup()
