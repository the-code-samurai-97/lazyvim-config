return {
  "folke/snacks.nvim",
  opts = {
    notifier = { enabled = true },
    statuscolumn = {
      enabled = true,
    },
    picker = {
      sources = {
        explorer = {
          hidden = true, -- show hidden files like .env
          ignored = true, -- show files ignored by git like node_modules
          exclude = { "node_modules", ".git" },
        },
      },
      layout = {
        backdrop = true, -- Enables floating with backdrop
        width = 0.9,
        height = 0.8,
        border = "rounded",
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Protect against cursor position errors
    local snacks_statuscolumn = require("snacks.statuscolumn")
    local original_get = snacks_statuscolumn.get

    snacks_statuscolumn.get = function(...)
      local ok, result = pcall(original_get, ...)
      return ok and result or ""
    end
  end,
}
