#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/hex-grid.mk ./make
git submodule add https://github.com/zhandouxiaojiji/lua-hex-grid.git 3rd/hex-grid
