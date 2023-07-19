all: ${BUILD_CLUALIB_DIR}/openssl.so

OPENSSL_SOUCE=3rd/openssl/src/asn1.c \
				3rd/openssl/src/asn1.c \
				3rd/openssl/src/bio.c \
				3rd/openssl/src/cipher.c \
				3rd/openssl/src/cms.c \
				3rd/openssl/src/compat.c \
				3rd/openssl/src/crl.c \
				3rd/openssl/src/csr.c \
				3rd/openssl/src/dh.c \
				3rd/openssl/src/digest.c \
				3rd/openssl/src/dsa.c \
				3rd/openssl/src/ec.c \
				3rd/openssl/src/engine.c \
				3rd/openssl/src/hmac.c \
				3rd/openssl/src/lbn.c \
				3rd/openssl/src/lhash.c \
				3rd/openssl/src/misc.c \
				3rd/openssl/src/ocsp.c \
				3rd/openssl/src/openssl.c \
				3rd/openssl/src/ots.c \
				3rd/openssl/src/pkcs12.c \
				3rd/openssl/src/pkcs7.c \
				3rd/openssl/src/pkey.c \
				3rd/openssl/src/rsa.c \
				3rd/openssl/src/ssl.c \
				3rd/openssl/src/th-lock.c \
				3rd/openssl/src/util.c \
				3rd/openssl/src/x509.c \
				3rd/openssl/src/xattrs.c \
				3rd/openssl/src/xexts.c \
				3rd/openssl/src/xname.c \
				3rd/openssl/src/xstore.c \
				3rd/openssl/src/xalgor.c \
				3rd/openssl/src/callback.c \
				3rd/openssl/src/srp.c \
				3rd/openssl/deps/auxiliar/subsidiar.c \
				3rd/openssl/deps/auxiliar/auxiliar.c

SUBSIDIAR_C=3rd/openssl/deps/auxiliar/subsidiar.c

$(SUBSIDIAR_C):
	cd 3rd/openssl && git submodule update --init

${BUILD_CLUALIB_DIR}/openssl.so:${OPENSSL_SOUCE}
	${CC} $(CFLAGS) -I3rd/openssl/src -I3rd/openssl/deps/auxiliar -Iskynet/3rd/lua $(SHARED) $^ -o $@ -lssl -lcrypto