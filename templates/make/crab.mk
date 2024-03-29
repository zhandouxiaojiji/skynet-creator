all: ${BUILD_CLUALIB_DIR}/crab.so ${BUILD_CLUALIB_DIR}/utf8.so

CRAB_SOURCE=3rd/crab/lua-crab.c
UTF8_SOURCE=3rd/crab/lua-utf8.c

${CRAB_SOURCE}:
	git submodule update --init 3rd/crab

${BUILD_CLUALIB_DIR}/crab.so: ${CRAB_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -I3rd/crab/src/ -Iskynet/3rd/lua $^ -o $@ $(LDFLAGS)

${BUILD_CLUALIB_DIR}/utf8.so: ${UTF8_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -I3rd/crab/src/ -Iskynet/3rd/lua $^ -o $@ $(LDFLAGS)