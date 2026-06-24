-- Bazel/Starlark document symbols for `<leader>ss` (and outline, breadcrumbs).
--
-- BUILD / BUILD.bazel / *.bzl files (filetype `bzl`) are served by the `starpls`
-- language server, but its document symbols are bare target names (`:math_utils`,
-- kind Variable) with no hint about the rule type. This module provides its own
-- `textDocument/documentSymbol` implementation that parses the buffer with the
-- (Starlark-compatible) Python Tree-sitter parser and reports each rule call by
-- name *together with its rule type*, e.g.
--
--     cc_binary(name = "main_app", ...)    ->  [Function] main_app        cc_binary
--     cc_library(name = "math_utils", ...) ->  [Class]    math_utils      cc_library
--     py_binary / cuda_library / cc_test / genrule / ...
--
-- For .bzl files it also reports top-level `def` functions and assignments so
-- navigation there keeps working.
--
-- It runs as a tiny *in-process* LSP server advertising `documentSymbolProvider`,
-- so the existing `<leader>ss` keymap (registered by LazyVim with
-- `has = "documentSymbol"`) lights up automatically. starpls' own (weaker)
-- document symbols are suppressed to avoid duplicate entries.

local M = {}

local SymbolKind = vim.lsp.protocol.SymbolKind

-- Pick an LSP SymbolKind for a rule. The kinds chosen here are all part of
-- LazyVim's default `kind_filter`, so the targets are never filtered out, and
-- they give visually distinct icons in the picker.
---@param rule string e.g. "cc_binary", "native.cc_library", "py_test"
---@return integer
local function rule_to_kind(rule)
  local short = rule:match("[%w_]+$") or rule
  if short:match("_test$") then
    return SymbolKind.Method
  elseif short:match("_binary$") then
    return SymbolKind.Function
  elseif short:match("library$") or short:match("_proto$") or short:match("module$") then
    return SymbolKind.Class
  end
  return SymbolKind.Struct
end

-- Literal value of a Python `string` node, without the surrounding quotes /
-- string prefix. Non-literal expressions (concatenations, variables, f-strings)
-- fall back to their raw source text.
---@param node TSNode
---@param src string
---@return string
local function string_value(node, src)
  if node:type() == "string" then
    for i = 0, node:named_child_count() - 1 do
      local child = node:named_child(i)
      if child:type() == "string_content" then
        return vim.treesitter.get_node_text(child, src)
      end
    end
    return "" -- empty literal: "" or ''
  end
  return vim.treesitter.get_node_text(node, src)
end

---@param node TSNode
---@return lsp.Range
local function range_of(node)
  local sr, sc, er, ec = node:range()
  return {
    start = { line = sr, character = sc },
    ["end"] = { line = er, character = ec },
  }
end

-- Find the `name = "..."` value node inside a call's `argument_list`.
---@param args TSNode argument_list
---@param src string
---@return TSNode?
local function find_name_arg(args, src)
  for i = 0, args:named_child_count() - 1 do
    local arg = args:named_child(i)
    if arg:type() == "keyword_argument" then
      local key = arg:field("name")[1]
      local val = arg:field("value")[1]
      if key and val and vim.treesitter.get_node_text(key, src) == "name" then
        return val
      end
    end
  end
end

-- Turn one top-level statement into a DocumentSymbol (or nil).
---@param stmt TSNode a named child of the module root
---@param src string
---@return lsp.DocumentSymbol?
local function statement_symbol(stmt, src)
  local t = stmt:type()

  -- def foo(...):  ->  Function
  if t == "function_definition" then
    local name = stmt:field("name")[1]
    if name then
      return {
        name = vim.treesitter.get_node_text(name, src),
        detail = "def",
        kind = SymbolKind.Function,
        range = range_of(stmt),
        selectionRange = range_of(name),
      }
    end
    return nil
  end

  -- Everything else we care about lives inside an expression_statement.
  local inner = t == "expression_statement" and stmt:named_child(0) or stmt
  if not inner then
    return nil
  end

  -- A rule invocation: cc_binary(name = "...", ...)  ->  rule target
  if inner:type() == "call" then
    local func = inner:field("function")[1]
    local args = inner:field("arguments")[1]
    if not (func and args and args:type() == "argument_list") then
      return nil
    end
    local name_node = find_name_arg(args, src)
    if not name_node then
      return nil -- load(), package(), licenses(), ... — not a target
    end
    local rule = vim.treesitter.get_node_text(func, src)
    return {
      name = string_value(name_node, src),
      detail = rule,
      kind = rule_to_kind(rule),
      range = range_of(inner), -- whole rule block (used by outline)
      selectionRange = range_of(func), -- jump target: the rule name
    }
  end

  -- Top-level assignment: COPTS = [...] / my_rule = rule(...)  ->  Variable/Constant
  if inner:type() == "assignment" then
    local left = inner:field("left")[1]
    if left and left:type() == "identifier" then
      local name = vim.treesitter.get_node_text(left, src)
      return {
        name = name,
        detail = "",
        kind = name:match("^_?%u[%u%d_]*$") and SymbolKind.Constant or SymbolKind.Variable,
        range = range_of(stmt),
        selectionRange = range_of(left),
      }
    end
  end

  return nil
end

-- Parse a buffer and return LSP DocumentSymbol[] for its top-level rule calls,
-- function definitions and assignments.
---@param bufnr integer
---@return lsp.DocumentSymbol[]
function M.document_symbols(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return {}
  end

  local src = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")

  -- Starlark is syntactically a subset of Python; reuse the Python parser so we
  -- don't depend on a separately-installed `starlark` parser.
  local ok, parser = pcall(vim.treesitter.get_string_parser, src, "python")
  if not ok or not parser then
    return {}
  end

  local root = parser:parse()[1]:root()
  local symbols = {} ---@type lsp.DocumentSymbol[]
  for i = 0, root:named_child_count() - 1 do
    local sym = statement_symbol(root:named_child(i), src)
    if sym then
      symbols[#symbols + 1] = sym
    end
  end
  return symbols
end

-- Factory for the in-process LSP server. See `:h vim.lsp.rpc.PublicClient`.
---@param dispatchers vim.lsp.rpc.Dispatchers
---@return vim.lsp.rpc.PublicClient
local function make_server(dispatchers)
  local closing = false
  local id = 0

  return {
    request = function(method, params, callback, notify_callback)
      id = id + 1

      local function reply(result)
        if callback then
          vim.schedule(function()
            callback(nil, result)
          end)
        end
      end

      if method == "initialize" then
        reply({
          capabilities = {
            documentSymbolProvider = true,
            textDocumentSync = { openClose = true, change = 1 }, -- Full
          },
          serverInfo = { name = "bazel-symbols", version = "1.0.0" },
        })
      elseif method == "textDocument/documentSymbol" then
        vim.schedule(function()
          local buf = vim.uri_to_bufnr(params.textDocument.uri)
          local ok, result = pcall(M.document_symbols, buf)
          if callback then
            callback(nil, ok and result or {})
          end
        end)
      else
        -- `shutdown` and anything we don't implement: reply with a null result.
        reply(nil)
      end

      if notify_callback then
        vim.schedule(function()
          notify_callback(id)
        end)
      end
      return true, id
    end,

    notify = function(method)
      if method == "exit" then
        closing = true
        if dispatchers and dispatchers.on_exit then
          dispatchers.on_exit(0, 15)
        end
      end
      return true
    end,

    is_closing = function()
      return closing
    end,

    terminate = function()
      closing = true
    end,
  }
end

-- Filetypes used for Bazel/Starlark files. Neovim's builtin detection uses
-- `bzl`; `bazel`/`starlark` are included for custom setups.
local FILETYPES = { bzl = true, bazel = true, starlark = true }

local ROOT_MARKERS = { "MODULE.bazel", "WORKSPACE.bazel", "WORKSPACE", "WORKSPACE.bzlmod", ".git" }

---@param bufnr integer
local function attach(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not FILETYPES[vim.bo[bufnr].filetype] then
    return
  end
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(bufnr, ROOT_MARKERS)
    or (fname ~= "" and vim.fs.dirname(fname))
    or vim.uv.cwd()

  vim.lsp.start({
    name = "bazel-symbols",
    cmd = make_server,
    root_dir = root,
    -- Tree-sitter reports byte columns; tell the client to treat them as bytes
    -- so jumps land on the right column for non-ASCII target names too.
    offset_encoding = "utf-8",
  }, { bufnr = bufnr })
end

function M.setup()
  -- We rely on the Python Tree-sitter parser; bail quietly if it's missing.
  if not pcall(vim.treesitter.language.add, "python") then
    return
  end

  local group = vim.api.nvim_create_augroup("BazelSymbolsLsp", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = vim.tbl_keys(FILETYPES),
    callback = function(args)
      attach(args.buf)
    end,
  })

  -- starpls also answers documentSymbol (with weaker, untyped results). Suppress
  -- it so the picker doesn't show every target twice — ours wins.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "starpls" then
        client.server_capabilities.documentSymbolProvider = false
      end
    end,
  })

  -- Catch buffers/clients that already exist when setup runs (startup args,
  -- restored sessions, config reloads).
  for _, client in ipairs(vim.lsp.get_clients({ name = "starpls" })) do
    client.server_capabilities.documentSymbolProvider = false
  end
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      attach(bufnr)
    end
  end
end

return M
