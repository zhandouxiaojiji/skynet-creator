#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/crab.mk ./make
git submodule add https://github.com/xjdrew/crab.git 3rd/crab
