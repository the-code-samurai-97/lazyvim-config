-- return {
--   {
--     "bazelbuild/vim-bazel",
--     lazy = true,
--     ft = { "bzl", "bazel", "starlark" },
--     dependencies = {
--       "google/vim-maktaba",
--     },
--     config = function()
--       vim.g.bazel_make_command = "/usr/bin/bazel"
--       -- No keymaps as requested
--     end,
--   },
-- }
--
return {
  { "sibi-venti/vim-bazel", dependencies = { "google/vim-maktaba" } },
  { "rcarriga/nvim-notify" },
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.compat", { "alexander-born/cmp-bazel", dependencies = "hrsh7th/nvim-cmp" } },
    opts = {
      sources = {
        compat = { "bazel" },
      },
    },
  },
}
