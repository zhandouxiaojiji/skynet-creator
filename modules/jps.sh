#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/jps.mk ./make
git submodule add https://github.com/rangercyh/jps.git 3rd/jps
