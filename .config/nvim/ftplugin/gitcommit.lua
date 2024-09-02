-- https://hiroki-sawano.hatenablog.com/entry/autocomplete-commit-message-using-copilot-chat-nvim
local has_copilot = vim.fn.exists(":CopilotChat") == 2

if has_copilot then
  vim.schedule(function()
      local chat = require("CopilotChat")
      chat.ask('Generate a concise and meaningful commit message title based on the changes made with conventional commits format. Make sure the title has maximum 50 characters. Do not put quotes around the title. Focus solely on creating the title, not the full commit message body.', {
        selection = function(source)
          return require("CopilotChat.select").gitdiff(source, true)
        end,
        callback = function(response)
          chat.close()
          vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, {response})
        end,
      })
  end)
end
