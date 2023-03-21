#!/bin/bash

cp -v $RESOURCES_DIR/templates/make/curl.mk ./make
git submodule add https://github.com/Lua-cURL/Lua-cURLv3.git 3rd/curl
