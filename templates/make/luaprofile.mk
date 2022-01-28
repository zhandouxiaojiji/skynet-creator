all: ${BUILD_CLUALIB_DIR}/profile.so

LUAPROFILE_SOURCE=3rd/luaprofile/imap.c \
	3rd/luaprofile/profile.c

3rd/luaprofile/profile.c.c:
	git submodule update --init 3rd/jps

${BUILD_CLUALIB_DIR}/profile.so: ${LUAPROFILE_SOURCE}
	gcc $(CFLAGS) $(SHARED) -I3rd/profile/ $^ -o $@ $(LDFLAGS)