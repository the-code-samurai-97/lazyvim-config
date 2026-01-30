return {
  {
    "nvim-telescope/telescope.nvim",
    enabled = false, -- Disable Telescope
  },
  {
    "ibhagwan/fzf-lua",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional for icons
    config = function()
      local fzf_lua = require("fzf-lua")
      fzf_lua.setup({
        fzf_opts = {
          -- This forces exact matching globally for all fzf-lua pickers
          ["--exact"] = "",
        },
        files = {
          -- Exclude deprecated directory from file search --follow --hidden
          fd_opts = "--no-ignore --exclude .git --exclude clangd --exclude bazel-bin --exclude bazel-out --exclude bazel-testlogs  --exclude deprecated ",
        },
        grep = {
          -- --no-ignore --hidden --follow
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096  --no-messages --glob=!deprecated/",
        },
        winopts = {
          -- Enable colors in the preview window
          preview = {
            syntax = true,
            syntax_limit_l = 0, -- syntax limit (lines), 0=nolimit
            syntax_limit_b = 1024 * 1024, -- syntax limit (bytes)
          },
        },
      })

      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
      -- Leader fG: live grep INCLUDING gitignored files AND following symlinks
      vim.keymap.set("n", "<leader>sf", function()
        -- Get parent directory of current file
        local filepath = vim.api.nvim_buf_get_name(0)
        local parent = vim.fn.fnamemodify(filepath, ":h")
        fzf_lua.live_grep({ cwd = parent })
      end, { desc = "Live grep in parent folder" })
      -- Search buffer lines with custom window options
      -- ----------------------------------------------------------
      vim.keymap.set("n", "f", function() -- <leader>sf
        require("fzf-lua").blines({
          winopts = {
            height = 0.8,
            width = 0.9,
            row = 0.5,
            col = 0.5,
            border = "rounded",
            preview = {
              vertical = "down:50%",
              horizontal = "right:50%",
            },
          },
          fzf_opts = {
            ["--layout"] = "default",
            ["--info"] = "inline",
          },
        })
      end, { desc = "Search buffer lines (fzf-lua)" })
    end,
  },
}
