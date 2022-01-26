.PHONY: all

all:
	git submodule update --init
	cp 3rd/argparse/src/argparse.lua lualib
	cp 3rd/argparse/src/argparse.lua templates/lualib
	cp 3rd/uuid/src/uuid.lua templates/lualib
	cp -r 3rd/behavior3/behavior3 templates/lualib