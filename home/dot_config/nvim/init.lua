vim.cmd([[

let mapleader = " "
let maplocalleader = " "

nnoremap <leader>/ :noh<CR>

if exists('g:vscode')
	set shadafile=NONE
	" https://github.com/vscode-neovim/vscode-neovim/issues/602#issuecomment-1839802239
	set ve=onemore
	" HACK: Disable default marks in vscode-neovim
	nnoremap m <Nop>
	" HACK: Disable default keymaps for formation
	vnoremap = <Nop>
	vnoremap == <Nop>
else
	set nowrap
	colorscheme torte
	vnoremap <leader>y "+y
	" Resize splits if window got resized
	augroup resize_splits
  		autocmd!
  		autocmd VimResized * wincmd =
	augroup END

endif

]])

if vim.g.vscode then
	local vscode = require("vscode")

	-- [[ Keymaps ]]
	local map = vim.keymap.set
	local opts = { noremap = true, silent = true }

	-- HACK: Save without formatting
	map("n", "<leader>w", function()
		vscode.action("workbench.action.files.saveWithoutFormatting")
	end, opts)

	-- HACK: Add keymaps for formatting
	map("n", "<leader>f", function()
		vscode.action("editor.action.formatDocument")
	end, opts)
	map("v", "<leader>f", function()
		vscode.action("editor.action.formatSelection")
	end, opts)

	-- HACK: Fix keymaps for folding
	map("n", "zM", function()
		vscode.action("editor.foldAll")
	end, opts)
	map("n", "zR", function()
		vscode.action("editor.unfoldAll")
	end, opts)
	map("n", "zc", function()
		vscode.action("editor.fold")
	end, opts)
	map("n", "zC", function()
		vscode.action("editor.foldRecursively")
	end, opts)
	map("n", "zo", function()
		vscode.action("editor.unfold")
	end, opts)
	map("n", "zO", function()
		vscode.action("editor.unfoldRecursively")
	end, opts)
	map("n", "za", function()
		vscode.action("editor.toggleFold")
	end, opts)

	-- TODO: Replace default marks with vscode bookmark extension
end
