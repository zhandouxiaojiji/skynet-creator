all: ${BUILD_CLUALIB_DIR}/packet.so

PACKET_SOURCE=3rd/packet/lua-packet.c

${PACKET_SOURCE}:
	git submodule update --init 3rd/packet

${BUILD_CLUALIB_DIR}/packet.so: ${PACKET_SOURCE}
	${CC} $(CFLAGS) $(SHARED) -I3rd/packet/ -Iskynet/3rd/lua $^ -o $@ $(LDFLAGS)