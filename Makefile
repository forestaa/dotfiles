EXCLUDES := .git
TARGET := $(wildcard .??*)
SRCS := $(filter-out $(EXCLUDES), $(TARGET))
DIR := $(PWD)
NVIM := $(HOME)/.config/nvim

deploy: deploy-nvim
	@$(foreach val, $(SRCS), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

deploy-nvim:
	mkdir -p $(NVIM)
	ln -sfnv $(abspath $(DIR)/.vimrc) $(NVIM)/init.vim
