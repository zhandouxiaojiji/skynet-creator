#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/packet.mk ./make
git submodule add https://github.com:zhandouxiaojiji/lua-packet.git 3rd/packet