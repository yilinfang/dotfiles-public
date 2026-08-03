--[[

Yilin Fang's Personal Neovim Configuration
Copyright (c) 2026 Yilin Fang

--]]

-- OPTIONS {{{

-- Leadey key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable some providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Clipboard
if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = 'Customized OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = function()
        local content = vim.fn.getreg('')
        return vim.split(content, '\n')
      end,
      ['*'] = function()
        local content = vim.fn.getreg('')
        return vim.split(content, '\n')
      end,
    },
  }
end

-- General options
vim.o.autoread = true
vim.o.breakindent = true
vim.o.confirm = true
vim.o.cursorline = true
vim.o.cursorlineopt = 'screenline,number'
vim.o.fillchars = 'fold:╌'
vim.o.ignorecase = true
vim.o.inccommand = 'split'
vim.o.linebreak = true
vim.o.mouse = 'a'
vim.o.number = true
vim.o.relativenumber = false
vim.o.scrolloff = 8
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.wrap = false

-- List chars
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Indentation
vim.o.autoindent = true
vim.o.copyindent = true
vim.o.expandtab = false
vim.o.preserveindent = true
vim.o.shiftround = true
vim.o.shiftwidth = 8
vim.o.smartindent = true
vim.o.softtabstop = 8
vim.o.tabstop = 8

-- Fold
vim.o.foldmethod = 'manual' -- Use manual fold method by default
vim.o.foldlevel = 99 -- Open all folds by default
vim.o.foldtext = '' -- Use default fold text

-- Signcolumn & Statuscolumn
vim.o.signcolumn = 'yes:1'
-- HACK: Minmal number of columns for line numbers
--  Set to 1 to only use essential columns for line numbers.
--  For example, if line number less than 100, it will only use 2 columns.
--  If line number is 100 or more, it will use 3 columns or more.
vim.o.numberwidth = 1
vim.o.statuscolumn = ' %=%l%s'

-- }}}

-- KEYMAPS {{{

vim.keymap.set(
  'n',
  '<leader>/',
  '<cmd>nohlsearch<CR>',
  { desc = 'Clear search highlighting' }
)
vim.keymap.set('n', '<leader>r', '<cmd>r!<CR>', { desc = 'Reload current buffer' })
vim.keymap.set(
  'v',
  '<leader>y',
  '"+y',
  { desc = 'Yank selection to system clipboard' }
)
vim.keymap.set(
  'n',
  '<leader>x',
  vim.diagnostic.setloclist,
  { desc = 'Open Diagnostic Quickfi[x] List' }
)
vim.keymap.set('n', 'gt', '<cmd>bnext<cr>', { desc = 'Go to next buffer' })
vim.keymap.set('n', 'gT', '<cmd>bprevious<cr>', { desc = 'Go to previous buffer' })
vim.keymap.set(
  'n',
  '<leader>f',
  function() vim.fn.setreg('+', vim.fn.expand('%:p')) end,
  { desc = 'Copy file path to system clipboard' }
)
vim.keymap.set(
  'n',
  '<leader>y',
  '<cmd>%y+<cr>',
  { desc = 'Yank entire buffer to system clipboard' }
)
vim.keymap.set('n', '<leader>ts', function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
  local status = vim.opt_local.spell:get() and 'ON' or 'OFF'
  print('Spell check: ' .. status)
end, { desc = '[T]oggle [S]pell Check' })
vim.keymap.set('n', '<leader>tw', function()
  vim.opt_local.wrap = not vim.opt_local.wrap:get()
  local status = vim.opt_local.wrap:get() and 'ON' or 'OFF'
  print('Wrap: ' .. status)
end, { desc = '[T]oggle [W]rap' })

-- HACK: Better up/down
--  From LazyVim: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
vim.keymap.set(
  { 'n', 'x' },
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { desc = 'Down', expr = true, silent = true }
)
vim.keymap.set(
  { 'n', 'x' },
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { desc = 'Up', expr = true, silent = true }
)

-- }}}

-- AUTOCMDS {{{

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Check for spell and wrap in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Check for spell in text filetypes',
  group = vim.api.nvim_create_augroup('spell-check-on-text', { clear = true }),
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
})

-- Automatically enable wrap for quickfix window
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable wrap for quickfix window',
  group = vim.api.nvim_create_augroup('quickfix-wrap', { clear = true }),
  pattern = 'qf',
  callback = function() vim.opt_local.wrap = true end,
})

-- HACK: Automatically resize splits when the window is resize
--  It will resize all splits to have equal height and width,
--  but not preserve the current size of splits.
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Automatically resize splits when the window is resized',
  group = vim.api.nvim_create_augroup('resize-splits', { clear = true }),
  command = 'windo wincmd = ',
})

-- }}}

-- USER MODULES {{{

-- Load my own plugins
require('custom.mark-manager').setup()
require('custom.code-agents').setup()

-- }}}

-- BOOTSTRAP & SETUP PLUGINS {{{

-- [[ Bootstrap lazy.nvim ]]
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Setup lazy.nvim ]]
require('lazy').setup({
  -- add your plugins here
  spec = {
    -- NOTE: Be careful with the order of setting up plugins!!!
    -- {
    --   'sainnhe/sonokai',
    --   lazy = false,
    --   priority = 1000, -- NOTE: load theme first
    --   config = function() require('config.sonokai') end,
    -- },
    {
      'folke/tokyonight.nvim',
      lazy = false,
      priority = 1000,
      config = function() require('config.tokyonight') end,
    },
    {
      'ibhagwan/fzf-lua',
      dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Icon support
      config = function() require('config.fzf') end,
    },
    {
      'tpope/vim-fugitive',
    },
    {
      'tpope/vim-sleuth',
      -- HACK: vim-sleuth won't work if lazy loaded
      lazy = false,
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- do not lazy-load plugin by default
  defaults = { lazy = false },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'habamax' } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- }}}

-- vi:se fdm=marker fmr={{{,}}} fdl=0:
