all: ${BUILD_CLUALIB_DIR}/protobuf.so

PBC_SOURCE=3rd/pbc/pbc.h
PBC_BINDING=lualib/protobuf.lua

${PBC_SOURCE}:
	git submodule update --init 3rd/pbc

${PBC_BINDING}:
	cp 3rd/pbc/binding/lua53/protobuf.lua lualib/protobuf.lua	

${BUILD_CLUALIB_DIR}/protobuf.so: ${PBC_SOURCE} ${PBC_BINDING}
	-cd 3rd/pbc && ${MAKE} lib
	${CC} ${CFLAGS} ${SHARED} -I3rd/pbc -Iskynet/3rd/lua 3rd/pbc/binding/lua53/pbc-lua53.c -o $@ -L3rd/pbc/build -lpbc