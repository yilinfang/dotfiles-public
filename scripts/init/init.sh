#!/usr/bin/env bash

# init.sh
# This script initializes the Bash shell environment

# Add $HOME/.local/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

# Create a wrapper for claude
if command -v claude &>/dev/null; then
	SECRET_ENV_FILE="$HOME/.secrets/claude_code_with_minimax.env"
	if [ -f "$SECRET_ENV_FILE" ]; then
		function mclaude() (
			# Set environment variables from secret environment file
			set -a
			source "$SECRET_ENV_FILE"
			set +a
			command claude "$@"
		)
	fi
fi

# If mise is installed, activate it
if command -v mise &>/dev/null; then
	eval "$(mise activate bash)"
	# export MISE_DISABLE_BACKENDS=asdf # Disable some backends (comma separated)
	# export MISE_PYTHON_COMPILE=false  # Always download pre-compiled python binaries
fi

# # If micro is installed, set it as the default editor
# if command -v micro &>/dev/null; then
# 	export EDITOR=micro
# 	export VISUAL=micro
# 	alias e='micro'
# fi

# If nvim is installed, set it as the default editor
if command -v nvim &>/dev/null; then
	export EDITOR=nvim
	export VISUAL=nvim
	alias vim='nvim'
fi

# If rg is installed
if command -v rg &>/dev/null; then
	export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
	alias rgv='rg --vimgrep'
	alias brg='rg --smart-case --max-columns=150 --max-columns-preview'
fi

# If bat is installed
if command -v bat &>/dev/null; then
	alias bcat='bat --color=always --paging=never --style=plain'
fi

# If bat or delta is installed, set BAT_THEME
if command -v bat &>/dev/null || command -v delta &>/dev/null; then
	export BAT_THEME="ansi"
fi

# Use lg for lazygit
if command -v lazygit &>/dev/null; then
	alias lg='lazygit'
fi

# # Use zj for zellij
# if command -v zellij &>/dev/null; then
# 	alias zj='zellij'
# fi

# Use y for yazi wrapper
if command -v yazi &>/dev/null; then
	function y() {
		local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
		yazi "$@" --cwd-file="$tmp"
		IFS= read -r -d '' cwd <"$tmp"
		[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
		rm -f -- "$tmp"
	}
fi

# Initialize fzf if installed
if command -v fzf &>/dev/null; then
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
fi

# Initialize starship if installed
if command -v starship &>/dev/null; then
	eval "$(starship init bash)"
fi

# Initialize zoxide if installed
if command -v zoxide &>/dev/null; then
	eval "$(zoxide init bash)"
fi
