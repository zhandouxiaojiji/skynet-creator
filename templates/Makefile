.PHONY: all clean
all: build

include make/include.mk

TOP=.
BUILD_DIR=./build
BIN_DIR=./build/bin
LOG_DIR=./logs

INCLUDE_DIR=$(BUILD_DIR)/include                                                                                                                
BUILD_CLUALIB_DIR=$(BUILD_DIR)/clualib
BUILD_CSERVICE_DIR=$(BUILD_DIR)/cservice
BUILD_CLIB_DIR=$(BUILD_DIR)/clib

LUA_BIN="./skynet/3rd/lua/lua"
export LUA_CPATH=$(TOP)/$(BUILD_CLUALIB_DIR)/?.so
export LUA_PATH=$(TOP)/lualib/?.lua;$(TOP)/skynet/lualib/?.lua;

build:
	-mkdir -p $(BUILD_DIR)
	-mkdir -p $(BIN_DIR)
	-mkdir -p $(LOG_DIR)
	-mkdir -p $(INCLUDE_DIR)
	-mkdir -p $(BUILD_CLUALIB_DIR)
	-mkdir -p $(BUILD_CSERVICE_DIR)
	-mkdir -p $(BUILD_CLIB_DIR)

clean:
	cd skynet && $(MAKE) clean
	-rm -rf $(BUILD_DIR)