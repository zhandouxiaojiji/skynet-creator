#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/pbc.mk ./make
git submodule add https://github.com/zhandouxiaojiji/pbc.git 3rd/pbc
