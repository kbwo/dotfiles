require("hlchunk").setup({
  chunk = {
    enable = true,
    chars = {
      horizontal_line = "─",
      vertical_line = "│",
      left_top = "╭",
      left_bottom = "╰",
      right_arrow = "",
    },
    notify = false,
    priority = 0,
  },
  indent = {
    enable = true,
    notify = false,
    priority = 0,
    use_treesitter = false,
    chars = { "╎" },
    -- ┃│╏┊︴╷╵╎〡︱
    ahead_lines = 5,
    delay = 100,
  }
})
