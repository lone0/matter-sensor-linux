# Matter Temperature and Humidity Sensor for Linux

Turn a Debian 12 Linux device, such as an Ethernet-connected Raspberry Pi, into
a native Matter temperature and relative-humidity sensor. The application is
derived from Project CHIP/connectedhomeip's Linux architecture and has no Snap
or Snapcraft dependency.

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

The repository uses profile-driven Debian cross builds. Architecture facts live
in `configs/architectures/*.conf`; common scripts create sysroots and build any
selected profile. This keeps sysroots and outputs separate per architecture.

## Quick start

```sh
git clone <repository-url> matter-temperature-humidity-sensor
cd matter-temperature-humidity-sensor
git submodule update --init --recursive

sudo apt update
sudo apt install -y \
  pkg-config libssl-dev libavahi-client-dev libdbus-1-dev \
  libglib2.0-dev libglib2.0-dev-bin \
  mmdebstrap debian-archive-keyring jq

make test
make host
```

The host binary is written to:

```text
out/host/matter-temperature-humidity-sensor
```

For development, copy `config/sensor.conf.example`, set `sensor_command` to
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

## Debian 12 profile builds

Install the GCC 12 cross compiler for the chosen architecture. GCC 12 is used
because newer Ubuntu cross compilers can introduce GLIBC requirements newer than
Debian 12 supports.

```sh
# arm64
sudo apt install -y gcc-12-aarch64-linux-gnu g++-12-aarch64-linux-gnu

# armhf
sudo apt install -y gcc-12-arm-linux-gnueabihf g++-12-arm-linux-gnueabihf
```

Create the Debian 12 sysroot and build using a profile:

```sh
make sysroot ARCH=arm64
make build ARCH=arm64

# Or:
make sysroot ARCH=armhf
make build ARCH=armhf

# riscv64 with the supplied QEMU sysroot and GCC 12 cross compiler
make build ARCH=riscv64 SYSROOT=/mnt/storage/riscv64-qemu-sysroot \
  CROSS_GCC=/usr/bin/riscv64-linux-gnu-gcc-12 \
  CROSS_GXX=/usr/bin/riscv64-linux-gnu-g++-12
```

The result is placed at:

```text
out/debian12-<debian-architecture>/matter-temperature-humidity-sensor
```

The generic build script wraps the Ubuntu compiler so headers and runtime
libraries come from the Debian sysroot. It then rejects a binary requiring
GLIBC newer than Debian 12's `GLIBC_2.36`.

Equivalent direct commands are:

```sh
./scripts/create-debian-sysroot.sh --profile arm64 sysroot/debian12-arm64 bookworm
./scripts/build-debian.sh arm64 sysroot/debian12-arm64
```

The older `create-debian12-sysroot.sh` and `build-debian12-arm64.sh` scripts
remain as arm64 compatibility wrappers.

## Porting guide

### Add an architecture already supported by CHIP Linux GN

CHIP's supplied Linux GN toolchains support `x64`, `x86`, `arm`, and `arm64`.
This repository also adds Linux `riscv64` support to its connectedhomeip
submodule. For one of these, create
`configs/architectures/<profile>.conf` by copying `arm64.conf`, `armhf.conf`,
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
| `DEBIAN_ARCH` | Argument passed to `mmdebstrap`; also names the output directory. |
| `GN_TARGET_CPU` | CHIP GN CPU identifier. |
| `GNU_TRIPLET` | Prefix of the Ubuntu cross compiler binaries. |
| `DEBIAN_MULTIARCH` | Debian sysroot include and library directory name. |
| `GCC_VERSION` | Cross compiler and Debian `libstdc++-<version>-dev` version. |
| `OUTPUT_DIR` | Optional output directory suffix; used by external sysroots. |
| `GLIBC_MAX_VERSION` | Optional maximum supported GLIBC version; defaults to Debian 12's `2.36`. |

Install the matching compiler, then run:

```sh
make sysroot ARCH=<profile>
make build ARCH=<profile>
```

The profile builder creates `sysroot/debian12-<DEBIAN_ARCH>` and
`out/debian12-<DEBIAN_ARCH>`, so multiple architectures can coexist.

### Add a completely new CPU family

First confirm Debian 12 has packages for the desired architecture. A CPU family
outside the repository's existing `x64`, `x86`, `arm`, `arm64`, and `riscv64`
Linux GN support requires a connectedhomeip build port, not merely a new project
profile. Then:

1. Add the architecture profile described above.
2. Add a matching GNU toolchain target in
   `third_party/connectedhomeip/build/toolchain/linux/BUILD.gn`.
3. Ensure the new GN toolchain uses the profile's `GNU_TRIPLET`.
4. Map the architecture to a supported `GN_TARGET_CPU`, or extend CHIP's build
   configuration for the new CPU.
5. Run `make sysroot ARCH=<profile>` and `make build ARCH=<profile>`.
6. Confirm the result using `file` and `readelf --version-info`; its highest
   `GLIBC_*` requirement must not exceed `GLIBC_2.36`.

## Deploy

Copy the target binary to `/usr/local/bin/matter-temperature-humidity-sensor`,
install the sensor configuration at
`/etc/matter-temperature-humidity-sensor.conf`, and install the systemd unit:

```sh
sudo useradd --system \
  --home /var/lib/matter-temperature-humidity-sensor \
  --shell /usr/sbin/nologin \
  matter-sensor
sudo install -m 0644 deploy/matter-temperature-humidity-sensor.service \
  /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now matter-temperature-humidity-sensor
```

The target network must permit IPv6 and mDNS/DNS-SD between the controller and
the device. Live-sensor and controller end-to-end validation remains dependent
on the production sensor command; the deterministic stub and unit tests cover
the provider behavior in the meantime.
