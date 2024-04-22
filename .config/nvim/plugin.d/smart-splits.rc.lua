require('smart-splits').setup({
  resize_mode = {
    -- key to exit persistent resize mode
    quit_key = '<CR>',
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
