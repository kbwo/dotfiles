local mc = require("multicursor-nvim")
mc.setup()

 -- Add cursors above/below the main cursor.
vim.keymap.set({"n", "v"}, "<up>", function() mc.addCursor("k") end)
vim.keymap.set({"n", "v"}, "<down>", function() mc.addCursor("j") end)

-- Add a cursor and jump to the next word under cursor.
vim.keymap.set({"n", "v"}, "<c-j>", function() mc.addCursor("*") end)
vim.keymap.set({"n", "v"}, "<c-k>", function() mc.prevCursor() end)

-- Jump to the next word under cursor but do not add a cursor.
vim.keymap.set({"n", "v"}, "<Leader>q", function() mc.skipCursor("*") end)

-- Rotate the main cursor.
vim.keymap.set({"n", "v"}, "<left>", mc.nextCursor)
vim.keymap.set({"n", "v"}, "<right>", mc.prevCursor)

-- Delete the main cursor.
vim.keymap.set({"n", "v"}, "<leader>x", mc.deleteCursor)

vim.keymap.set("n", "<esc>", function()
    if not mc.cursorsEnabled() then
        mc.enableCursors()
    elseif mc.hasCursors() then
        mc.clearCursors()
    else
        -- Default <esc> handler.
    end
end)

-- Align cursor columns.
vim.keymap.set("n", "<leader>aa", mc.alignCursors)

-- Split visual selections by regex.
vim.keymap.set("v", "S", mc.splitCursors)

-- Append/insert for each line of visual selections.
vim.keymap.set("v", "I", mc.insertVisual)
vim.keymap.set("v", "A", mc.appendVisual)

-- match new cursors within visual selections by regex.
vim.keymap.set("v", "M", mc.matchCursors)

-- Rotate visual selection contents.
vim.keymap.set("v", "<leader>at", function() mc.transposeCursors(1) end)
vim.keymap.set("v", "<leader>aT", function() mc.transposeCursors(-1) end)

-- Customize how cursors look.
vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
vim.api.nvim_set_hl(0, "MultiCursorVisual", {   fg = '#FFFFFF', bg = '#b26e29', bold = true   })
vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })

