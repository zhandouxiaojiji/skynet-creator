#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/lua-zset.mk ./make
git submodule add https://github.com/xjdrew/lua-zset.git 3rd/lua-zset
