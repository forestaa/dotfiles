DIR := $(CURDIR)
CONFIG := $(HOME)/.config
SHARE := $(HOME)/.local/share

build:
	stack build

install:
	stack install

deploy: install
	rm -rf $(HOME)/.xmonad
	mkdir -p $(CONFIG)/xmonad
	mkdir -p $(SHARE)/xmonad
	ln -sfvn $(DIR)/app/build $(CONFIG)/xmonad/build
	ln -sfvn $(DIR)/app/xmonad.hs $(CONFIG)/xmonad/xmonad.hs
	ln -sfvn $(DIR)/app/xmobarrc $(CONFIG)/xmonad/xmobarrc
