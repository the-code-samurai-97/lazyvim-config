return {
  {
    "bazelbuild/vim-bazel",
    lazy = true,
    ft = { "bzl", "bazel", "starlark" },
    dependencies = {
      "google/vim-maktaba",
    },
    config = function()
      vim.g.bazel_make_command = "/usr/bin/bazel"
      -- No keymaps as requested
    end,
  },
}
