" Load vim configuration from .vimrc
source $HOME/.vimrc

" Neovim specific configurations
if has("termguicolors") " Enable termguicolors if terminal supports it
  set termguicolors
endif
colorscheme unokai
set list
set listchars=tab:▸\ ,trail:·,nbsp:␣
nnoremap <leader>y <cmd>%y+<cr>
