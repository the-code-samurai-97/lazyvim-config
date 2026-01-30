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

local function build_current_bazel_file()
  -- 1. Locate the Bazel root (Workspace)
  local root_files = { "MODULE.bazel", "WORKSPACE.bazel", "WORKSPACE" }
  local find_root = vim.fs.find(root_files, { upward = true, path = vim.fn.expand("%:p:h") })

  if #find_root == 0 then
    vim.notify("No Bazel workspace root found (missing MODULE.bazel or WORKSPACE).", vim.log.levels.ERROR)
    return
  end

  local root_path = vim.fs.dirname(find_root[1])
  local current_dir = vim.fn.expand("%:p:h")
  local relative_pkg = current_dir:sub(#root_path + 2)
  local target = (relative_pkg == "" or relative_pkg == ".") and "//..." or "//" .. relative_pkg .. ":all"

  vim.notify("🚀 Bazel Building: " .. target, vim.log.levels.INFO)

  local output = {}

  vim.fn.jobstart({ "bazel", "build", target }, {
    cwd = root_path,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✅ Bazel Build Successful!", vim.log.levels.INFO)
        vim.cmd("cclose")
      else
        -- Load errors into Quickfix
        vim.fn.setqflist({}, "r", {
          title = "Bazel Build Errors",
          lines = output,
        })
        vim.cmd("copen")

        -- The modern way to alert the user of an error
        vim.notify("❌ Build Failed. Errors loaded to Quickfix list.", vim.log.levels.ERROR)
      end
    end,
  })
end

-- Create the command
vim.api.nvim_create_user_command("BazelBuildCurrent", build_current_bazel_file, {
  desc = "Find Bazel root and build current directory",
})
