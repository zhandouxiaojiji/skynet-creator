all: ${BUILD_CLUALIB_DIR}/crypto.so

SOURCE=3rd/crypto/luabinding.c \
	   3rd/crypto/lcodec.c \
	   3rd/crypto/lcrc.c \
	   3rd/crypto/lmd5.c \
	   3rd/crypto/lsha1.c \
	   3rd/crypto/lsha2.c \

3rd/crypto/luabinding.c:
	git submodule update --init 3rd/crypto/luabinding

${BUILD_CLUALIB_DIR}/crypto.so:${SOURCE}
	${CC} $(CFLAGS) -I3rd/lua/crypto $(SHARED) $^ -o $@ $(LDFLAGS) -lcrypto

