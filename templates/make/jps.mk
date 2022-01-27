all: ${BUILD_CLUALIB_DIR}/jps.so

JPS_SOURCE=3rd/jps/jps.c 3rd/jps/fibheap.c

${JPS_SOURCE}:
	git submodule update --init 3rd/jps

${BUILD_CLUALIB_DIR}/jps.so: ${JPS_SOURCE}
	gcc $(CFLAGS) $(SHARED) -I3rd/jps/ $^ -o $@ $(LDFLAGS)