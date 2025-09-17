return {
  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    opts = {
      -- add your options that should be passed to the setup() function here
      position = "right",
      show_numbers = true,
      width = 70,
      relative_width = true,
      show_relative_numbers = true,
      auto_preview = false,
    },
  },
}
