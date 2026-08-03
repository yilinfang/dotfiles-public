-- lua/custom/code-agents.lua
local M = {}

function M.copy_selection_ref(relative)
  local filepath = relative and vim.fn.expand('%:.') or vim.fn.expand('%:p')
  local line1 = vim.fn.line('v')
  local line2 = vim.fn.line('.')
  local start_line = math.min(line1, line2)
  local end_line = math.max(line1, line2)

  local ref
  if start_line == end_line then
    ref = string.format('%s:%d', filepath, start_line)
  else
    ref = string.format('%s:%d-%d', filepath, start_line, end_line)
  end

  vim.fn.setreg('+', ref)
  vim.notify('Copied: ' .. ref, vim.log.levels.INFO)
end

function M.setup()
  vim.keymap.set('v', '<leader>cr', function()
    M.copy_selection_ref(true)
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end, { desc = '[C]opy relative code [r]eference for coding agents' })

  vim.keymap.set('v', '<leader>cR', function()
    M.copy_selection_ref(false)
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end, { desc = 'Copy absolute code [r]eference for coding agents' })
end

return M
