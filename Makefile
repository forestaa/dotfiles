EXCLUDES := .git
TARGET := $(wildcard .??*)
SRCS := $(filter-out $(EXCLUDES), $(TARGET))
DIR := $(PWD)
CONFIG := $(HOME)/.config
NVIM := $(CONFIG)/nvim
KARABINER := $(CONFIG)/karabiner
WEZTERM := $(CONFIG)/wezterm

all: deploy-config

deploy-config: deploy-nvim
	@$(foreach val, $(SRCS), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

deploy-nvim:
	mkdir -p $(NVIM)
	ln -sfnv $(abspath $(DIR)/.vimrc) $(NVIM)/init.vim

deploy-karabiner:
	mkdir -p $(KARABINER)
	ln -sfnv $(abspath $(DIR)/.config/karabiner) $(KARABINER)

deploy-wezterm:
	mkdir -p $(KARABINER)
	ln -sfnv $(abspath $(DIR)/.config/wezterm) $(WEZTERM)
