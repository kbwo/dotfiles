local home = vim.fn.expand("~")

require('copilot').setup({
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>"
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.4
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    hide_during_completion = true,
    debounce = 75,
    keymap = {
      accept = "<c-e><c-n>",
      accept_word = false,
      accept_line = false,
      next = "<C-e><c-l>",
      prev = "<C-e><c-h>",
      dismiss = "<C-e><c-e>",
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
  copilot_node_command = home .. '/.local/share/mise/installs/node/18/bin/node',
  server_opts_overrides = {},
})
require("CopilotChat").setup {
  debug = true, -- Enable debugging
  proxy = nil, -- [protocol://]host[:port] Use this proxy
  allow_insecure = false, -- Allow insecure server connections

  yank_diff_register = '"', -- Allow overriding the register for yanking diffs

  model = 'gpt-4o', -- GPT model to use, 'gpt-3.5-turbo', 'gpt-4', or 'gpt-4o'
  temperature = 0.1, -- GPT temperature

  question_header = '## User ', -- Header to use for user questions
  answer_header = '## Copilot ', -- Header to use for AI answers
  error_header = '## Error ', -- Header to use for errors
  separator = '───', -- Separator to use in chat

  show_folds = false, -- Shows folds for sections in chat
  highlight_selection = true, -- Highlight selection in the source buffer when in the chat window
  window = {
    layout = 'replace', -- 'vertical', 'horizontal', 'float', 'replace'
    width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
    height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
    -- Options below only apply to floating windows
    relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
    border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
    row = nil, -- row position of the window, default is centered
    col = nil, -- column position of the window, default is centered
    title = 'Copilot Chat', -- title of chat window
    footer = nil, -- footer of chat window
    zindex = 1, -- determines if window is on top or below other floating windows
  },

  -- default mappings
  mappings = {
    complete = {
      detail = 'Use @<Tab> or /<Tab> for options.',
      insert ='<Tab>',
    },
    close = {
      normal = 'q',
      insert = '<C-c>'
    },
    reset = {
      normal ='<C-l>',
      insert = '<C-l>'
    },
    submit_prompt = {
      normal = '<CR>',
      insert = '<C-s>'
    },
    accept_diff = {
      normal = '<C-y>',
      insert = '<C-y>'
    },
    yank_diff = {
      normal = 'gy',
    },
    show_diff = {
      normal = 'gd'
    },
    show_system_prompt = {
      normal = 'gp'
    },
    show_user_selection = {
      normal = 'gs'
    },
  },
}

vim.api.nvim_set_keymap('n', '<Leader>cc', '<Cmd>lua require("CopilotChat").toggle()<CR>', { noremap = true, silent = true })

-- Define an autocmd in Lua to set conceallevel to 0 for Markdown and Copilot Chat files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "copilot-chat" },
    callback = function()
        vim.opt_local.conceallevel = 0
    end
})
