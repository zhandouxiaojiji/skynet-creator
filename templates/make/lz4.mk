all: $(BUILD_CLUALIB_DIR)/lz4.so

LZ4_SOURCE=3rd/lz4/lz4/lz4.c \
	3rd/lz4/lz4/lz4hc.c \
	3rd/lz4/lz4/lz4frame.c \
	3rd/lz4/lz4/xxhash.c \
	3rd/lz4/lua_lz4.c

3rd/lz4/lz4.c:
	git submodule update --init 3rd/lz4

$(BUILD_CLUALIB_DIR)/lz4.so: $(LZ4_SOURCE)
	gcc $(CFLAGS) -std=c99 -Wno-unused-variable -DXXH_NAMESPACE=LZ4_ $(SHARED) $^ -o $@ $(LDFLAGS)