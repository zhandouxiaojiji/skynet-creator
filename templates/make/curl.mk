# 依赖libcurl-devel库，自行安装，例: yum install libcurl-devel

all: ${BUILD_CLUALIB_DIR}/curl.so ${LUALIB_DIR}/curl.lua

CURL_SOURCE=3rd/curl/Makefile

${CURL_SOURCE}:
	git submodule update --init 3rd/curl

${LUALIB_DIR}/curl.lua:
	cp -r 3rd/curl/src/lua/* $(LUALIB_DIR)/

${BUILD_CLUALIB_DIR}/curl.so:
	cd 3rd/curl && make
	cp 3rd/curl/lcurl.so $(BUILD_CLUALIB_DIR)