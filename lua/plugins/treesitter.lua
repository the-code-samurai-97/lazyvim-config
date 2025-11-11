return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true, -- Enable this plugin
        max_lines = 3, -- Max lines shown for context
        min_window_height = 0, -- Minimum height to enable
        line_numbers = true, -- Show line numbers in context
        multiline_threshold = 20, -- Max lines per context
        trim_scope = "outer", -- Discard outer context if too long
        mode = "cursor", -- Follow cursor
        separator = nil, -- You can use "─" or "—" for a line
        zindex = 20, -- Display priority
      })
    end,
  },
}
