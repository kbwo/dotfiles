-- ~/notes: a card list of the notes, search and page operations (notes/lua/notes/).
vim.opt.runtimepath:append(vim.fn.expand("~/dotfiles/.config/nvim/notes"))
-- `require` returns a module it loaded before without reading the file again, so :Sov
-- (re-sourcing init.vim) would keep running the old code unless that copy is dropped.
for name in pairs(package.loaded) do
  if name == "notes" or name:find("^notes%.") then
    package.loaded[name] = nil
  end
end
require("notes").setup()
if vim.v.vim_did_enter == 1 then -- re-sourced by :Sov, not at startup
  require("notes").reopen_pages()
end
