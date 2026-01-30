MISE_BIN := $(HOME)/.local/bin/mise
MISE_DEFAULT_CONFIG_PATH := $(HOME)/.config/mise/config.toml
MISE_INSTALL_CMD := curl https://mise.run | sh
CHEZMOI := $(MISE_BIN) exec chezmoi age -- chezmoi
CHEZMOI_DOTFILES_PATH := $(HOME)/.chezmoi/dotfiles


.PHONY: ensure_mise install pde_install

ensure_mise:
	@if [ ! -f $(MISE_BIN) ]; then \
		echo "Installing mise..."; \
		$(MISE_INSTALL_CMD); \
	else \
		echo "mise already installed"; \
		$(MISE_BIN) self-update; \
	fi
	@if [ ! -f $(MISE_DEFAULT_CONFIG_PATH) ]; then \
		echo "Creating default mise config..."; \
		mkdir -p "$$(dirname "$(MISE_DEFAULT_CONFIG_PATH)")"; \
		touch "$(MISE_DEFAULT_CONFIG_PATH)"; \
	fi

install: ensure_mise
	@echo "Installing dotfiles..."
	$(CHEZMOI) init --apply -S $(CHEZMOI_DOTFILES_PATH)
	$(MISE_BIN) install
	$(MISE_BIN) upgrade
	bash scripts/pde/setup-git.sh

pde_install: ensure_mise
	@echo "Installing PDE-specific dotfiles..."
	IS_PDE=true $(CHEZMOI) init --apply -S $(CHEZMOI_DOTFILES_PATH)
	$(MISE_BIN) install
	$(MISE_BIN) upgrade
	bash scripts/pde/setup-shell.sh
	bash scripts/pde/setup-git.sh