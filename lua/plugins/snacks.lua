return {
    "folke/snacks.nvim",
    opts = {
      notifier = { enabled = true },
      picker = {
        sources = {
          explorer = {
            hidden = true, -- show hidden files like .env
            ignored = true, -- show files ignored by git like node_modules
            exclude = { "node_modules", ".git" },
              
          },
        },
      },
    },
  }
  