if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Homebrew
fish_add_path -g /opt/homebrew/bin
fish_add_path -g /opt/homebrew/sbin

# Add $HOME/.local/bin to PATH
fish_add_path -g $HOME/.local/bin

# Set XDG_CONFIG_HOME to "$HOME/.config" if not already set
if not set -q XDG_CONFIG_HOME
    set -gx XDG_CONFIG_HOME $HOME/.config
end

# 'bls' a better 'ls' using 'eza' if available
if command -v eza >/dev/null
    alias bls='eza --color=always --icons=always --group-directories-first'
    alias la='bls -a'
    alias ll='bls -l'
    alias lla='ll -a'
    alias lt='bls -l --tree --level=2 --git'
    alias lta='lt -a'
    alias l='lla'
end

# 'kssh' is a better 'ssh' provided by kitten
if command -v kitten >/dev/null
    function kssh
        kitten ssh $argv
    end
    complete --command kssh --wraps ssh
end

if test -f "$HOME/.chezmoi/dotfiles/scripts/init/init.fish"
    source "$HOME/.chezmoi/dotfiles/scripts/init/init.fish"
end
