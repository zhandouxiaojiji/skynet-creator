#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/quadtree.mk ./make
git submodule add https://github.com/rangercyh/quadtree.git 3rd/quadtree