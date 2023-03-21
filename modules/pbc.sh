#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/pbc.mk ./make
git submodule add https://github.com/cloudwu/pbc.git 3rd/pbc
