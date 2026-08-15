ARCH ?= riscv64
SYSROOT ?=

.PHONY: all build host platform test test-riscv64

all: build

build:
	@test -n "$(SYSROOT)" || { echo "set SYSROOT to an existing target development sysroot" >&2; exit 2; }
	./scripts/build-debian.sh $(ARCH) $(SYSROOT)

platform:
	@test -n "$(PLATFORM)" || { echo "set PLATFORM to a supported platform, for example: PLATFORM=sg2002" >&2; exit 2; }
	@test -f "platforms/$(PLATFORM)/Makefile" || { echo "unsupported platform: $(PLATFORM)" >&2; exit 2; }
	$(MAKE) -C platforms/$(PLATFORM)

host:
	./scripts/build-host.sh

test:
	./tests/run-unit-tests.sh

test-riscv64:
	@test -n "$(SYSROOT)" || { echo "set SYSROOT to an existing riscv64 development sysroot" >&2; exit 2; }
	./tests/run-riscv64-build-test.sh $(SYSROOT)
