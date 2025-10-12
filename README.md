# dotfiles-public

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

_NOTE: I may occasionally create conflicts in this repository by force pushing or rewriting history._
_This happens when I accidentally commit some sensitive data._

## Usage

### Install tools

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/yilinfang/dotfiles-public/refs/heads/main/scripts/install.sh)
```

### Install dotfiles

```bash
# Remove existing chezmoi config
rm -rf ~/.config/chezmoi
# Remove existing chezmoi data (optional)
rm -rf ~/.local/share/chezmoi
# Install dotfiles
chezmoi init --apply https://github.com/yilinfang/dotfiles-public.git -S ~/.chezmoi/dotfiles
```
