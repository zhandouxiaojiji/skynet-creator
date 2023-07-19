all: ${BUILD_CLUALIB_DIR}/profile.so

LUAPROFILE_SOURCE=3rd/profile/imap.c \
	3rd/profile/profile.c

3rd/profile/profile.c.c:
	git submodule update --init 3rd/profile

${BUILD_CLUALIB_DIR}/profile.so: ${LUAPROFILE_SOURCE}
	gcc $(CFLAGS) $(SHARED) -I3rd/profile/ -Iskynet/3rd/lua $^ -o $@ $(LDFLAGS)