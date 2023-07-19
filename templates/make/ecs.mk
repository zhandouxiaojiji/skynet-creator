all: ${BUILD_CLUALIB_DIR}/ecs.so ${LUALIB_DIR}/ecs.lua

ECS_SOURCE=3rd/ecs/luaecs.c

${ECS_SOURCE}:
	git submodule update --init 3rd/ecs

${LUALIB_DIR}/ecs.lua:
	cp 3rd/ecs/ecs.lua lualib/ecs.lua

${BUILD_CLUALIB_DIR}/ecs.so: ${ECS_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -DTEST_LUAECS -I 3rd/ecs -Iskynet/3rd/lua -o $@ $^