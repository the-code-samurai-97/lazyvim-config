return {
  "frabjous/knap",
  config = function()
    local gknapsettings = {
      rstoutputext = "html",
      rsttohtml = "rst2html '%docroot%/%filename%' '%outputfile%'",
      rsttohtmlviewerlaunch = "python3 -m webbrowser '%outputfile%'",
      rsttohtmlviewerrefresh = "none",
      delay = 250,
    }

    vim.g.knap_settings = gknapsettings

    -- Simple working preview function using default browser
    local function simple_rst_preview()
      if vim.bo.modified then
        vim.cmd("write")
      end

      local input = vim.fn.expand("%:p")
      local output = vim.fn.expand("%:p:r") .. ".html"

      local cmd = string.format("rst2html '%s' '%s'", input, output)
      local result = vim.fn.system(cmd)

      if vim.v.shell_error == 0 then
        -- Use Python's webbrowser module to open with default browser
        vim.fn.system("python3 -m webbrowser 'file://" .. output .. "' &")
        vim.notify("Preview opened in default browser", vim.log.levels.INFO)
      else
        vim.notify("Error: " .. result, vim.log.levels.ERROR)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rst",
      callback = function()
        vim.keymap.set("n", "<leader>cp", simple_rst_preview, { desc = "Preview RST", buffer = true })
      end,
    })
  end,

  keys = {
    {
      "<leader>cp",
      function()
        require("knap").process_once()
      end,
      desc = "Preview Document",
    },
    {
      "<leader>cP",
      function()
        require("knap").close_viewer()
      end,
      desc = "Close Preview",
    },
  },

  ft = { "rst" },
}
