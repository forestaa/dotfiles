EXCLUDES := .git
TARGET := $(wildcard .??*)
SRCS := $(filter-out $(EXCLUDES), $(TARGET))
DIR := $(PWD)
CONFIG := $(HOME)/.config
NVIM := $(CONFIG)/nvim

all: deploy-config

deploy-config: deploy-nvim
	@$(foreach val, $(SRCS), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

deploy-nvim:
	mkdir -p $(NVIM)
	ln -sfnv $(abspath $(DIR)/.vimrc) $(NVIM)/init.vim
