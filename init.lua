-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
--

require("catppuccin").setup({
  flavour = "mocha", -- "latte", "frappe", "macchiato", "mocha"
  -- other config options if needed
})

vim.cmd.colorscheme("catppuccin")
---
vim.filetype.add({
  filename = {
    [".bazelrc"] = "sh",
    [".yamllint"] = "yaml",
    ["jenkinsfile"] = "groovy",
  },
  extension = {
    [".bzl"] = "bazel",
    [".bazel.tpl"] = "bazel",
    [".msg"] = "rosmsg",
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
    ["cu"] = "cpp",
    ["cuh"] = "cpp",
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

-- Center after half-page and search movements
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
--
-- local mem = require("memlayout")
--
-- -- Get all layouts as a Lua table
-- local layouts = mem.get_record_layouts()
--
-- -- Print it nicely
-- print(vim.inspect(layouts))
