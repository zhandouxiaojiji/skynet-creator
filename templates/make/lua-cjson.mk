all: ${BUILD_CLUALIB_DIR}/cjson.so

CJSON_SOURCE=3rd/lua-cjson/lua_cjson.c \
			 3rd/lua-cjson/strbuf.c \
			 3rd/lua-cjson/fpconv.c

${BUILD_CLUALIB_DIR}/cjson.so:${CJSON_SOURCE}
	${CC} $(CFLAGS) -I3rd/lua/lua-cjson $(SHARED) $^ -o $@ $(LDFLAGS)

3rd/lua-cjson/lua_cjson.c:
	git submodule update --init 3rd/lua-cjson