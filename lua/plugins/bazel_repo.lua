-- Bazel/Starlark navigation, actions, document symbols (and snippets).
-- Extracted into a standalone plugin: https://github.com/the-code-samurai-97/bazel-nvim
--
-- Provides:
--   * <leader>ss document symbols for BUILD/*.bzl (cc_binary/cc_library/...)
--   * build/test/run target under cursor, yank //pkg:target label
--   * workspace target picker, reverse-deps picker (bazel query)
--   * source <-> BUILD jump
--   * :Bazel* commands and <localleader> keymaps
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
}
