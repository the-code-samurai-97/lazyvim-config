-- cppman
return {
  {
    "madskjeldgaard/cppman.nvim",
    requires = {
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      local cppman = require("cppman")
      cppman.setup()

      -- Open search box
      vim.keymap.set("n", "<leader>cc", function()
        cppman.input()
      end)
    end,
  },
}
