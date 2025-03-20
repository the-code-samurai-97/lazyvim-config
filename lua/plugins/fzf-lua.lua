return {
    {
      "nvim-telescope/telescope.nvim",
      enabled = false, -- Disable Telescope
    },
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional for icons
      config = function()
        require("fzf-lua").setup({})
        vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
      end,
    },
  }
  