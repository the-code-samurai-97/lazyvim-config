if vim.fn.executable("lazygit") == 1 then
  -- LazyGit at current working directory (plain terminal)
  vim.keymap.set("n", "<leader>gg", function()
    Snacks.lazygit({ cwd = vim.fn.getcwd() })
  end, { desc = "Lazygit (cwd, plain terminal)" })
end
