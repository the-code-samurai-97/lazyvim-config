-- ~/.config/nvim/after/ftplugin/cpp.lua
-- Doxygen math highlighting for C++ in Neovim (Lua-native)

-- Set conceallevel for current buffer
vim.wo.conceallevel = 2

-- Helper function to match regex and highlight
local function highlight_math(pattern, hl_group, conceal)
  vim.fn.matchadd(hl_group, pattern, 10, -1)
  if conceal then
    vim.fn.matchadd("Conceal", pattern)
  end
end

-- Inline math: \f$ ... \f$
highlight_math("\\\\f\\$.*\\\\f\\$", "String", true)

-- Display math: \f[ ... \f]
highlight_math("\\\\f\\[.*\\\\\\]", "String", true)
