#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/lz4.mk ./make
git submodule add https://github.com/witchu/lua-lz4.git 3rd/lz4
