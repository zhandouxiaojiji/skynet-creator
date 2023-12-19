all: ${BUILD_CLUALIB_DIR}/bytebuffer.so

BYTEBUFFER_SOURCE=3rd/bytebuffer/lua-bytebuffer.c

${BYTEBUFFER_SOURCE}:
	git submodule update --init 3rd/bytebuffer

${BUILD_CLUALIB_DIR}/bytebuffer.so: ${BYTEBUFFER_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -I3rd/bytebuffer/ -Iskynet/3rd/lua $^ -o $@ $(LDFLAGS)