return {
  {
    "ojroques/vim-oscyank",
    init = function()
      -- Keymaps
      -- vim.keymap.set("v", "<leader>y", ":OSCYank<CR>", { silent = true, desc = "OSCYank selection" })
      -- vim.keymap.set("n", "<leader>y", ":OSCYank<CR>", { silent = true, desc = "OSCYank line" })
      -- -- Replace normal yy with: yank line + OSCYank
      -- vim.keymap.set("n", "yy", "yy:OSCYank<CR>", { silent = true })
      --
      -- Use OSC52 for all Visual mode yanks
      vim.keymap.set("v", "<leader>y", ":<C-u>OSCYank<CR>", { silent = true, desc = "OSCYank selection" })

      vim.keymap.set("n", "yy", function()
        vim.cmd("normal! yy")
        vim.cmd('OSCYankRegister "')
      end, { silent = true })

      -- Enhance `yy` to also OSC52
      vim.keymap.set("n", "yy", function()
        vim.cmd("normal! yy")
        vim.cmd('OSCYankRegister "')
      end, { silent = true })

      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.cmd([[OSCYankRegister "]])
        end,
      })

      -- Optional settings
      vim.g.oscyank_max_length = 0 -- default: 100000
      vim.g.oscyank_silent = false -- do not show 'Copied!' message
      vim.g.oscyank_trim = false -- trim trailing newlines
    end,
  },
}
