all: ${BUILD_CLUALIB_DIR}/openssl.so

OPENSSL_SOUCE=3rd/lua-openssl/src/asn1.c \
				3rd/lua-openssl/src/asn1.c \
				3rd/lua-openssl/src/bio.c \
				3rd/lua-openssl/src/cipher.c \
				3rd/lua-openssl/src/cms.c \
				3rd/lua-openssl/src/compat.c \
				3rd/lua-openssl/src/crl.c \
				3rd/lua-openssl/src/csr.c \
				3rd/lua-openssl/src/dh.c \
				3rd/lua-openssl/src/digest.c \
				3rd/lua-openssl/src/dsa.c \
				3rd/lua-openssl/src/ec.c \
				3rd/lua-openssl/src/engine.c \
				3rd/lua-openssl/src/hmac.c \
				3rd/lua-openssl/src/lbn.c \
				3rd/lua-openssl/src/lhash.c \
				3rd/lua-openssl/src/misc.c \
				3rd/lua-openssl/src/ocsp.c \
				3rd/lua-openssl/src/openssl.c \
				3rd/lua-openssl/src/ots.c \
				3rd/lua-openssl/src/pkcs12.c \
				3rd/lua-openssl/src/pkcs7.c \
				3rd/lua-openssl/src/pkey.c \
				3rd/lua-openssl/src/rsa.c \
				3rd/lua-openssl/src/ssl.c \
				3rd/lua-openssl/src/th-lock.c \
				3rd/lua-openssl/src/util.c \
				3rd/lua-openssl/src/x509.c \
				3rd/lua-openssl/src/xattrs.c \
				3rd/lua-openssl/src/xexts.c \
				3rd/lua-openssl/src/xname.c \
				3rd/lua-openssl/src/xstore.c \
				3rd/lua-openssl/src/xalgor.c \
				3rd/lua-openssl/src/callback.c \
				3rd/lua-openssl/src/srp.c \
				3rd/lua-openssl/deps/auxiliar/subsidiar.c \
				3rd/lua-openssl/deps/auxiliar/auxiliar.c

SUBSIDIAR_C=3rd/lua-openssl/deps/auxiliar/subsidiar.c

$(SUBSIDIAR_C):
	cd 3rd/lua-openssl && git submodule update --init

${BUILD_CLUALIB_DIR}/openssl.so:${OPENSSL_SOUCE}
	${CC} $(CFLAGS) -I3rd/lua-openssl/src -I3rd/lua-openssl/deps/auxiliar $(SHARED) $^ -o $@ -lssl -lcrypto