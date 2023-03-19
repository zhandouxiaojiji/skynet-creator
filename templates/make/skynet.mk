.PHONY: skynet

all: skynet

SKYNET_MAKEFILE=skynet/Makefile

SKYNET_DEP_PATH=SKYNET_BUILD_PATH=../$(BIN_DIR) \
                LUA_CLIB_PATH=../$(BUILD_CLUALIB_DIR) \
                CSERVICE_PATH=../$(BUILD_CSERVICE_DIR)


$(SKYNET_MAKEFILE):
	git submodule update --init

build-skynet: | $(SKYNET_MAKEFILE)
	cd skynet && $(MAKE) PLAT=linux $(SKYNET_DEP_PATH) TLS_MODULE=ltls

skynet: build-skynet
	cp skynet/skynet-src/skynet_malloc.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet_env.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet_socket.h $(INCLUDE_DIR)
	cp skynet/3rd/lua/*.h $(INCLUDE_DIR)
	cp skynet/3rd/lua/lua $(BIN_DIR)