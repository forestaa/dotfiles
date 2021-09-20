EXCLUDES := .git .zshrc
TARGET := $(wildcard .??*)
SRCS := $(filter-out $(EXCLUDES), $(TARGET))
DIR := $(PWD)
NVIM := $(HOME)/.config/nvim

all: deploy-config install-package

install-package:
	sudo pacman -S --needed - < pkglist.txt

deploy-config: deploy-nvim deploy-zshrc
	@$(foreach val, $(SRCS), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

deploy-nvim:
	mkdir -p $(NVIM)
	ln -sfnv $(abspath $(DIR)/.vimrc) $(NVIM)/init.vim

deploy-zshrc:
	ln -sfnv $(abspath .zshrc) $(HOME)/.zshrc.local
