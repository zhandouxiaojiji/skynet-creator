all: ${BUILD_CLUALIB_DIR}/navigation.so

NAVI_BINDING=lualib/navigation.lua
NAVI_SOURCE=3rd/navigation/luabinding.c \
	3rd/navigation/map.c \
	3rd/navigation/jps.c \
	3rd/navigation/fibheap.c \
	3rd/navigation/smooth.c

${NAVI_SOURCE}:
	git submodule update --init 3rd/navigation

${NAVI_BINDING}:
	cp 3rd/navigation/navigation.lua lualib/navigation.lua	

${BUILD_CLUALIB_DIR}/navigation.so: ${NAVI_SOURCE} ${NAVI_BINDING}
	${CC} $(CFLAGS) $(SHARED) -o -I3rd/navigation/ -Iskynet/3rd/lua $^ -o $@
