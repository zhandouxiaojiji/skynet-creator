all: ${BUILD_CLUALIB_DIR}/hex-grid.so

HEX_GRID_SOURCE=3rd/hex-grid/luabinding.c \
	3rd/hex-grid/hex_grid.c \
	3rd/hex-grid/node_freelist.c \
	3rd/hex-grid/intlist.c

${HEX_GRID_SOURCE}:
	git submodule update --init 3rd/hex-grid

${BUILD_CLUALIB_DIR}/hex-grid.so: ${HEX_GRID_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -I3rd/hex-grid/ -Iskynet/3rd/lua $^ -o $@