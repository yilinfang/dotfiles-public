let mapleader = " "
let maplocalleader = " "

set nu
set autoindent
set smarttab
set nowrap
colorscheme torte 
vnoremap <leader>y "+y

augroup resize_splits
  autocmd!
  autocmd VimResized * wincmd =
augroup end
