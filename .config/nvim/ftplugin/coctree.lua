-- Create an augroup for the Coctree width settings
vim.api.nvim_create_augroup("CoctreeWidth", { clear = true })

-- Function to set the width of the coctree window
local function set_coctree_width()
  if vim.bo.filetype == "coctree" then
    local width = math.floor(vim.o.columns * 0.20) -- 30% of the current window width
    vim.cmd("vertical resize " .. width)
  end
end

-- Autocommand to set width when the filetype is coctree
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = "CoctreeWidth",
  pattern = "coctree",
  callback = set_coctree_width,
})

-- Autocommand to adjust the width when the Vim window is resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = "CoctreeWidth",
  callback = set_coctree_width,
})

-- Autocommand to adjust the width whenever a buffer is opened
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = "CoctreeWidth",
  callback = set_coctree_width,
})
