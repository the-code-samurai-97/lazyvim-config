return {
  "hrsh7th/nvim-cmp",
  dependencies = { "alexander-born/cmp-bazel" },
  opts = function(_, opts)
    opts.sources = require("cmp").config.sources(vim.list_extend(opts.sources, { { name = "bazel" } }))
  end,
}
