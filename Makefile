MISE_BIN := $(HOME)/.local/bin/mise
MISE_DEFAULT_CONFIG_PATH := $(HOME)/.config/mise/config.toml
MISE_INSTALL_CMD := curl https://mise.run | sh
# Uses mise to provide chezmoi and age binaries
CHEZMOI := $(MISE_BIN) exec chezmoi age -- chezmoi
CHEZMOI_DOTFILES_PATH := $(HOME)/.chezmoi/dotfiles

# Merge or diff two files using the best available tool
# Usage: $(call merge_files,existing,new)
define merge_files
	if command -v nvim >/dev/null 2>&1; then \
		MERGE_TOOL="nvim -d"; \
	elif command -v vimdiff >/dev/null 2>&1; then \
		MERGE_TOOL="vimdiff"; \
	else \
		MERGE_TOOL="diff -u"; \
	fi; \
	$$MERGE_TOOL $(1) $(2) || true
endef

.PHONY: ensure_mise install pde_install claude opencode codex vscode cursor

.IGNORE: install pde_install

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
		$(call merge_files,"$(HOME)/.claude/settings.json",assets/claude/settings.json); \
	fi

opencode:
# @if command -v opencode >/dev/null 2>&1; then \
# 	echo "Updating OpenCode..."; \
# 	opencode upgrade; \
# else \
# 	echo "Installing OpenCode..."; \
# 	curl -fsSL https://opencode.ai/install | bash; \
# fi
	@if ! command -v opencode >/dev/null 2>&1; then \
		echo "Installing OpenCode..."; \
		if command -v mise >/dev/null 2>&1; then \
			mise use -g npm:opencode-ai; \
		elif command -v npm >/dev/null 2>&1; then \
			npm install -g opencode-ai; \
		else \
			echo "Error: neither mise nor npm is available. Please install one of them to install OpenCode." >&2; \
			exit 1; \
		fi; \
	else \
		echo "OpenCode already installed"; \
	fi
	@mkdir -p $(HOME)/.config/opencode; \
	if [ ! -f "$(HOME)/.config/opencode/opencode.jsonc" ]; then \
		echo "Installing OpenCode opencode.jsonc..."; \
		cp assets/opencode/opencode.jsonc "$(HOME)/.config/opencode/opencode.jsonc"; \
	else \
		echo "Merging OpenCode opencode.jsonc with existing file..."; \
		$(call merge_files,"$(HOME)/.config/opencode/opencode.jsonc",assets/opencode/opencode.jsonc); \
	fi

codex:
	@if ! command -v codex >/dev/null 2>&1; then \
		echo "Installing Codex..."; \
		if command -v mise >/dev/null 2>&1; then \
			mise use -g npm:@openai/codex; \
		elif command -v npm >/dev/null 2>&1; then \
			npm install -g @openai/codex; \
		else \
			echo "Error: neither mise nor npm is available. Please install one of them to install Codex." >&2; \
			exit 1; \
		fi; \
	else \
		echo "Codex already installed"; \
	fi
	@mkdir -p $(HOME)/.codex; \
	if [ ! -f "$(HOME)/.codex/config.toml" ]; then \
		echo "Installing Codex config.toml..."; \
		cp assets/codex/config.toml "$(HOME)/.codex/config.toml"; \
	else \
		echo "Merging Codex config.toml with existing file..."; \
		$(call merge_files,"$(HOME)/.codex/config.toml",assets/codex/config.toml); \
	fi
# Optional Codex auth install flow, kept for future reference
# @mkdir -p "$(HOME)/.codex"
# @if [ -f "$(HOME)/.codex/auth.json" ]; then \
# 	echo "Codex auth.json already exists."; \
# 	read -r -p "Overwrite Codex auth.json from encrypted asset? [y/N] " resp; \
# 	case "$$resp" in \
# 		[yY][eE][sS]|[yY]) \
# 		echo "Overwriting Codex auth.json..."; \
# 		age -d -o "$(HOME)/.codex/auth.json" "assets/codex/auth.json.age" && chmod 600 "$(HOME)/.codex/auth.json"; \
# 		;; \
# 		*) \
# 		echo "Skipping Codex auth.json installation."; \
# 		;; \
# 	esac; \
# else \
# 	read -r -p "Install Codex auth.json from encrypted asset? [y/N] " resp; \
# 	case "$$resp" in \
# 		[yY][eE][sS]|[yY]) \
# 		echo "Installing Codex auth.json..."; \
# 		age -d -o "$(HOME)/.codex/auth.json" "assets/codex/auth.json.age" && chmod 600 "$(HOME)/.codex/auth.json"; \
# 		;; \
# 		*) \
# 		echo "Skipping Codex auth.json installation."; \
# 		;; \
# 	esac; \
# fi

vscode:
	@echo "Installing extensions for VS Code..."
	@if command -v code >/dev/null 2>&1; then \
		python3 scripts/install-vscode-extensions.py --editor code; \
	else \
		echo "code not found, skipping."; \
	fi

cursor:
	@echo "Installing extensions for Cursor..."
	@if command -v cursor >/dev/null 2>&1; then \
		python3 scripts/install-vscode-extensions.py --editor cursor; \
	else \
		echo "cursor not found, skipping."; \
	fi
