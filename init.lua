-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
--
vim.filetype.add({
  filename = {
    [".bazelrc"] = "sh",
  },
  extension = {
    [".bzl"] = "bazel",
    [".bazel.tpl"] = "bazel",
    ["bzlmod"] = "bazel",
    ["BUILD"] = "bazel",
    ["BUILD.bazel"] = "bazel",
    ["WORKSPACE"] = "bazel",
    ["workspace"] = "bazel",
    ["bzlproj"] = "bazel",
    ["data"] = "csv",
    ["scn"] = "yaml",
    ["lola"] = "yaml",
    ["veh"] = "yaml",
    ["tpp"] = "cpp",
  },
  pattern = {
    ["%.bazel$"] = "bazel",
    ["%.bazel.%"] = "bazel",
    ["%.tpl$"] = "bazel",
    ["bzl"] = "bazel",
    ["BUILD"] = "bazel",
    ["BUILD%.bazel$"] = "bazel",
    ["%.bazelrc$"] = "bazel", -- Added the missing .bazelrc pattern
    ["%.tpp$"] = "cpp", -- Fixed the pattern (was [".%pp$"])
    ["%.lola$"] = "yaml", -- Fixed the pattern (was [".lola"])
    ["%.scn$"] = "yaml", -- Fixed the pattern (was [".scn"])
    ["%.veh$"] = "yaml", -- Fixed the pattern (was [".veh"])
    ["%.data$"] = "csv",
  },
  extension = {
    [".bazelrc"] = "bazelrc",
    ["bzl"] = "bazel",
    ["bzlmod"] = "bazel",
    ["BUILD"] = "bazel",
    ["BUILD.bazel"] = "bazel",
    ["WORKSPACE"] = "bazel",
    ["bzlproj"] = "bazel",
    ["data"] = "csv",
  },
  pattern = {
    ["%.bazel$"] = "bazel",
    ["%.bzl$"] = "bazel",
    ["BUILD"] = "bazel",
    ["BUILD%.bazel$"] = "bazel",
  },
})

-- -- Add your shell's PATH to Neovim's PATH
-- local path = vim.env.PATH
-- if not path:find("/usr/bin") then -- Adjust this path as needed
--   vim.env.PATH = "/usr/bin:" .. path -- Add the directory containing bazel
-- end

vim.keymap.set("n", "<C-g>", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("No file loaded.", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path) -- copy to system clipboard
  vim.notify("Copied path: " .. path, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Copy absolute file path to clipboard" })

-- Set to `false` to globally disable all snacks animations
vim.g.snacks_animate = false
