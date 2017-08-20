EXCLUDES := .git
TARGET := $(wildcard .??*)
SRCS := $(filter-out $(EXCLUDES), $(TARGET))
DIR := $(PWD)

deploy:
	@$(foreach val, $(SRCS), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init:
	@$(foreach val, $(wildcard $(DIR)/etc/init/*.sh), bash $(val);)
