EXCLUDES := .git
TARGET := $(wildcard .??*)
SRCS := $(filter-out $(EXCLUDES), $(TARGET))
DIR := $(CURDIR)
NVIM := $(HOME)/.config/nvim
LOGO := .logo

deploy:
	@$(foreach val, $(SRCS), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	mkdir -p $(NVIM)
	ln -sfnv $(DIR)/.vimrc $(NVIM)/init.vim
	ln -sfnv $(DIR)/$(LOGO) $(HOME)/$(LOGO)

init:
	@$(foreach val, $(wildcard $(DIR)/etc/init/*.sh), bash $(val);)
