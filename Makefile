ARCH ?= arm64
SUITE ?= bookworm
SYSROOT ?= sysroot/debian12-$(ARCH)

.PHONY: all build host sysroot test

all: build

build:
	./scripts/build-debian.sh $(ARCH) $(SYSROOT)

host:
	./scripts/build-host.sh

sysroot:
	./scripts/create-debian-sysroot.sh --profile $(ARCH) $(SYSROOT) $(SUITE)

test:
	./tests/run-unit-tests.sh
