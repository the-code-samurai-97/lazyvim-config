return {
  {
    "nvim-telescope/telescope.nvim",
    enabled = false, -- Disable Telescope
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional for icons
    config = function()
      local fzf_lua = require("fzf-lua")
      fzf_lua.setup({})
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
      -- Leader sf: live grep in current file's parent folder
      vim.keymap.set("n", "<leader>sf", function()
        -- Get parent directory of current file
        local filepath = vim.api.nvim_buf_get_name(0)
        local parent = vim.fn.fnamemodify(filepath, ":h")
        fzf_lua.live_grep({ cwd = parent })
      end, { desc = "Live grep in parent folder" })
    end,
  },
}
