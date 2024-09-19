require("toggleterm").setup{
  size = 20,
  close_on_exit = true,
}
local terminal_id = 1

function open_new_terminal()
  require("toggleterm.terminal").Terminal:new({ id = terminal_id, close_on_exit = true }):toggle()
  terminal_id = terminal_id + 1
end

function toggle_or_new_terminal()
  if terminal_id == 1 then
    open_new_terminal()
  else
    vim.cmd('ToggleTerm')
  end
end

vim.api.nvim_set_keymap('n', '<Leader>gt', '<cmd>lua toggle_or_new_terminal()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>gn", "<cmd>lua open_new_terminal()<CR>", { noremap = true, silent = true })

-- Function to close all buffers with filetype 'toggleterm'
local function close_all_toggleterm_buffers()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'filetype') == 'toggleterm' then
      local windows = vim.fn.win_findbuf(buf)
      if #windows > 0 then
        for _, win in ipairs(windows) do
          vim.api.nvim_win_close(win, true)
        end
      else
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end

-- Define a Neovim command to close all toggleterm buffers
vim.api.nvim_create_user_command(
  'CloseToggletermBuffers',
  close_all_toggleterm_buffers,
  { desc = 'Close all toggleterm buffers' }
)
