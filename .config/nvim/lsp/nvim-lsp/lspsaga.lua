local saga = require 'lspsaga'
saga.init_lsp_saga {
  finder_action_keys = {
    open = '<CR>', vsplit = '<Leader>v',split = '<Leader>s',quit = 'q',scroll_down = '<C-n>', scroll_up = '<C-p>'
  }
}
