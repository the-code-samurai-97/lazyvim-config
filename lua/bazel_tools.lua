-- Bazel productivity tools that build on the Tree-sitter rule parser in
-- `bazel_symbols.lua`. Everything resolves the *target under the cursor* (or the
-- current file) into a `//package:target` label and acts on it.
--
-- Features
--   1. Build / test / run the target under the cursor    -> M.action("build"|"test"|"run")
--   2. Workspace-wide target picker (bazel query //...)   -> M.pick_targets()
--   3. Yank the //package:target label under the cursor   -> M.yank_label()
--   4. Source <-> BUILD jump                              -> M.goto_owning_target() / M.open_sources()
--   5. Reverse-deps picker (bazel query rdeps(...))       -> M.pick_rdeps()
--
-- User commands and keymaps are wired in M.setup() and after/ftplugin/bzl.lua.

local M = {}

local Symbols = require("bazel_symbols")

local ROOT_MARKERS = { "MODULE.bazel", "WORKSPACE.bazel", "WORKSPACE", "WORKSPACE.bzlmod" }
local BUILD_NAMES = { "BUILD.bazel", "BUILD" }

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Bazel" })
end

local function bazel_exe()
  for _, exe in ipairs({ "bazel", "bazelisk" }) do
    if vim.fn.executable(exe) == 1 then
      return exe
    end
  end
end

--- Nearest Bazel workspace root above `path` (a path string or bufnr), or nil.
---@param path? string|integer
---@return string?
function M.root(path)
  if type(path) == "number" then
    path = vim.api.nvim_buf_get_name(path)
  end
  path = (path and path ~= "") and path or vim.api.nvim_buf_get_name(0)
  local dir = path ~= "" and vim.fs.dirname(path) or vim.uv.cwd()
  local marker = vim.fs.find(ROOT_MARKERS, { upward = true, path = dir })[1]
  return marker and vim.fs.dirname(marker) or nil
end

--- Package path of `dir` relative to `root`, e.g. "foo/bar" ("" at the root).
---@param root string
---@param dir string
---@return string
local function package_of(root, dir)
  if dir == root then
    return ""
  end
  return (dir:sub(#root + 2):gsub("\\", "/"))
end

--- Split "//pkg:name" / "@repo//pkg:name" / "//pkg" into pkg, name.
---@param label string
---@return string? pkg, string? name
local function parse_label(label)
  local l = label:gsub("^@+[%w_.~+-]*", "") -- strip @repo / @@repo~ (external)
  local pkg, name = l:match("^//(.-):(.+)$")
  if not pkg then
    pkg = l:match("^//(.+)$")
    name = pkg and pkg:match("[^/]+$") -- //foo/bar -> //foo/bar:bar
  end
  return pkg, name
end

--- Target under the cursor as { label, name, rule, root }, or nil + reason.
---@return { label:string, name:string, rule:string, root:string }?, string?
function M.cursor_target()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local target = Symbols.target_at(bufnr, row)
  if not target then
    return nil, "No Bazel target under the cursor"
  end
  local root = M.root(bufnr)
  if not root then
    return nil, "No Bazel workspace root (MODULE.bazel / WORKSPACE) found"
  end
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local label = ("//%s:%s"):format(package_of(root, dir), target.name)
  return { label = label, name = target.name, rule = target.rule, root = root }
end

-- ── running bazel ──────────────────────────────────────────────────────────

--- build / test: async job, errors streamed into the quickfix list.
---@param args string[]
---@param cwd string
---@param title string
local function run_quickfix(args, cwd, title)
  local exe = bazel_exe()
  if not exe then
    return notify("`bazel` executable not found", vim.log.levels.ERROR)
  end
  local cmd = vim.list_extend({ exe }, args)
  notify("🚀 " .. table.concat(cmd, " "))
  local out = {}
  vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, d)
      if d then
        vim.list_extend(out, d)
      end
    end,
    on_stderr = function(_, d)
      if d then
        vim.list_extend(out, d)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        notify("✅ " .. title .. " succeeded")
        vim.cmd("cclose")
      else
        vim.fn.setqflist({}, "r", { title = title, lines = out })
        vim.cmd("copen")
        notify("❌ " .. title .. " failed — see quickfix", vim.log.levels.ERROR)
      end
    end,
  })
end

--- run: open in a terminal (interactive stdin/stdout).
---@param args string[]
---@param cwd string
local function run_terminal(args, cwd)
  local exe = bazel_exe()
  if not exe then
    return notify("`bazel` executable not found", vim.log.levels.ERROR)
  end
  local cmd = vim.list_extend({ exe }, args)
  local ok = pcall(function()
    Snacks.terminal(cmd, { cwd = cwd, win = { position = "bottom", height = 0.4 } })
  end)
  if not ok then
    vim.cmd("botright new")
    vim.fn.jobstart(cmd, { cwd = cwd, term = true })
    vim.cmd("startinsert")
  end
end

--- Feature 1: build / test / run the target under the cursor.
---@param kind "build"|"test"|"run"
function M.action(kind)
  local info, err = M.cursor_target()
  if not info then
    return notify(err, vim.log.levels.WARN)
  end
  if kind == "run" then
    run_terminal({ "run", info.label }, info.root)
  else
    run_quickfix({ kind, info.label }, info.root, ("bazel %s %s"):format(kind, info.label))
  end
end

--- Feature 3: copy the label of the target under the cursor.
function M.yank_label()
  local info, err = M.cursor_target()
  if not info then
    return notify(err, vim.log.levels.WARN)
  end
  vim.fn.setreg("+", info.label)
  vim.fn.setreg('"', info.label)
  notify("Copied: " .. info.label)
end

-- ── bazel query + navigation ────────────────────────────────────────────────

--- Run `bazel query <expr>` asynchronously; cb(labels) | cb(nil, err).
---@param expr string
---@param root string
---@param cb fun(labels?: string[], err?: string)
function M.query(expr, root, cb)
  local exe = bazel_exe()
  if not exe then
    return notify("`bazel` executable not found", vim.log.levels.ERROR)
  end
  notify("⏳ bazel query " .. expr)
  vim.system(
    { exe, "query", expr, "--output=label", "--keep_going", "--noshow_progress" },
    { cwd = root, text = true },
    function(res)
      vim.schedule(function()
        local labels = {}
        for line in (res.stdout or ""):gmatch("[^\r\n]+") do
          if line:match("^@?//") then
            labels[#labels + 1] = line
          end
        end
        if #labels == 0 and res.code ~= 0 then
          cb(nil, vim.trim(res.stderr or "bazel query failed"))
        else
          cb(labels)
        end
      end)
    end
  )
end

--- Open the BUILD file for `label` and jump to the rule.
---@param label string
---@param root? string
function M.goto_label(label, root)
  root = root or M.root(0)
  if not root then
    return notify("No Bazel workspace root found", vim.log.levels.ERROR)
  end
  local pkg, name = parse_label(label)
  if not pkg or not name then
    return notify("Cannot resolve label: " .. label, vim.log.levels.WARN)
  end
  local dir = pkg == "" and root or (root .. "/" .. pkg)
  local build
  for _, b in ipairs(BUILD_NAMES) do
    if vim.uv.fs_stat(dir .. "/" .. b) then
      build = dir .. "/" .. b
      break
    end
  end
  if not build then
    return notify("No BUILD file for //" .. pkg, vim.log.levels.WARN)
  end
  vim.cmd.edit(vim.fn.fnameescape(build))
  for _, t in ipairs(Symbols.targets(0)) do
    if t.name == name then
      vim.api.nvim_win_set_cursor(0, { t.start_row + 1, 0 })
      vim.cmd("normal! zz")
      return
    end
  end
end

--- A Snacks picker over a list of labels; confirming jumps to the rule.
---@param title string
---@param labels string[]
---@param root string
local function pick_labels(title, labels, root)
  if #labels == 0 then
    return notify("No targets found", vim.log.levels.WARN)
  end
  local items = {}
  for _, l in ipairs(labels) do
    items[#items + 1] = { text = l, label = l }
  end
  Snacks.picker.pick({
    source = "bazel",
    title = title,
    items = items,
    format = function(item)
      local pkg, name = item.label:match("^(//.-):(.+)$")
      if pkg then
        return { { pkg .. ":", "SnacksPickerDir" }, { name, "SnacksPickerLabel" } }
      end
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        M.goto_label(item.label, root)
      end
    end,
  })
end

--- Feature 2: pick any target in the workspace and jump to its rule.
function M.pick_targets()
  local root = M.root(0) or vim.uv.cwd()
  M.query("//...", root, function(labels, err)
    if not labels then
      return notify(err, vim.log.levels.ERROR)
    end
    pick_labels("Bazel Targets", labels, root)
  end)
end

--- Feature 5: reverse dependencies of the target under the cursor.
function M.pick_rdeps()
  local info, err = M.cursor_target()
  if not info then
    return notify(err, vim.log.levels.WARN)
  end
  M.query(("rdeps(//..., %s)"):format(info.label), info.root, function(labels, qerr)
    if not labels then
      return notify(qerr, vim.log.levels.ERROR)
    end
    labels = vim.tbl_filter(function(l)
      return l ~= info.label
    end, labels)
    pick_labels("rdeps of " .. info.label, labels, info.root)
  end)
end

--- Feature 4a: from a source file, jump to the target(s) that own it.
function M.goto_owning_target()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  local root = M.root(bufnr)
  if not root or file == "" then
    return notify("No Bazel workspace root found", vim.log.levels.WARN)
  end
  local pkg = package_of(root, vim.fs.dirname(file))
  local fname = vim.fs.basename(file)
  local file_label = ("//%s:%s"):format(pkg, fname)
  M.query(("rdeps(//%s:all, %s, 1)"):format(pkg, file_label), root, function(labels, err)
    if not labels then
      return notify(err, vim.log.levels.ERROR)
    end
    labels = vim.tbl_filter(function(l)
      return l ~= file_label
    end, labels)
    if #labels == 0 then
      return notify("No target owns " .. fname, vim.log.levels.WARN)
    elseif #labels == 1 then
      M.goto_label(labels[1], root)
    else
      pick_labels("Targets owning " .. fname, labels, root)
    end
  end)
end

--- Feature 4b: open the srcs/hdrs of the target under the cursor.
function M.open_sources()
  local info, err = M.cursor_target()
  if not info then
    return notify(err, vim.log.levels.WARN)
  end
  local expr = ("labels(srcs, %s) union labels(hdrs, %s)"):format(info.label, info.label)
  M.query(expr, info.root, function(labels, qerr)
    if not labels then
      return notify(qerr, vim.log.levels.ERROR)
    end
    local items = {}
    for _, l in ipairs(labels) do
      local pkg, name = parse_label(l)
      if pkg and name then
        local path = info.root .. "/" .. (pkg == "" and "" or (pkg .. "/")) .. name
        items[#items + 1] = { text = name, file = path }
      end
    end
    if #items == 0 then
      return notify("No srcs/hdrs for " .. info.label, vim.log.levels.WARN)
    elseif #items == 1 then
      vim.cmd.edit(vim.fn.fnameescape(items[1].file))
    else
      Snacks.picker.pick({
        source = "bazel_sources",
        title = "Sources of " .. info.label,
        items = items,
        format = function(item, picker)
          return require("snacks.picker.format").filename(item, picker)
        end,
        confirm = function(picker, item)
          picker:close()
          if item then
            vim.cmd.edit(vim.fn.fnameescape(item.file))
          end
        end,
      })
    end
  end)
end

-- ── wiring ──────────────────────────────────────────────────────────────────

function M.setup()
  local command = vim.api.nvim_create_user_command
  -- stylua: ignore start
  command("BazelBuild",   function() M.action("build") end, { desc = "Bazel: build target under cursor" })
  command("BazelTest",    function() M.action("test") end,  { desc = "Bazel: test target under cursor" })
  command("BazelRun",     function() M.action("run") end,   { desc = "Bazel: run target under cursor" })
  command("BazelLabel",   function() M.yank_label() end,    { desc = "Bazel: yank //pkg:target label" })
  command("BazelTargets", function() M.pick_targets() end,  { desc = "Bazel: pick any target in workspace" })
  command("BazelRdeps",   function() M.pick_rdeps() end,    { desc = "Bazel: reverse deps of target under cursor" })
  command("BazelTarget",  function() M.goto_owning_target() end, { desc = "Bazel: jump to target owning current file" })
  command("BazelSources", function() M.open_sources() end,  { desc = "Bazel: open srcs/hdrs of target under cursor" })
  -- stylua: ignore end

  -- Source-file keymaps (C/C++/CUDA/Python): jump to the owning target and the
  -- workspace target picker. BUILD-file keymaps live in after/ftplugin/bzl.lua.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("BazelToolsSrcKeys", { clear = true }),
    pattern = { "c", "cpp", "cuda", "python" },
    callback = function(args)
      local function map(lhs, fn, desc)
        vim.keymap.set("n", lhs, fn, { buffer = args.buf, silent = true, desc = desc })
      end
      map("<localleader>b", M.goto_owning_target, "Bazel: jump to owning target")
      map("<localleader>f", M.pick_targets, "Bazel: find target in workspace")
    end,
  })
end

return M
