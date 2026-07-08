-- Define markdown-related filetypes and git commit
local markdown_filetypes = { "markdown", "md", "text", "txt", "tex", "pandoc", "rst", "org", "norg", "gitcommit" }

-- Create autocommand group for autolist keymaps
vim.api.nvim_create_augroup("AutolistKeymaps", { clear = true })

local list_patterns = {
  neorg_1 = "%-",
  neorg_2 = "%-%-",
  neorg_3 = "%-%-%-",
  neorg_4 = "%-%-%-%-",
  neorg_5 = "%-%-%-%-%-",
  unordered = "[-+*]", -- - + *
  digit = "%d+[.)]",   -- 1. 2. 3.
  ascii = "%a[.)]",    -- a) b) c)
  latex_item = "\\item",
}
require("autolist").setup({
  cycle = { -- Cycles the list type in order
    "-",    -- whatever you put here will match the first item in your list
    "*",    -- for example if your list started with a `-` it would go to `*`
    "1.",   -- this says that if your list starts with a `*` it would go to `1.`
    "1)",   -- this all leverages the power of recalculate.
    "a)",   -- i spent many hours on that function
  },
  lists = { -- configures list behaviours
    -- Each key in lists represents a filetype.
    -- The value is a table of all the list patterns that the filetype implements.
    -- See how to define your custom list below in the readme.
    -- You must put the file name for the filetype, not the file extension
    -- To get the "file name", it is just =:set filetype?= or =:se ft?=.
    markdown = {
      list_patterns.unordered,
      list_patterns.digit,
      list_patterns.ascii, -- for example this specifies activate the ascii list
    },
    text = {
      list_patterns.unordered,
      list_patterns.digit,
      list_patterns.ascii,
    },
    norg = {
      list_patterns.neorg_1,
      list_patterns.neorg_2,
      list_patterns.neorg_3,
      list_patterns.neorg_4,
      list_patterns.neorg_5,
    },
    tex = { list_patterns.latex_item },
    plaintex = { list_patterns.latex_item },
  },
})

vim.api.nvim_create_autocmd("FileType", {
  group = "AutolistKeymaps",
  pattern = markdown_filetypes,
  callback = function()
    local opts = { buffer = true }

    -- Insert mode mappings
    vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>", opts)
    vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>", opts)
    -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>", opts) -- an example of using <c-t> to indent
    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", opts)

    -- Normal mode mappings
    vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
    vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)
    vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr>", opts)
    vim.keymap.set("n", "<leader>l<Space>", "<cmd>AutolistRecalculate<cr>", opts)

    -- Cycle list types with dot-repeat
    vim.keymap.set("n", "<A-l>", require("autolist").cycle_next_dr, { buffer = true, expr = true })
    -- vim.keymap.set("n", "<leader>lp", require("autolist").cycle_prev_dr, { buffer = true, expr = true })

    -- Indentation and deletion mappings
    vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>", opts)
    vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>", opts)
    vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>", opts)
    vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>", opts)
  end,
})
