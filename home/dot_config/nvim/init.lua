if vim.g.vscode then
  -- Configurations for vscode-neovim
  vim.cmd([[
    set shadafile=NONE
    nnoremap <leader>/ :noh<CR>
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
    " " HACK: Disable default <C-i> and <C-o> in vscode-neovim they are buggy now
    " nnoremap <C-i> <Nop>
    " nnoremap <C-o> <Nop>
  ]])
  local vscode = require("vscode")
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }
  -- Fix folding in vscode-neovim
  map("n", "za", function()
    vscode.action("editor.toggleFold")
  end, opts)
  -- -- Fix <C-i> and <C-o> in vscode-neovim
  -- map("n", "<C-i>", function()
  --   vscode.action("workbench.action.navigateForward")
  -- end, opts)
  -- map("n", "<C-o>", function()
  --   vscode.action("workbench.action.navigateBack")
  -- end, opts)
else
  -- Load ~/.vimrc for regular Neovim
  vim.cmd([[ source $HOME/.vimrc ]])
end
