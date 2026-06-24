-- Bazel/Starlark support — everything lives in the standalone plugin:
--   https://github.com/the-code-samurai-97/bazel-nvim
--
-- Plugin provides: document symbols (<leader>ss), build/test/run + whole-package
-- build, target/rdeps pickers, source <-> BUILD jump, yank label, label
-- completion, buildifier formatting, ftdetect, snippets, and :Bazel* commands.
--
-- The blink.cmp and conform.nvim fragments below are unavoidable glue: those
-- plugins read their sources/formatters from their own configs. The actual
-- logic lives in the plugin (`bazel-nvim.blink`, `buildifier`).
return {
  {
    "the-code-samurai-97/bazel-nvim",
    dependencies = { "folke/snacks.nvim" },
    ft = { "bzl", "bazel", "starlark", "c", "cpp", "cuda", "python" },
    opts = {
      -- Tailored Bazel snippets already live in ~/.config/nvim/snippets
      -- (snippets/bzl/bzl_custom.json, loaded via LuaSnip). Keep the plugin's
      -- generic snippets off to avoid duplicate completions. Set to `true`
      -- (and remove the JSON) if you'd rather use the bundled ones.
      snippets = false,
    },
  },

  -- Bazel label completion in BUILD / *.bzl (source logic is in bazel-nvim.blink).
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        providers = { bazel = { name = "Bazel", module = "bazel-nvim.blink" } },
        per_filetype = { bzl = { inherit_defaults = true, "bazel" } },
      },
    },
  },

  -- buildifier formatting for Bazel filetypes (runs through conform's pipeline).
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        bzl = { "buildifier" },
        bazel = { "buildifier" },
        starlark = { "buildifier" },
      },
    },
  },
}
