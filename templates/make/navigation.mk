all: ${BUILD_CLUALIB_DIR}/navigation.so

NAVI_SOURCE=3rd/navigation/luabinding.c \
	3rd/navigation/map.c \
	3rd/navigation/jps.c \
	3rd/navigation/fibheap.c \
	3rd/navigation/smooth.c

${NAVI_SOURCE}:
	git submodule update --init 3rd/navigation

${BUILD_CLUALIB_DIR}/navigation.so: ${NAVI_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -o -I3rd/navigation/ $^ -o $@