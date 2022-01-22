.PHONY: all

all:
	git submodule update --init
	cp 3rd/argparse/src/argparse.lua lualib/