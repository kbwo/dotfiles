local saga = require 'lspsaga'
saga.init_lsp_saga {
  use_saga_diagnostic_sign = true,
  error_sign = 'E',
  warn_sign = 'W',
  hint_sign = 'H',
  infor_sign = 'I',
  dianostic_header_icon = '',
  code_action_icon = '',
  finder_definition_icon = '',
  finder_reference_icon = '',
  definition_preview_icon = '',
  finder_action_keys = {
    open = '<CR>', vsplit = '<Leader>v',split = '<Leader>s',quit = 'q',scroll_down = '<C-n>', scroll_up = '<C-p>'
  }
}
