#!/bin/bash

cp -v -n $RESOURCES_DIR/templates/luacheck/.luacheckrc ./
cp -v $RESOURCES_DIR/templates/luacheck/pre-commit ./.git/hooks/
chmod 755 ./.git/hooks/pre-commit