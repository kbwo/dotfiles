require("autolist").setup()

  -- Define markdown-related filetypes and git commit
  local markdown_filetypes = { "markdown", "md", "text", "txt", "tex", "pandoc", "rst", "org", "norg", "gitcommit" }

  -- Create autocommand group for autolist keymaps
  vim.api.nvim_create_augroup("AutolistKeymaps", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = "AutolistKeymaps",
    pattern = markdown_filetypes,
    callback = function()
      local opts = { buffer = true }

      -- Insert mode mappings
      vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>", opts)
      vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>", opts)
      -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>", opts) -- an example of using <c-t> to indent
      vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", opts)

      -- Normal mode mappings
      vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
      vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)
      vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>", opts)
      vim.keymap.set("n", "<leader>l<Space>", "<cmd>AutolistRecalculate<cr>", opts)

      -- Cycle list types with dot-repeat
      vim.keymap.set("n", "<A-l>", require("autolist").cycle_next_dr, { buffer = true, expr = true })
      -- vim.keymap.set("n", "<leader>lp", require("autolist").cycle_prev_dr, { buffer = true, expr = true })

      -- Indentation and deletion mappings
      vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>", opts)
      vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>", opts)
      vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>", opts)
      vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>", opts)
    end,
  })
