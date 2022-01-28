.PHONY: lsnapshot

all: ${BUILD_CLUALIB_DIR}/snapshot.so
all: lsnapshot

SNAPSHOT_SOURCE=3rd/snapshot/snapshot.c

${SNAPSHOT_SOURCE}:
	git submodule update --init 3rd/snapshot

${BUILD_CLUALIB_DIR}/snapshot.so: ${SNAPSHOT_SOURCE}
	gcc $(CFLAGS) $(SHARED) -I3rd/snapshot/ $^ -o $@ $(LDFLAGS)

lsnapshot:
	cp 3rd/snapshot/lsnapshot.lua $(LUALIB_DIR)
