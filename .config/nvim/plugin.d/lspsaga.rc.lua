local saga = require 'lspsaga'
saga.setup({
  outline = {
    auto_close = true,
    win_position = 'bottom'
  },
  diagnostic = {
        max_height = 0.8,
        keys = {
            quit = {'q', '<ESC>'}
        },
        diagnostic_only_current = true
    },
})
