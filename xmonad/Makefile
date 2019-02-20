DIR := $(CURDIR)
CONFIG := $(HOME)/.config

build:
	stack build

install:
	stack install

deploy: install
	rm -rf $(HOME)/.xmonad
	mkdir -p $(CONFIG)/xmonad
	ln -sfvn $(DIR)/app/build $(CONFIG)/xmonad/build
	ln -sfvn $(DIR)/app/xmonad.hs $(CONFIG)/xmonad/xmonad.hs
	ln -sfvn $(DIR)/app/xmobarrc $(CONFIG)/xmonad/xmobarrc
