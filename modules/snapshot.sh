#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/snapshot.mk ./make
git submodule add https://github.com/lvzixun/lua-snapshot.git 3rd/snapshot
