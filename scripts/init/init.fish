# init.fish
# This script initializes the Fish shell environment
# NOTE: Deprecated

# Add $HOME/.local/bin to PATH if not already present
fish_add_path -g $HOME/.local/bin # Automatically deduplicates

# If mise is installed, activate it
if command -v mise >/dev/null
    mise activate fish | source
    set -gx MISE_PIPX_UVX false # Use pipx instead of uvx by default
end

# If nvim is installed, set it as the default editor
if command -v nvim >/dev/null
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    alias n='nvim'
end

# If rg is installed
if command -v rg >/dev/null
    set -gx RIPGREP_CONFIG_PATH "$HOME/.ripgreprc"
    alias rgv='rg --vimgrep'
    alias brg='rg --smart-case --max-columns=150 --max-columns-preview'
end

# If bat is installed
if command -v bat >/dev/null
    alias bcat='bat --color=always --paging=never --style=plain'
end

# If bat or delta is installed, set BAT_THEME
if command -v bat >/dev/null or command -v delta >/dev/null
    set -gx BAT_THEME ansi
end

# Use g for git
if command -v git >/dev/null
    alias g='git'
end

# Use t for tmux
if command -v tmux >/dev/null
    alias t='tmux'
end

# Use lg for lazygit
if command -v lazygit >/dev/null
    alias lg='lazygit'
end

# # Use zj for zellij
# if command -v zellij >/dev/null
#     alias zj='zellij'
# end

# # Use y for yazi
# if command -v yazi >/dev/null
#     function y
#         set tmp (mktemp -t "yazi-cwd.XXXXXX")
#         yazi $argv --cwd-file="$tmp"
#         if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
#             builtin cd -- "$cwd"
#         end
#         rm -f -- "$tmp"
#     end
# end

# Create wrapper for lf
if command -v lf >/dev/null
    function lf
        env LF_OLD_PWD=(pwd) command lf $argv
    end
end

# Initialize fzf if installed
if command -v fzf >/dev/null
    fzf --fish | source

    # Check for fd or fdfind command
    if command -v fdfind >/dev/null
        set fd_command fdfind
    else if command -v fd >/dev/null
        set fd_command fd
    end

    # Set up fzf commands if fd/fdfind is available
    if set -q fd_command
        set -gx FZF_DEFAULT_COMMAND "$fd_command --strip-cwd-prefix --no-ignore-vcs --hidden"
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -gx FZF_ALT_C_COMMAND "$fd_command --type dir --strip-cwd-prefix --no-ignore-vcs --hidden"
    end
end

# Initialize zoxide if installed
if command -v zoxide >/dev/null
    zoxide init fish | source
end
