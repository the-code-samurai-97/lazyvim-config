return {
  "nvimtools/none-ls.nvim",
  opts = {
    sources = {
      require("null-ls").builtins.formatting.buildifier,
    },
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr })
          end,
        })
      end
    end,
  },
}
