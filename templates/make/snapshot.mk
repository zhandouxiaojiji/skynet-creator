.PHONY: lsnapshot

all: ${BUILD_CLUALIB_DIR}/snapshot.so
all: lsnapshot

SNAPSHOT_SOURCE=3rd/snapshot/snapshot.c

${SNAPSHOT_SOURCE}:
	git submodule update --init 3rd/snapshot

${BUILD_CLUALIB_DIR}/snapshot.so: ${SNAPSHOT_SOURCE}
	$(CC) $(CFLAGS) $(SHARED) -I$(INCLUDE_DIR) -I3rd/snapshot/ -Iskynet/3rd/lua $^ -o $@ $(LDFLAGS)

lsnapshot:
	cp 3rd/snapshot/lsnapshot.lua $(LUALIB_DIR)
