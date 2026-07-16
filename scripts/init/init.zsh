#!/usr/bin/env zsh

# init.zsh
# This script initializes the Zsh shell environment

# Add $HOME/.local/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

# Add chezmoi dotfiles bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.chezmoi/dotfiles/bin:"* ]]; then
	export PATH="$HOME/.chezmoi/dotfiles/bin:$PATH"
fi

# Add opencode to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.opencode/bin:"* ]]; then
	export PATH="$HOME/.opencode/bin:$PATH"
fi

# Define an alias only if the name is not already taken (command, builtin,
# alias, or function). Warns and skips on collision instead of clobbering.
safe_alias() {
	if command -v -- "$1" >/dev/null 2>&1; then
		printf 'safe_alias: skipping %s (already defined)\n' "$1" >&2
		return
	fi
	alias "$1=$2"
}

# If mise is installed, activate it
if command -v mise &>/dev/null; then
	eval "$(mise activate zsh)"
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
	safe_alias n 'nvim'
	# alias vim='nvim'
fi

# If rg is installed
if command -v rg &>/dev/null; then
	# export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
	safe_alias rgv 'rg --vimgrep'
	safe_alias brg 'rg --smart-case --max-columns=150 --max-columns-preview'
fi

# If bat is installed
if command -v bat &>/dev/null; then
	safe_alias bcat 'bat --color=always --paging=never --style=plain'
fi

# # If bat or delta is installed, set BAT_THEME
# if command -v bat &>/dev/null || command -v delta &>/dev/null; then
# 	export BAT_THEME="ansi"
# fi

# Use t for tmux
if command -v tmux &>/dev/null; then
	safe_alias t 'tmux'
	safe_alias ta 'tmux a'
	safe_alias tl 'tmux ls'
	safe_alias tns 'tmux new -s'
	safe_alias tat 'tmux attach -t'
fi

# Use lg for lazygit
if command -v lazygit &>/dev/null; then
	safe_alias lg 'lazygit'
fi

# Use zj for zellij
if command -v zellij &>/dev/null; then
	safe_alias zj 'zellij'
fi

# Use h for herdr
if command -v herdr &>/dev/null; then
	safe_alias h 'herdr'
	safe_alias hss 'herdr server stop'
	safe_alias hsr 'herdr server reload-config'
fi

# Use oc for opencode
if command -v opencode &>/dev/null; then
	safe_alias oc 'opencode'
fi

# Alias for codex
if command -v codex &>/dev/null; then
	safe_alias c 'codex -s danger-full-access -a on-request'
	safe_alias cm 'codex -s danger-full-access -a on-request -c model=gpt-5.6-sol -c model_reasoning_effort=medium -c plan_mode_reasoning_effort=medium'
	safe_alias ch 'codex -s danger-full-access -a on-request -c model=gpt-5.6-sol -c model_reasoning_effort=high -c plan_mode_reasoning_effort=high'
	safe_alias cq 'codex -s danger-full-access -a on-request -c model=gpt-5.6-luna -c model_reasoning_effort=medium -c plan_mode_reasoning_effort=medium'
fi

# # Use c for claude
# if command -v claude &>/dev/null; then
# 	safe_alias c 'claude'
# 	safe_alias co 'claude --model opus'
# 	safe_alias cs 'claude --model sonnet'
# 	safe_alias ch 'claude --model haiku'
# fi

# # Create wrappers for claude
# if command -v claude &>/dev/null; then
# 	# Use cld for claude
# 	alias cld='claude'
# 	# # MiniMax Provider
# 	# SECRETS_MINIMAX_ENV="$HOME/.secrets/claude_code_with_minimax.env"
# 	# if [ -f "$SECRETS_MINIMAX_ENV" ]; then
# 	# 	# Claude Code with MiniMax
# 	# 	function cldm() (
# 	# 		set -a
# 	# 		source "$SECRETS_MINIMAX_ENV"
# 	# 		set +a
# 	# 		export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"
# 	# 		export API_TIMEOUT_MS="3000000"
# 	# 		export ANTHROPIC_SMALL_FAST_MODEL="MiniMax-M2.5"
# 	# 		export ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.5"
# 	# 		export ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.5"
# 	# 		export ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.5"
# 	# 		command claude "$@"
# 	# 	)
# 	# fi
# 	# # Z.ai Provider
# 	# SECRETS_ZAI_ENV="$HOME/.secrets/claude_code_with_zai.env"
# 	# if [ -f "$SECRETS_ZAI_ENV" ]; then
# 	# 	# Claude Code with GLM models
# 	# 	function cldg() (
# 	# 		set -a
# 	# 		source "$SECRETS_ZAI_ENV"
# 	# 		set +a
# 	# 		command claude "$@"
# 	# 	)
# 	# fi
# 	# # NanoGPT Provider
# 	# SECRETS_NANOGPT_ENV="$HOME/.secrets/claude_code_with_nanogpt.env"
# 	# if [ -f "$SECRETS_NANOGPT_ENV" ]; then
# 	# 	# Claude Code with GLM 4.7
# 	# 	function cldg() (
# 	# 		set -a
# 	# 		source "$SECRETS_NANOGPT_ENV"
# 	# 		set +a
# 	# 		export ANTHROPIC_DEFAULT_SONNET_MODEL="zai-org/glm-4.7:thinking"
# 	# 		export ANTHROPIC_DEFAULT_OPUS_MODEL="zai-org/glm-4.7:thinking"
# 	# 		export ANTHROPIC_DEFAULT_HAIKU_MODEL="zai-org/GLM-4.5-Air"
# 	# 		export CLAUDE_CODE_SUBAGENT_MODEL="zai-org/GLM-4.5-Air"
# 	# 		command claude "$@"
# 	# 	)
# 	# fi
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
	source <(fzf --zsh)

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

# # Initialize starship if installed
# if command -v starship &>/dev/null; then
# 	eval "$(starship init zsh)"
# fi

# Initialize zoxide if installed
if command -v zoxide &>/dev/null; then
	eval "$(zoxide init zsh)"
fi
