return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        -- Add buildifier here for all Bazel/Starlark filetypes
        bzl = { "buildifier" },
        bazel = { "buildifier" },
        starlark = { "buildifier" },
        -- Your C++ formatters
        cpp = { "clang-format" },
      },
      -- This is the crucial part to stop duplication
      format_on_save = {
        lsp_format = "fallback", -- Use buildifier OR LSP, never both
        timeout_ms = 500,
      },
    },
  },
}
