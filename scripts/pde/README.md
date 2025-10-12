# Scripts for Setting up PDE

## Usage

```bash
# Install
bash <(curl -fsSL https://raw.githubusercontent.com/yilinfang/dotfiles-public/refs/heads/main/scripts/install.sh)
rm -rf ~/.config/chezmoi
rm -rf ~/.local/share/chezmoi
rm -rf ~/.chezmoi
IS_PDE=true chezmoi init --apply https://github.com/yilinfang/dotfiles-public.git -S ~/.chezmoi/dotfiles
chezmoi cd
cd scripts/pde
bash ./setup-shell.sh
bash ./install-mise.sh
bash ./install-tools.sh
# Optional
bash ./setup-git.sh
bash ./build-git-linux.sh
bash ./build-tmux-linux.sh
```
