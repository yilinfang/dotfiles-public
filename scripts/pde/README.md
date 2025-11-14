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

## Usage (updated)

```bash
# Install mise if you don't have it
curl https://mise.run | sh
# Remove existing chezmoi config
rm -rf ~/.config/chezmoi
# Remove existing chezmoi data
rm -rf ~/.local/share/chezmoi
rm -rf ~/.chezmoi/dotfiles
# Install dotfiles
IS_PDE=true mise exec age chezmoi -- chezmoi init --apply https://github.com/yilinfang/dotfiles-public.git -S ~/.chezmoi/dotfiles
# Setup shell
mise exec chezmoi -- chezmoi cd
cd scripts/pde
bash ./setup-shell.sh
# Optional
bash ./setup-git.sh
bash ./build-git-linux.sh
bash ./build-tmux-linux.sh
```

## Usage (via make)

```bash
# Remove existing chezmoi config
rm -rf ~/.config/chezmoi
# Remove existing chezmoi data
rm -rf ~/.local/share/chezmoi
rm -rf ~/.chezmoi/dotfiles
# Download dotfiles via git
git clone https://github.com/yilinfang/dotfiles-public.git ~/.chezmoi/dotfiles
# Install dotfiles
cd ~/.chezmoi/dotfiles
make install
```
