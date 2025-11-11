return {
  "hat0uma/doxygen-previewer.nvim",
  opts = {},
  dependencies = { "hat0uma/prelive.nvim" },
  cmd = {
    "DoxygenOpen",
    "DoxygenUpdate",
    "DoxygenStop",
    "DoxygenLog",
    "DoxygenTempDoxyfileOpen",
  },
  config = function()
    local dp = require("doxygen-previewer")

    -- Preprocess doxygen math to fix common issues
    local function preprocess_math(line)
      -- Fix \texttt{dst} [I] -> \texttt{dst[I]}
      line = line:gsub("\\texttt%{([%w_]+)%}%s*%[([%w_]+)%]", "\\texttt{%1[%2]}")
      -- Remove extra spaces inside \f[ ... \f] and \f$ ... \f$
      line = line:gsub("\\f%[%s*(.-)%s*\\f%]", "\\f[%1\\f]")
      line = line:gsub("\\f%$%s*(.-)%s*\\f%$", "\\f$%1\\f$")
      return line
    end

    -- Hook into the previewer renderer
    local orig_render = dp.render
    dp.render = function(bufnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      for i, line in ipairs(lines) do
        lines[i] = preprocess_math(line)
      end
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      orig_render(bufnr)
    end

    -- Setup doxygen-previewer
    dp.setup({
      tempdir = vim.fn.stdpath("cache"),
      update_on_save = true,
      doxygen = {
        cmd = "doxygen",
        doxyfile_patterns = { "Doxyfile", "doc/Doxyfile" },
        fallback_cwd = function()
          return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        end,
        override_options = {},
      },
    })
  end,
}
