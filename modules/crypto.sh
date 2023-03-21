#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/crypto.mk ./make
git submodule add https://github.com/zhandouxiaojiji/lua-crypto.git 3rd/crypto
