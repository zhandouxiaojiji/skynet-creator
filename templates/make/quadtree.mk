all: ${BUILD_CLUALIB_DIR}/quadtree.so

QUADTREE_SOURCE=3rd/quadtree/quadtree/Quadtree.c \
	3rd/quadtree/quadtree/luabinding.c

${QUADTREE_SOURCE}:
	git submodule update --init 3rd/quadtree

${BUILD_CLUALIB_DIR}/quadtree.so: ${QUADTREE_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -I3rd/quadtree/ -Iskynet/3rd/lua $^ -o $@