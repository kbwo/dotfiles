local HEIGHT_RATIO = 0.8  -- You can change this
local WIDTH_RATIO = 0.5   -- You can change this too

require('nvim-tree').setup({
  renderer = {
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = false,
        git = true,
        modified = true,
      }
    }
  },
  view = {
    mappings = {
      list = {
        { key = "<Leader>v", action = "vsplit" },
        { key = "<Leader>s", action = "split" },
        { key = "<Leader>t", action = "tabnew" },
        { key = "dl", action = "remove" },
        { key = "yy", action = "copy_absolute_path" },
        { key = "cc", action = "copy" },
        { key = "M", action = "create" },
        { key = "F", action = "next_sibling" },
        { key = "B", action = "prev_sibling" }
      }
    },
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * WIDTH_RATIO
        local window_h = screen_h * HEIGHT_RATIO
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2)
                         - vim.opt.cmdheight:get()
        return {
          border = 'rounded',
          relative = 'editor',
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
        }
        end,
    },
    width = function()
      return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
    end,
  },
    update_focused_file = {
      enable = true,
    update_root = true,
    ignore_list = {},
  },
})

vim.api.nvim_set_keymap('n', '<c-n>', ":NvimTreeToggle<CR>", {})
