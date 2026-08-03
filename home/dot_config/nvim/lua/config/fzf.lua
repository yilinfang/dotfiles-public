-- lua/config/fzf.lua
-- Configuration for `fzf-lua`

local fzf = require('fzf-lua')

-- [[ Setup `fzf-lua` ]]
local opts = {
  'default', -- Use default profile
  winopts = {
    backdrop = 100, -- Disable backdrop dimming
    preview = {
      default = 'bat', -- Use `bat` as default previewer
      -- winopts = {
      --   number = false, -- Disbale line numbers in preview window
      -- },
    },
  },
  files = {
    hidden = true,
    follow = false,
    no_ignore = false,
    toggle_ignore_flag = '--no-ignore-vcs', -- Only ignore .gitignore
  },
  grep = {
    RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH, -- Use system ripgrep config
    hidden = true,
    follow = false,
    no_ignore = false,
    toggle_ignore_flag = '--no-ignore-vcs', -- Only ignore .gitignore
  },
  complete_path = {
    cmd = vim.env.FZF_CTRL_T_COMMAND or 'fd --hidden --no-ignore-vcs', -- Use fzf's ctrl-t command if set
  },
  previewers = {
    builtin = {
      -- HACK: Disable treesitter since it is buggy
      treesitter = { enabled = false },
      -- HACK: Disable image previewer
      extensions = nil,
      snacks_image = { enabled = false },
    },
  },
}
fzf.setup(opts)

-- Registration ui select with fzf-lua
-- HACK: Customize the UI select appearance
fzf.register_ui_select(function(ui_select_opts)
  ui_select_opts.prompt = '> '
  local title = 'Select'
  return {
    winopts = {
      title = ' ' .. title .. ' ',
    },
  }
end)

-- HACK: Create an autocmd to redraw the fzf window when the neovim window is resized
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Redraw fzf window on resize',
  group = vim.api.nvim_create_augroup('fzflua-redraw', { clear = true }),
  pattern = '*',
  callback = function() fzf.redraw() end,
})

-- [[ Keymaps ]]
vim.keymap.set(
  'n',
  '<leader><leader>',
  '<cmd>FzfLua lgrep_curbuf<cr>',
  { desc = "[' '] Grep Current Buffer" }
)
vim.keymap.set(
  'n',
  '<leader>,',
  '<cmd>FzfLua buffers<cr>',
  { desc = "[','] Open Buffer Manager" }
)
vim.keymap.set(
  'n',
  '<leader>.',
  '<cmd>FzfLua resume<cr>',
  { desc = "['.'] Resume Last Search" }
)
vim.keymap.set(
  'n',
  '<leader>sf',
  '<cmd>FzfLua files<cr>',
  { desc = '[S]earch [F]iles' }
)
vim.keymap.set(
  'n',
  '<leader>sg',
  '<cmd>FzfLua live_grep<cr>',
  { desc = '[S]earch [G]rep' }
)
vim.keymap.set(
  'n',
  '<leader>s.',
  '<cmd>FzfLua oldfiles<cr>',
  { desc = "[S]earch Old Files (['.'] for repeat)" }
)
vim.keymap.set(
  'n',
  '<leader>sm',
  '<cmd>FzfLua marks<cr>',
  { desc = '[S]earch [M]arks' }
)
vim.keymap.set(
  'n',
  '<leader>sj',
  '<cmd>FzfLua jumps<cr>',
  { desc = '[S]earch [J]umplist' }
)
vim.keymap.set(
  'n',
  '<leader>sp',
  '<cmd>FzfLua builtin<cr>',
  { desc = '[S]earch Builtin [P]ickers' }
)
vim.keymap.set(
  'i',
  '<C-t>',
  [[<cmd>FzfLua complete_path winopts.title="\ Path\ "<cr>]],
  { desc = 'Fuzzy complete path' }
)
