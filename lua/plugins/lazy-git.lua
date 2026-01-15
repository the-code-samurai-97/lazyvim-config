return {
  "kdheepak/lazygit.nvim",
  cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>gg", "<cmd>LazyGitCurrentFile<cr>", desc = "Open Lazygit" },
  },
  config = function()
    -- -- Lazygit floating window style
    -- vim.g.lazygit_floating_window_use_plenary = 1
    -- vim.g.lazygit_floating_window_winblend = 5      -- Slight transparency
    -- vim.g.lazygit_floating_window_scaling_factor = 0.9
    -- vim.g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" }
    -- vim.g.lazygit_use_neovim_remote = 1
    --
    -- Fix floating window position when returning to terminal or resizing
    vim.api.nvim_create_autocmd({ "VimResized", "FocusGained" }, {
      callback = function()
        local ok, winid = pcall(vim.fn.win_getid)
        if ok and winid ~= 0 then
          vim.cmd("redraw!")
        end
      end,
    })
    vim.g.lazygit_floating_window_use_plenary = 1
    vim.g.lazygit_floating_window_winblend = 5 -- Slight transparency
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    vim.g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" }
    vim.g.lazygit_use_neovim_remote = 0

    -- Fix floating window position when returning to terminal or resizing
    -- vim.api.nvim_create_autocmd({ "VimResized", "FocusGained" }, {
    --   callback = function()
    --     local ok, winid = pcall(vim.fn.win_getid)
    --     if ok and winid ~= 0 then
    --       vim.cmd("redraw!")
    --     end
    --   end,
    -- })
  end,
}
