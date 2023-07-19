all: ${BUILD_CLUALIB_DIR}/jps.so

JPS_SOURCE=3rd/jps/jps.c \
	3rd/jps/heap.c \
	3rd/jps/intlist.c \
	3rd/jps/luabinding.c

${JPS_SOURCE}:
	git submodule update --init 3rd/jps

${BUILD_CLUALIB_DIR}/jps.so: ${JPS_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -I3rd/jps/ -Iskynet/3rd/lua $^ -o $@