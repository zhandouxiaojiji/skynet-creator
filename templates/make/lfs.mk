all: ${BUILD_CLUALIB_DIR}/lfs.so

LFS_SOURCE=3rd/lfs/src/lfs.c

${LFS_SOURCE}:
	git submodule update --init 3rd/lfs

${BUILD_CLUALIB_DIR}/lfs.so: ${LFS_SOURCE}
	gcc $(CFLAGS) $(SHARED) -I3rd/lfs/src/ $^ -o $@ $(LDFLAGS)