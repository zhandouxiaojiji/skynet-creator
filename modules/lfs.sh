#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/lfs.mk ./make
git submodule add https://github.com/keplerproject/luafilesystem.git 3rd/lfs
