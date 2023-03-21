#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/navigation.mk ./make
git submodule add https://github.com/zhandouxiaojiji/lua-navigation.git 3rd/navigation
