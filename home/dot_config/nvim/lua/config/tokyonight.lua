-- lua/config/tokyonight.lua
-- Configuration for theme `tokyonight.nvim`

local tokyonight = require('tokyonight')
local opts = {
  style = 'night',
}
tokyonight.setup(opts)

vim.cmd.colorscheme('tokyonight')
