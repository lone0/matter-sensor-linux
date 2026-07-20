ARCH ?= arm64
SYSROOT ?=

.PHONY: all build host platform-sg2002-8051 platform-sg2002-8051-loader test test-riscv64

all: build

build:
	@test -n "$(SYSROOT)" || { echo "set SYSROOT to an existing target development sysroot" >&2; exit 2; }
	./scripts/build-debian.sh $(ARCH) $(SYSROOT)

platform-sg2002-8051:
	$(MAKE) -C platforms/sg2002/8051

platform-sg2002-8051-loader:
	$(MAKE) -C platforms/sg2002/8051 loader

host:
	./scripts/build-host.sh

test:
	./tests/run-unit-tests.sh

test-riscv64:
	@test -n "$(SYSROOT)" || { echo "set SYSROOT to an existing riscv64 development sysroot" >&2; exit 2; }
	./tests/run-riscv64-build-test.sh $(SYSROOT)
