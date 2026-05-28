# dotfiles-public

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

_NOTE: I may occasionally create conflicts in this repository by force pushing or rewriting history._
_This happens when I accidentally commit some sensitive data._

_NOTE: This repository assumes its chezmoi source directory is `~/.chezmoi/dotfiles`. That path is hardcoded in several places — the `sourceDir` and Age key paths in `home/.chezmoi.toml.tmpl`, `home/.chezmoiscripts/run_before_decrypt-private-key.sh`, the helper scripts in `bin/`, and the `PATH` entry in `scripts/init/init.{sh,zsh}`. The commands below already pass `-S ~/.chezmoi/dotfiles`; keep that path (or update those references if you relocate it)._

## Usage

### Install tools

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/yilinfang/dotfiles-public/refs/heads/main/scripts/install.sh)
```

### Install dotfiles

```bash
# Remove existing chezmoi config
rm -rf ~/.config/chezmoi
# Remove existing chezmoi data
rm -rf ~/.local/share/chezmoi
rm -rf ~/.chezmoi/dotfiles
# Install dotfiles
chezmoi init --apply https://github.com/yilinfang/dotfiles-public.git -S ~/.chezmoi/dotfiles
# Setup shell
chezmoi cd
bash scripts/pde/setup-shell.sh
```

### Install via mise

```bash
# Install mise if you don't have it
curl https://mise.run | sh
# Remove existing chezmoi config
rm -rf ~/.config/chezmoi
# Remove existing chezmoi data
rm -rf ~/.local/share/chezmoi
rm -rf ~/.chezmoi/dotfiles
# Install dotfiles
mise exec age chezmoi -- chezmoi init --apply https://github.com/yilinfang/dotfiles-public.git -S ~/.chezmoi/dotfiles
# Setup shell
mise exec chezmoi -- chezmoi cd
bash scripts/pde/setup-shell.sh
```

### Install via make (recommended)

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

### Quick install (minimal dotfiles)

Install only essential config files (.vimrc, .tmux.conf) directly to your home directory.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/yilinfang/dotfiles-public/refs/heads/main/scripts/install_quick.sh)
```

_NOTE: Existing files will be backed up with a `.backup_YYYYMMDD_HHMMSS` suffix._
