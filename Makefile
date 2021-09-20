EXCLUDES := .git .zshrc
TARGET := $(wildcard .??*)
SRCS := $(filter-out $(EXCLUDES), $(TARGET))
DIR := $(PWD)
NVIM := $(HOME)/.config/nvim

deploy: deploy-nvim deploy-zshrc
	@$(foreach val, $(SRCS), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

deploy-nvim:
	mkdir -p $(NVIM)
	ln -sfnv $(abspath $(DIR)/.vimrc) $(NVIM)/init.vim

deploy-zshrc:
	ln -sfnv $(abspath .zshrc) $(HOME)/.zshrc.local
