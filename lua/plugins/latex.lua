return {
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      -- Use latexmk with XeLaTeX
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-xelatex", -- force XeLaTeX for all files
      }
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-xelatex",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- Use a dedicated PDF viewer (recommended)
      vim.g.vimtex_view_method = "zathura" -- or "evince", "okular", etc.
      -- If you must use general:
      -- vim.g.vimtex_view_general_viewer = "xdg-open"
      -- vim.g.vimtex_view_general_options = "%o"
    end,
  },
}
