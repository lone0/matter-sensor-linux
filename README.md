# Matter Temperature and Humidity Sensor for Linux

Turn a Linux device, such as an Ethernet-connected Raspberry Pi, into a native
Matter temperature and relative-humidity sensor. The application is derived
from Project CHIP/connectedhomeip's Linux architecture and has no Snap or
Snapcraft dependency. It supports every CPU architecture supported by CHIP's
Linux SDK.

It exposes the standard Temperature Measurement and Relative Humidity
Measurement server clusters on endpoint `1`. Commissioning is on-network over
IPv6 and mDNS/DNS-SD; Bluetooth LE advertising is disabled at startup.

## Project design

The application separates sensor acquisition from Matter reporting:

```text
sensor command or custom SensorProvider
        -> SensorPoller
        -> MatterReporter
        -> Matter measurement attributes
```

- `SensorProvider` defines the pluggable sensor interface.
- `CommandJsonSensorProvider` executes a configured command directly, without
  a shell, and parses its JSON output.
- `SensorPoller` runs reads periodically and retains the last valid Matter
  value if an acquisition fails.
- `MatterReporter` marshals updates to CHIP's application thread and writes
  the two standard measurement attributes.

The repository uses profile-driven Linux cross builds. Architecture facts live
in `build-profiles/*.conf`; a selected profile builds against an existing target
development sysroot supplied by the board image, SDK, or toolchain owner.

## Quick start

```sh
git clone <repository-url> matter-temperature-humidity-sensor
cd matter-temperature-humidity-sensor
git submodule update --init --recursive

sudo apt update
sudo apt install -y \
  pkg-config libssl-dev libavahi-client-dev libdbus-1-dev \
  libglib2.0-dev libglib2.0-dev-bin \
  jq

make test
make host
```

The host binary is written to:

```text
out/host/matter-temperature-humidity-sensor
```

For development, copy `runtime-config/sensor.conf.example`, set `sensor_command` to
the absolute path of `scripts/stub-sensor.sh`, and run:

```sh
./out/host/matter-temperature-humidity-sensor --sensor-config ./sensor.conf
```

The CHIP startup output contains the onboarding payload for on-network
commissioning.

## Sensor integration

The simplest integration is an executable configured by `sensor_command`. It
must exit successfully and write exactly one object to stdout:

```json
{"temperature_c":23.45,"humidity_percent":56.78}
```

Diagnostics belong on stderr, not stdout. Temperature must be finite and within
`-273.15..327.67` C; humidity must be finite and within `0..100` percent.

```ini
sensor_command=/usr/local/libexec/read-temperature-humidity
# sensor_arg=--optional-argument
poll_interval_seconds=60
command_timeout_milliseconds=5000
maximum_output_bytes=4096
```

The command is invoked with `execvp`, not `sh -c`; `sensor_arg` lines provide
arguments without shell parsing. See `scripts/stub-sensor.sh` for a minimal
fixture.

For development, set `SENSOR_STUB_LOG` to a writable file before starting the
application. The stub appends one timestamped line for every poll while keeping
stdout limited to its JSON reading:

```sh
SENSOR_STUB_LOG=/tmp/matter-sensor-polls.log \
  ./out/host/matter-temperature-humidity-sensor --sensor-config ./sensor.conf
tail -f /tmp/matter-sensor-polls.log
```

For a direct I2C, serial, or other in-process implementation, begin with:

| Purpose | Location |
| --- | --- |
| Provider interface | `include/SensorProvider.h` |
| Reading type and conversion | `include/SensorReading.h`, `src/SensorReading.cpp` |
| Existing command provider | `src/CommandJsonSensorProvider.cpp` |
| Provider construction | `src/main.cpp` |
| Polling lifecycle | `src/SensorPoller.cpp` |
| Matter reporting | `src/MatterReporter.cpp` |

Implement `SensorProvider::Read`, return a validated `SensorReading`, and
select the new provider in `src/main.cpp`. Normal sensor ports do not need to
change `MatterReporter.cpp`.

## Cross builds with an external development sysroot

Install the cross compiler selected by the architecture profile. The target
sysroot must come from the exact board image, vendor SDK, or distribution build
environment used for deployment. It must contain target development headers and
libraries, not only the runtime root filesystem.

```sh
# arm64
sudo apt install -y gcc-12-aarch64-linux-gnu g++-12-aarch64-linux-gnu

# armhf
sudo apt install -y gcc-12-arm-linux-gnueabihf g++-12-arm-linux-gnueabihf
```

Build by naming the profile and the external sysroot:

```sh
make build ARCH=arm64 SYSROOT=/opt/board-sdk/sysroot

# Or:
make build ARCH=armhf SYSROOT=/opt/board-sdk/sysroot

# riscv64 with an existing sysroot and GCC 12 cross compiler
make build ARCH=riscv64 SYSROOT=/mnt/storage/riscv64-qemu-sysroot \
  CROSS_GCC=/usr/bin/riscv64-linux-gnu-gcc-12 \
  CROSS_GXX=/usr/bin/riscv64-linux-gnu-g++-12
```

The cross-build script verifies the supplied sysroot has the target include and
multiarch library directories, then derives its GLIBC ceiling from target
`libc.so.6`. It rejects a binary requiring a newer GLIBC version.

The result is placed at:

```text
out/<profile-output-directory>/matter-temperature-humidity-sensor
```

Without `OUTPUT_DIR` in the profile, the output directory is
`out/linux-<DEBIAN_ARCH>`.

Equivalent direct command:

```sh
./scripts/build-debian.sh arm64 /opt/board-sdk/sysroot
```

The older `build-debian12-arm64.sh` script remains as an arm64 compatibility
wrapper and also requires an existing sysroot.

The parent-owned connectedhomeip RISC-V toolchain patch is applied only for a
`riscv64` build and automatically reversed afterward. Exercise that lifecycle
with an external RISC-V development sysroot:

```sh
make test-riscv64 SYSROOT=/path/to/riscv64-development-sysroot
```

## SG2002 Debian 13 preparation

The SG2002 DHT11 integration is an external command backend in
[`platforms/sg2002`](platforms/sg2002). It adds BusyBox `devmem`, RTC register
handling, a privileged service unit, and board-specific deployment guidance
without changing the generic application.

There is no SG2002 build profile or build flag. Build the standard Linux
`riscv64` binary, then select the SG2002 integration on the board by installing
its command configuration and service:

```sh
make build ARCH=riscv64 SYSROOT=/path/to/riscv64-sysroot
cd platforms/sg2002
sudo ./install-dependencies.sh --install
sudo ./probe-rtc-info.sh
```

The SG2002 configuration sets `sensor_command` to `read-rtc-info.sh`; other
deployments can use the same binary with any executable that emits the standard
sensor JSON. The platform guide also documents its optional 8051 LED/DHT11
firmware, board-side GPIO preflight, and loader procedure.

## Porting guide

### Add an architecture already supported by CHIP Linux GN

CHIP's supplied Linux GN toolchains support `x64`, `x86`, `arm`, and `arm64`.
This repository also adds Linux `riscv64` support to its connectedhomeip
submodule through
`patches/connectedhomeip/0001-add-linux-riscv64-gcc-toolchain.patch`. The
build script applies this patch only for the riscv64 profile and reverses it
after the build, so the submodule remains at its upstream revision. For one of
these, create
`build-profiles/<profile>.conf` by copying `arm64.conf`, `armhf.conf`,
or `riscv64.conf`:

```sh
DEBIAN_ARCH=armhf
GN_TARGET_CPU=arm
GNU_TRIPLET=arm-linux-gnueabihf
DEBIAN_MULTIARCH=arm-linux-gnueabihf
GCC_VERSION=12
```

| Field | Meaning |
| --- | --- |
| `DEBIAN_ARCH` | Target Debian architecture; used for default output naming. |
| `GN_TARGET_CPU` | CHIP GN CPU identifier. |
| `GNU_TRIPLET` | Prefix of the Ubuntu cross compiler binaries. |
| `DEBIAN_MULTIARCH` | Debian sysroot include and library directory name. |
| `GCC_VERSION` | Required host cross-compiler version. |
| `OUTPUT_DIR` | Optional output directory suffix; used by external sysroots. |
| `GLIBC_MAX_VERSION` | Optional deployment GLIBC ceiling; otherwise derived from the supplied sysroot. |

Install the matching compiler and obtain a development sysroot, then run:

```sh
make build ARCH=<profile> SYSROOT=/path/to/target-development-sysroot
```

The build never creates or modifies the sysroot.

### Add a completely new CPU family

First confirm that CHIP's Linux SDK supports the desired CPU family. A CPU
family outside the repository's existing `x64`, `x86`, `arm`, `arm64`, and
`riscv64` Linux GN support requires a connectedhomeip build port, not merely a
new project profile. Then:

1. Add the architecture profile described above.
2. Add a matching GNU toolchain target in
   `third_party/connectedhomeip/build/toolchain/linux/BUILD.gn`.
3. Ensure the new GN toolchain uses the profile's `GNU_TRIPLET`.
4. Map the architecture to a supported `GN_TARGET_CPU`, or extend CHIP's build
   configuration for the new CPU.
5. Obtain an external development sysroot for the target.
6. Run `make build ARCH=<profile> SYSROOT=/path/to/target-development-sysroot`.
7. Confirm the result using `file` and `readelf --version-info`; its highest
   `GLIBC_*` requirement must not exceed the target sysroot's `libc.so.6`.

## Deploy

Deployment has two layers:

1. Install the generic Matter application and its standard systemd service.
2. Install a platform sensor command and its matching configuration before
   enabling the service.

On the running target, install the generic binary and service:

```sh
sudo useradd --system \
  --home /var/lib/matter-temperature-humidity-sensor \
  --shell /usr/sbin/nologin \
  matter-sensor
sudo install -D -m 0755 /path/to/matter-temperature-humidity-sensor \
  /usr/local/bin/matter-temperature-humidity-sensor
sudo install -m 0644 deploy/matter-temperature-humidity-sensor.service \
  /etc/systemd/system/
sudo systemctl daemon-reload
```

For a generic command sensor, copy its executable and install a configuration
at `/etc/matter-temperature-humidity-sensor.conf` based on
`runtime-config/sensor.conf.example`. Then enable the service:

```sh
sudo systemctl enable --now matter-temperature-humidity-sensor
```

For SG2002, do not enable the generic service yet. Follow the
[`platforms/sg2002`](platforms/sg2002) deployment guide to install the RTC
reader or its fixed-value debug stub, the matching configuration, and the
SG2002 service unit that grants `CAP_SYS_RAWIO`.

The target network must permit IPv6 and mDNS/DNS-SD between the controller and
the device. Live-sensor and controller end-to-end validation remains dependent
on the production sensor command; the deterministic stub and unit tests cover
the provider behavior in the meantime.
