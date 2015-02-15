# set gcc as default if CC is not set
ifndef CC
  CC=gcc
endif

SRCS      = sslscan.c
BINPATH   = /usr/bin/
MANPATH   = /usr/share/man/

WARNINGS  = -Wall -Wformat=2

LDFLAGS   = -Lopenssl
CFLAGS    = -Iopenssl/include
LIBS      = -lssl -lcrypto -ldl
VERSION   = OpenSSL_1_0_1j
DEFINES   = -DVERSION=\"$(VERSION)\"

.PHONY: sslscan clean

all: sslscan

openssl:
	git clone git://github.com/openssl/openssl.git -b $(VERSION)

openssl/Makefile: openssl Makefile
	cd ./openssl; ./config no-shared enable-ssl2 enable-ssl3
	#cd ./openssl; ./Configure linux-x86_64

openssl/libcrypto.a: openssl/Makefile
	$(MAKE) -C openssl depend
	$(MAKE) -C openssl all
	#$(MAKE) -C openssl test

openssl/libcrypto.so: openssl/Makefile
	cd ./openssl; rm libcrypto.a libssl.a; ./config shared zlib ssl2 ssl3
	$(MAKE) -C openssl depend
	$(MAKE) -C openssl all

sslscan: $(SRCS) openssl/libcrypto.a openssl/libssl.a
	$(CC) -o $@ ${WARNINGS} ${LDFLAGS} ${CFLAGS} ${DEFINES} ${SRCS} ${LIBS}

install:
	cp sslscan $(BINPATH)
	cp sslscan.1 $(MANPATH)man1

uninstall:
	rm -f $(BINPATH)sslscan
	rm -f $(MANPATH)man1/sslscan.1

clean:
	rm -f sslscan
