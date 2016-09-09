#!/usr/bin/make -f

ARCH = $(shell uname -m)

ifeq ($(ARCH),i686)
	ARCH = i386
endif
ifeq ($(ARCH),i586)
	ARCH = i386
endif
ifeq ($(ARCH),i486)
	ARCH = i386
endif

BINDIR = bin/$(shell uname | tr A-Z a-z)-$(ARCH)

all: lib/Zfm.lpr
	lazbuild lib/Zfm.lpr

install: $(BINDIR)/libzfm.so
	install -D --mode 644 $(BINDIR)/libzfm.so $(DESTDIR)/usr/lib/
