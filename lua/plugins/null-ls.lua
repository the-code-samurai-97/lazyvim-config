return {
  -- Remove null-ls if you have it
  {
    "jose-elias-alvarez/null-ls.nvim",
    enabled = false, -- Disable null-ls
  },

  -- Add none-ls
  {
    "nvimtools/none-ls.nvim",
    event = "LazyFile",
    dependencies = { "mason.nvim" },
    opts = function()
      local nls = require("null-ls")
      return {
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {

          -- Bazel formatting
          nls.builtins.formatting.buildifier, -- Bazel files (BUILD, WORKSPACE, .bzl)
        },
      }
    end,
  },
}
