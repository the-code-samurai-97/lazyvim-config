-- In your Neovim config (e.g., ~/.config/nvim/lua/plugins/noice.lua)
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = {
      view = "cmdline_popup", -- Use popup view
      format = {
        cmdline = { pattern = "^:", icon = ">", lang = "vim" },
      },
    },
    views = {
      cmdline_popup = {
        position = {
          row = "30%", -- Center vertically
          col = "50%", -- Center horizontally
        },
        size = {
          width = 60,
          height = "auto",
        },
        border = {
          style = "rounded",
        },
      },
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}
