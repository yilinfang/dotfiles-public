MISE_BIN := $(HOME)/.local/bin/mise
MISE_DEFAULT_CONFIG_PATH := $(HOME)/.config/mise/config.toml
MISE_INSTALL_CMD := curl https://mise.run | sh
CHEZMOI := $(MISE_BIN) exec chezmoi age -- chezmoi
CHEZMOI_DOTFILES_PATH := $(HOME)/.chezmoi/dotfiles


.PHONY: ensure_mise install pde_install claude opencode

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

install: ensure_mise claude opencode
	@echo "Installing dotfiles..."
	$(CHEZMOI) init --apply -S $(CHEZMOI_DOTFILES_PATH)
	$(MISE_BIN) install
	$(MISE_BIN) upgrade
	bash scripts/pde/setup-git.sh

pde_install: ensure_mise claude opencode
	@echo "Installing PDE-specific dotfiles..."
	IS_PDE=true $(CHEZMOI) init --apply -S $(CHEZMOI_DOTFILES_PATH)
	$(MISE_BIN) install
	$(MISE_BIN) upgrade
	bash scripts/pde/setup-shell.sh
	bash scripts/pde/setup-git.sh

claude:
	@if command -v claude >/dev/null 2>&1; then \
		echo "Updating Claude Code..."; \
		claude update; \
	else \
		echo "Installing Claude Code..."; \
		curl -fsSL https://claude.ai/install.sh | bash; \
	fi
	@mkdir -p $(HOME)/.claude; \
	if [ ! -f "$(HOME)/.claude/settings.json" ]; then \
		echo "Installing Claude settings.json..."; \
		cp assets/claude/settings.json "$(HOME)/.claude/settings.json"; \
	else \
		echo "Merging Claude settings.json with existing file..."; \
		if command -v nvim >/dev/null 2>&1; then \
			MERGE_TOOL="nvim -d"; \
		elif command -v vimdiff >/dev/null 2>&1; then \
			MERGE_TOOL="vimdiff"; \
		else \
			MERGE_TOOL="diff -u"; \
		fi; \
		$$MERGE_TOOL "$(HOME)/.claude/settings.json" assets/claude/settings.json || true; \
	fi

opencode:
	@if command -v opencode >/dev/null 2>&1; then \
		echo "Updating OpenCode..."; \
		opencode upgrade; \
	else \
		echo "Installing OpenCode..."; \
		curl -fsSL https://opencode.ai/install | bash; \
	fi
	@mkdir -p $(HOME)/.config/opencode; \
	if [ ! -f "$(HOME)/.config/opencode/opencode.jsonc" ]; then \
		echo "Installing OpenCode opencode.jsonc..."; \
		cp assets/opencode/opencode.jsonc "$(HOME)/.config/opencode/opencode.jsonc"; \
	else \
		echo "Merging OpenCode opencode.jsonc with existing file..."; \
		if command -v nvim >/dev/null 2>&1; then \
			MERGE_TOOL="nvim -d"; \
		elif command -v vimdiff >/dev/null 2>&1; then \
			MERGE_TOOL="vimdiff"; \
		else \
			MERGE_TOOL="diff -u"; \
		fi; \
		$$MERGE_TOOL "$(HOME)/.config/opencode/opencode.jsonc" assets/opencode/opencode.jsonc || true; \
	fi
