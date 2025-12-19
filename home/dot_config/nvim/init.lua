vim.cmd([[


" HACK: Don't scroll half-page up/down with Ctrl-u/Ctrl-d, use number+j/k instead
nnoremap <C-u> <Nop>
nnoremap <C-d> <Nop>
vnoremap <C-u> <Nop>
vnoremap <C-d> <Nop>

if exists('g:vscode')
  set shadafile=NONE
  " https://github.com/vscode-neovim/vscode-neovim/issues/602#issuecomment-1839802239
  set ve=onemore
  " HACK: Disable default marks in vscode-neovim since they are unusable
  nnoremap m <Nop>
  nnoremap ' <Nop>
  nnoremap ` <Nop>
  " HACK: Disable default folds in vscode-neovim since they are very buggy
  nnoremap z <Nop>
  vnoremap z <Nop>
  " HACK: Map V to $V to fix the weired cursor position in vscode-neovim
  nnoremap V $V
  " HACK: Disable default keymaps for formation
  vnoremap = <Nop>
  vnoremap == <Nop>
else
  set nu
  set incsearch
  set smartcase
  set autoindent
  set smarttab
  set nowrap
  colorscheme unokai
  " Resize splits if window got resized
  augroup resize_splits
    autocmd!
    autocmd VimResized * wincmd =
  augroup END
endif


]])

if vim.g.vscode then
  local vscode = require('vscode')

  -- [[ Keymaps ]]
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- HACK: Save without formatting
  -- map('n', '<leader>w', function()
  --   vscode.action('workbench.action.files.saveWithoutFormatting')
  -- end, opts)

  -- HACK: Add keymaps for formatting
  -- map('n', '<leader>f', function()
  --   vscode.action('editor.action.formatDocument')
  -- end, opts)
  -- map('v', '<leader>f', function()
  --   vscode.action('editor.action.formatSelection')
  -- end, opts)

  -- HACK: Toggle folding
  -- map('n', 'zM', function()
  --   vscode.action('editor.foldAll')
  -- end, opts)
  -- map('n', 'zR', function()
  --   vscode.action('editor.unfoldAll')
  -- end, opts)
  -- map('n', 'zc', function()
  --   vscode.action('editor.fold')
  -- end, opts)
  -- map('n', 'zC', function()
  --   vscode.action('editor.foldRecursively')
  -- end, opts)
  -- map('n', 'zo', function()
  --   vscode.action('editor.unfold')
  -- end, opts)
  -- map('n', 'zO', function()
  --   vscode.action('editor.unfoldRecursively')
  -- end, opts)
  map('n', 'za', function() vscode.action('editor.toggleFold') end, opts)
  map('v', 'za', function() vscode.action('editor.toggleFold') end, opts)

  -- HACK: Toggle git changes
  -- map('v', '<leader>g', function()
  --   vscode.action('git.revertSelectedRanges')
  -- end, opts)
  -- map('n', '<leader>g', function()
  --   vscode.action('git.revertSelectedRanges')
  -- end, opts)

  -- HACK: Toggle bookmarks
  -- map('n', '<leader>b', function()
  --   vscode.action('bookmarks.toggle')
  -- end, opts)
end
