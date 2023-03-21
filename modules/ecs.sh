#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/ecs.mk ./make
git submodule add https://github.com/cloudwu/luaecs.git 3rd/ecs
