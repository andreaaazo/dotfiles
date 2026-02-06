# Makefile - Dotfiles managed with GNU stow (clean + safe)
# Run from repo root (this directory).

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

DOTFILES_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TARGET ?= $(HOME)
STOW ?= stow

# Your packages (top-level directories in the repo)
PACKAGES ?= apps desktop dev fonts formatters linters mouse-cursor scripts shell system terminal

# Safety: avoid directory "folding" that can create nested stow (e.g. ~/.config -> repo/.config)
STOW_FLAGS := --dir="$(DOTFILES_DIR)" --target="$(TARGET)" --no-folding --verbose=1

.PHONY: help list preflight prune-strays dry-run unstow-all stow-all sync

.DEFAULT_GOAL := help

help:
	@echo "Dotfiles (GNU stow) - safe targets"
	@echo
	@echo "Targets:"
	@echo "  make list       - show packages"
	@echo "  make dry-run    - simulate: prune + unstow + stow"
	@echo "  make sync       - prune + UNSTOW all packages + STOW all packages"
	@echo
	@echo "Vars:"
	@echo "  TARGET=/path    - target directory (default: \$$HOME)"
	@echo "  PACKAGES=\"...\"  - override package list"

list:
	@printf "%s\n" $(PACKAGES)

preflight:
	@command -v "$(STOW)" >/dev/null 2>&1 || { echo "ERROR: 'stow' not found in PATH"; exit 1; }
	@test -n "$(TARGET)" || { echo "ERROR: TARGET empty"; exit 1; }
	@test "$(TARGET)" != "/" || { echo "ERROR: TARGET=/ is not allowed"; exit 1; }
	@test -d "$(DOTFILES_DIR)" || { echo "ERROR: DOTFILES_DIR missing: $(DOTFILES_DIR)"; exit 1; }
	@for p in $(PACKAGES); do \
		test -d "$(DOTFILES_DIR)/$$p" || { echo "ERROR: missing package dir: $$p"; exit 1; }; \
	done
	@# Hard stop if these are symlinks into this repo (classic nested-stow footgun)
	@for d in .config .local .ssh; do \
		if [[ -L "$(TARGET)/$$d" ]]; then \
			link="$$(readlink -f "$(TARGET)/$$d" 2>/dev/null || true)"; \
			if [[ "$$link" == "$(DOTFILES_DIR)"* ]]; then \
				echo "ERROR: $(TARGET)/$$d is a symlink into this repo: $$link"; \
				echo "Fix: remove that symlink and recreate it as a real directory, then retry."; \
				exit 1; \
			fi; \
		fi; \
	done

# Remove symlinks in TARGET that point into this repo BUT are not managed by stow.
# This cleans leftovers like ~/git -> ~/dotfiles/dev/.config/git from previous wrong stow.
prune-strays: preflight
	@echo "==> Pruning stray symlinks in $(TARGET) pointing into $(DOTFILES_DIR)"
	@find "$(TARGET)" -path "$(DOTFILES_DIR)" -prune -o -type l -print0 \
	| while IFS= read -r -d '' l; do \
		t="$$(readlink -f -- "$$l" 2>/dev/null || true)"; \
		if [[ "$$t" == "$(DOTFILES_DIR)"* ]]; then \
			# If stow "owns" it, leave it. Otherwise remove.
			if "$(STOW)" $(STOW_FLAGS) --defer=".*" --delete --simulate $(PACKAGES) >/dev/null 2>&1; then :; fi; \
			if "$(STOW)" $(STOW_FLAGS) --delete --simulate $(PACKAGES) 2>/dev/null | grep -Fq "$$l"; then \
				:; \
			else \
				echo "-- rm $$l -> $$t"; \
				rm -f -- "$$l"; \
			fi; \
		fi; \
	done

dry-run: preflight
	@echo "==> DRY-RUN: UNSTOW (simulate)"
	@for p in $(PACKAGES); do \
		echo "-- delete $$p"; \
		"$(STOW)" $(STOW_FLAGS) --delete --simulate "$$p"; \
	done
	@echo
	@echo "==> DRY-RUN: STOW (simulate)"
	@for p in $(PACKAGES); do \
		echo "-- stow $$p"; \
		"$(STOW)" $(STOW_FLAGS) --stow --simulate "$$p"; \
	done

unstow-all: preflight
	@echo "==> UNSTOW: removing existing links for listed packages"
	@for p in $(PACKAGES); do \
		echo "-- delete $$p"; \
		"$(STOW)" $(STOW_FLAGS) --delete "$$p"; \
	done

stow-all: preflight
	@echo "==> STOW: applying packages"
	@for p in $(PACKAGES); do \
		echo "-- stow $$p"; \
		"$(STOW)" $(STOW_FLAGS) --stow "$$p"; \
	done

sync: preflight prune-strays unstow-all stow-all
	@echo "==> OK: dotfiles synced to $(TARGET)"

