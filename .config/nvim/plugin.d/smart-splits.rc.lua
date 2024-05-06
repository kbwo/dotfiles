require('smart-splits').setup({
  resize_mode = {
    -- key to exit persistent resize mode
    quit_key = '<ESC>',
    -- keys to use for moving in resize mode
    -- in order of left, down, up' right
    resize_keys = { 'h', 'j', 'k', 'l' },
    -- set to true to silence the notifications
    -- when entering/exiting persistent resize mode
    silent = true,
    -- must be functions, they will be executed when
    -- entering or exiting the resize mode
    hooks = {
      on_enter = nil,
      on_leave = nil,
    },
  },
})

vim.keymap.set('n', '<C-a>', function() require('smart-splits').start_resize_mode() end)
vim.keymap.set('n', '<C-w>h', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-w>j', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-w>k', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-w>l', require('smart-splits').move_cursor_right)
vim.keymap.set('n', '<C-w>p', require('smart-splits').move_cursor_previous)
