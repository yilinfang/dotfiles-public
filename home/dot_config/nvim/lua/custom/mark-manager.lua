-- lua/custom/mark-manager.lua
-- Manage marks in Neovim

local M = {}

-- Delete mark for current line
-- Includeing global marks (A-Z)
function M.delete_line_marks()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]

  -- Get all marks for the current buffer
  local marks = vim.fn.getmarklist(bufnr)
  local global_marks = vim.fn.getmarklist()

  local marks_to_delete = {}

  -- Check buffer-local marks (a-z)
  for _, mark in ipairs(marks) do
    if mark.pos[2] == lnum and mark.mark:match("^'[a-z]$") then
      table.insert(marks_to_delete, mark.mark:sub(2, 2))
    end
  end

  -- Check global marks (A-Z)
  for _, mark in ipairs(global_marks) do
    if
      mark.pos[1] == bufnr
      and mark.pos[2] == lnum
      and mark.mark:match("^'[A-Z]$")
    then
      table.insert(marks_to_delete, mark.mark:sub(2, 2))
    end
  end

  -- Delete found marks
  if #marks_to_delete > 0 then
    for _, mark_char in ipairs(marks_to_delete) do
      vim.cmd('delm ' .. mark_char)
    end
    vim.notify('Deleted marks: ' .. table.concat(marks_to_delete, ', '))
  else
    vim.notify('No marks found on current line')
  end
end

-- Delete local marks for current buffer
-- Not includes global marks (A-Z)
function M.delete_local_marks() vim.cmd('delm!') end

-- Delete global marks
function M.delete_global_marks() vim.cmd('delm A-Z') end

function M.setup()
  -- Register the commands
  vim.api.nvim_create_user_command(
    'DeleteLineMarks',
    function() M.delete_line_marks() end,
    {
      desc = 'Remove marks in the current line (including global marks)',
    }
  )

  vim.api.nvim_create_user_command(
    'DeleteLocalMarks',
    function() M.delete_local_marks() end,
    {
      desc = 'Remove local marks in the current buffer (excluding global marks)',
    }
  )

  vim.api.nvim_create_user_command(
    'DeleteGlobalMarks',
    function() M.delete_global_marks() end,
    {
      desc = 'Remove all global marks (A-Z)',
    }
  )
end

return M
