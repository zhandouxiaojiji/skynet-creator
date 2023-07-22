#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/packet.mk ./make
git submodule add git@github.com:zhandouxiaojiji/lua-packet.git 3rd/packet