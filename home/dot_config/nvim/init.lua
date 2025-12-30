-- Load ~/.vimrc for regular Neovim
vim.cmd([[ source $HOME/.vimrc ]])
-- Configurations for vscode-neovim
-- It is highly recommended to add following keybindings to your VSCode keybindings.json:
-- https://gist.github.com/yilinfang/f104c4a2903b9ddde5d523909c5485da
if vim.g.vscode then
  vim.cmd([[
    set mouse=
    set shadafile=NONE
    " https://github.com/vscode-neovim/vscode-neovim/issues/602#issuecomment-1839802239
    set ve=onemore
  ]])
  local vscode = require("vscode")
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }
  local disable_keymap = function(mode, key)
    map(mode, key, "<Nop>", opts)
  end
  -- Disable default marks in vscode-neovim since they are unusable
  disable_keymap({ "n", "v" }, "m")
  disable_keymap({ "n", "v" }, "'")
  disable_keymap({ "n", "v" }, "`")
  -- Map V to $V to fix the weired cursor position in vscode-neovim
  map("n", "V", "$V", opts)
  -- Disable default keymaps for formation
  disable_keymap({ "n", "v" }, "=")
  disable_keymap({ "n", "v" }, "==")
  -- Disable default <C-i> and <C-o> in vscode-neovim's normal mode since they are buggy now
  disable_keymap({ "n" }, "<C-i>")
  disable_keymap({ "n" }, "<C-o>")
  -- Fix folding in vscode-neovim
  -- Disable default folding keymaps
  local folding_keys = {
    "zf",
    "zF",
    "zd",
    "zD",
    "zE",
    "zo",
    "zO",
    "zc",
    "zC",
    "za",
    "zA",
    "zv",
    "zx",
    "zX",
    "zm",
    "zM",
    "zr",
    "zR",
    "zn",
    "zN",
    "zi",
    "[z",
    "]z",
    "zk",
  }
  for _, key in ipairs(folding_keys) do
    disable_keymap({ "n", "v" }, key)
  end
  map("n", "za", function()
    vscode.call("editor.toggleFold")
  end, opts)
end
