.PHONY: all install

all:
	git submodule update --init --recursive
	cp 3rd/argparse/src/argparse.lua lualib
	cp 3rd/argparse/src/argparse.lua templates/lualib
	cp 3rd/uuid/src/uuid.lua templates/lualib
	cp 3rd/fsm/src/fsm.lua templates/lualib
	cp -r 3rd/behavior3/behavior3 templates/lualib
	cp 3rd/revent/revent.lua templates/lualib
	cp 3rd/fog/fog.lua templates/lualib

install:
	install -m 0755 skynet-creator.sh /usr/local/bin/skynet-creator
	mkdir -p /usr/local/share/skynet-creator
	cp -r lualib modules templates /usr/local/share/skynet-creator