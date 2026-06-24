-- Buffer-local Bazel keymaps for BUILD / *.bzl files. See lua/bazel_tools.lua.
-- Uses <localleader> (default: \) to avoid clashing with global LazyVim maps.
local ok, bazel = pcall(require, "bazel_tools")
if not ok then
  return
end

local function map(lhs, fn, desc)
  vim.keymap.set("n", lhs, fn, { buffer = true, silent = true, desc = desc })
end

map("<localleader>b", function()
  bazel.action("build")
end, "Bazel: build target under cursor")

map("<localleader>t", function()
  bazel.action("test")
end, "Bazel: test target under cursor")

map("<localleader>r", function()
  bazel.action("run")
end, "Bazel: run target under cursor")

map("<localleader>y", bazel.yank_label, "Bazel: yank //pkg:target label")

map("<localleader>R", bazel.pick_rdeps, "Bazel: reverse deps of target")

map("<localleader>s", bazel.open_sources, "Bazel: open srcs/hdrs of target")

map("<localleader>f", bazel.pick_targets, "Bazel: find target in workspace")
