all:${BUILD_CLUALIB_DIR}/skiplist.so

LIB=skiplist.so
LUA_ZSET_PATH=3rd/lua-zset
SRC_FILES=$(wildcard $(LUA_ZSET_PATH)/*.c $(LUA_ZSET_PATH)/*.h $(LUA_ZSET_PATH)/*.lua)

LUA_ZSET_SOURCE=3rd/lua-zset/lua-skiplist.c

${LUA_ZSET_SOURCE}:
	git submodule update --init 3rd/lua-zset

${BUILD_CLUALIB_DIR}/$(LIB): ${SRC_FILES}
	$(MAKE) -C $(LUA_ZSET_PATH)
	cp $(LUA_ZSET_PATH)/$(LIB) $(BUILD_CLUALIB_DIR)/$(LIB)
	cp $(LUA_ZSET_PATH)/zset.lua lualib/zset.lua
