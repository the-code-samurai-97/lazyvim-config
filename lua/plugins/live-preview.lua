return {
  "brianhuster/live-preview.nvim",
  opts = {
    port = 5500,
    browser = "default",
  },
  keys = {
    { "<leader>cp", "<cmd>LivePreview start<cr>", desc = "Start Live Preview" },
    { "<leader>cP", "<cmd>LivePreview stop<cr>", desc = "Stop Live Preview" },
  },
}
