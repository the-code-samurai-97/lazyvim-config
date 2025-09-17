return {
  {
    "hat0uma/csvview.nvim",
    ft = { "csv" },
    event = "BufReadPre *.csv",
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    opts = {
      col_sep = ",", -- Use '|' as the column separator
      auto_format = true, -- Automatically format CSV on open
      header = true, -- Treat first row as header
      trim_whitespace = true, -- Trim whitespace from cells
      display_mode = "border", -- Set display mode as borde
      parser = { comments = { "#", "//" } }, -- Support comments
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>CsvViewEnable display_mode=border<cr>", desc = "CSV View" },
      { "<leader>cr", "<cmd>CsvViewDisable<cr>", desc = "CSV Reset" },
    },
  },
}
