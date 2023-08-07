local saga = require 'lspsaga'
saga.setup({
  ui = {
    border = 'rounded',
  },
  symbol_in_winbar = {
    enable = false
  },
  lightbulb = {
    enable = false
  },
  outline = {
    auto_close = true,
    win_position = 'bottom',
    layout = 'float'
  },
  diagnostic = {
      show_code_action = false,
      max_height = 0.8,
      keys = {
          quit = {'q', '<ESC>'}
      },
    },
    symbol_in_winbar = {
      enable = false,
    },
    callhierarchy = {
      enable = false,
    },
})
