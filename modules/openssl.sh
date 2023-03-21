#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/openssl.mk ./make
git submodule add https://github.com/zhongfq/lua-openssl.git 3rd/openssl
