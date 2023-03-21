#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/profile.mk ./make
git submodule add https://github.com/lvzixun/luaprofile.git 3rd/profile