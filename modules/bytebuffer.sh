#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/bytebuffer.mk ./make
git submodule add https://github.com/zhandouxiaojiji/lua-bytebuffer.git 3rd/bytebuffer
