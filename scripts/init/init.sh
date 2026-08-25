#!/usr/bin/env bash

# init.sh
# This script initializes the Bash shell environment

# helper functions
source "$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/helpers.sh"

# The first added path has the lowest priority
add_path_without_duplicate "$HOME/.bun/bin"
add_path_without_duplicate "$HOME/.chezmoi/dotfiles/bin"
add_path_without_duplicate "$HOME/.local/bin"

# mise
eval "$(mise activate bash)"

# neovim
export EDITOR=nvim
export VISUAL=nvim
safe_alias n 'nvim'

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
safe_alias rgv 'rg --vimgrep'
safe_alias brg 'rg --smart-case --max-columns=150 --max-columns-preview'

# bat
safe_alias bcat 'bat --color=always --paging=never --style=plain'

# tmux
safe_alias t 'tmux'
safe_alias ta 'tmux a'
safe_alias tl 'tmux ls'
safe_alias tns 'tmux new -s'
safe_alias tat 'tmux attach -t'

# lazygit
safe_alias lg 'lazygit'

# herdr
safe_alias h 'herdr'
safe_alias hsr 'herdr server reload-config'
safe_alias hss 'herder-server-stop'
safe_alias hwcq 'herder-workspace-create-quick'

# claude
safe_alias c 'claude'
safe_alias cm 'claude --model opus --effort high'
safe_alias ch 'claude --model opus --effort xhigh'
safe_alias cl 'claude --model sonnet --effort high'
safe_alias cx 'claude --model fable --effort high'
safe_alias cr 'claude --resume'

# lfcd
LFCD="$HOME/.lf/lfcd.sh"
if [ -f "$LFCD" ]; then
	source "$LFCD"
fi

# fzf
eval "$(fzf --bash)"
# Check for fd or fdfind command
if command -v fdfind &>/dev/null; then
	FD_COMMAND='fdfind'
elif command -v fd &>/dev/null; then
	FD_COMMAND='fd'
fi
# Set up fzf commands if fd/fdfind is available
if [[ -n "$FD_COMMAND" ]]; then
	export FZF_DEFAULT_COMMAND="$FD_COMMAND --strip-cwd-prefix --no-ignore-vcs --hidden"
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND="$FD_COMMAND --type dir --strip-cwd-prefix --no-ignore-vcs --hidden"
fi

# zoxide
eval "$(zoxide init bash)"
