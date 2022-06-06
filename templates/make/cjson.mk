all: ${BUILD_CLUALIB_DIR}/cjson.so

CJSON_SOURCE=3rd/cjson/lua_cjson.c \
			 3rd/cjson/strbuf.c \
			 3rd/cjson/fpconv.c

3rd/cjson/lua_cjson.c:
	git submodule update --init 3rd/cjson

${BUILD_CLUALIB_DIR}/cjson.so:${CJSON_SOURCE}
	${CC} $(CFLAGS) -I3rd/lua/cjson $(SHARED) $^ -o $@ $(LDFLAGS)

