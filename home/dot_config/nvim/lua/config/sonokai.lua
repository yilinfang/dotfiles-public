-- lua/config/sonokai.lua
-- Configuration of `sonokai` colorscheme

-- Force enable the truecolor support
vim.o.termguicolors = true

-- Config `sonokai`
vim.g.sonokai_style = 'default'
vim.g.sonokai_disable_italic_comment = 0
vim.g.sonokai_enable_italic = 1
vim.g.sonokai_cursor = 'auto'
vim.g.sonokai_transparent_background = 0
vim.g.sonokai_dim_inactive_windows = 0
vim.g.sonokai_menu_selection_background = 'green'
vim.g.sonokai_spell_foreground = 'none'
vim.g.sonokai_show_eob = 1
vim.g.sonokai_float_style = 'blend'
vim.g.sonokai_diagnostic_text_highlight = 0
vim.g.sonokai_diagnostic_line_highlight = 0
vim.g.sonokai_diagnostic_virtual_text = 'colored'
vim.g.sonokai_current_word = 'grey background'
vim.g.sonokai_inlay_hints_background = 'none'
vim.g.sonokai_disable_terminal_colors = 0
vim.g.sonokai_better_performance = 1

-- -- HACK: Fix highlights for other plugins
-- vim.api.nvim_create_autocmd('ColorScheme', {
--   pattern = 'sonokai',
--   group = vim.api.nvim_create_augroup('sonokai_custom_highlight', { clear = true }),
--   callback = function()
--     local get_hl = vim.api.nvim_get_hl
--     local set_hl = vim.api.nvim_set_hl
--
--     -- HACK: Fix colors for `copilot.vim` with Comment highlight but inverted italic setting
--     local comment_hl = get_hl(0, { name = 'Comment' })
--     set_hl(0, 'CopilotSuggestion', { fg = comment_hl.fg, italic = not comment_hl.italic })
--
--     -- HACK: Fix colors for lua/custom/statuscolumn.lua with CursorLineNr highlight
--     local curlineNr_hl = get_hl(0, { name = 'CursorLineNr' })
--     set_hl(0, 'StatusColumnMark', { fg = curlineNr_hl.fg })
--   end,
-- })

vim.cmd.colorscheme('sonokai')
