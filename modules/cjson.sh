#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/cjson.mk ./make
git submodule add https://github.com/cloudwu/lua-cjson.git 3rd/cjson
