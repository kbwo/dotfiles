-- Enhanced function to surround selected text with ```<lang>
function SurroundWithCodeblock()
  -- Prompt the user for the language
  local lang = vim.fn.input("Enter language for code block (optional): ")

  -- Get the current visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  -- Adjust positions (Lua indices start at 1)
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Prepare the opening backticks with language if provided
  local opening = lang ~= "" and "```" .. lang or "```"

  -- Insert ```<lang> above the selection
  vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { opening })

  -- Insert ``` below the selection
  vim.api.nvim_buf_set_lines(0, end_line + 1, end_line + 1, false, { "```" })
end

-- Map the enhanced function to <leader>c in visual mode
vim.api.nvim_set_keymap(
  'v',
  's`',
  ':lua SurroundWithCodeblock()<CR>',
  { noremap = true, silent = true }
)
