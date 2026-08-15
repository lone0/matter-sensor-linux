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

## Cross Build

Cross-building requires an existing **target development rootfs**, not merely
runtime libraries. It must be for the deployment CPU architecture and include
`/usr/include`, `/usr/lib/<target-multiarch>`, and the target development
packages `libglib2.0-dev`, `libssl-dev`, `libavahi-client-dev`,
`libdbus-1-dev`, and `libglib2.0-dev-bin`.

The built binary cannot require a newer GLIBC than the target rootfs. Debian
13 (trixie) is a good cross-build rootfs because it provides the required
development packages and GLIBC 2.41. Obtain one from the board vendor's Debian
13 image/SDK, or create an architecture-matched trixie rootfs with
`debootstrap` and install the development packages into it.

RISC-V is the maintained default. Install its GCC 12 cross compiler:

```sh
sudo apt install -y gcc-12-riscv64-linux-gnu g++-12-riscv64-linux-gnu
```

Build against the existing RISC-V rootfs:

```sh
make build ARCH=riscv64 SYSROOT=/mnt/storage/riscv64-qemu-sysroot \
  CROSS_GCC=/usr/bin/riscv64-linux-gnu-gcc-12 \
  CROSS_GXX=/usr/bin/riscv64-linux-gnu-g++-12
```

Arm64 is the supported alternative. Its matching compiler and included profile
are used with the same type of development rootfs:

```sh
sudo apt install -y gcc-12-aarch64-linux-gnu g++-12-aarch64-linux-gnu
make build ARCH=arm64 SYSROOT=/path/to/arm64-development-rootfs
```

The build verifies the rootfs headers and multiarch libraries, derives the
maximum supported GLIBC version from its `libc.so.6`, and rejects incompatible
binaries. Output is written to:

```text
out/<profile-output-directory>/matter-temperature-humidity-sensor
```

Without `OUTPUT_DIR` in a profile, the output directory is
`out/linux-<DEBIAN_ARCH>`. RISC-V builds temporarily apply the project’s CHIP
toolchain patch; verify that lifecycle with:

```sh
make test-riscv64 SYSROOT=/path/to/riscv64-development-rootfs
```

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

## Platforms

A platform is a hardware-board-specific integration layer. It supplies the
sensor acquisition, firmware, deployment, service configuration, and
diagnostics needed for one board while the Matter application remains generic.

### LicheeRV Nano (SG2002)

The Sipeed LicheeRV Nano is a compact RISC-V single-board computer based on
the Sophgo SG2002. Its SHT31 integration uses the RTC-domain 8051 and I2C3;
see the [SG2002 platform guide](platforms/sg2002/README.md) for deployment,
wiring, and troubleshooting.

## Deploy

Deployment uses two host-side scripts over SSH: the generic application
deployer owns the Matter binary and base service, while the platform deployer
owns board-specific acquisition and service integration.

For a LicheeRV Nano running Debian 13, first build the RISC-V application and
the SG2002 platform artifacts:

```sh
make build ARCH=riscv64 SYSROOT=/path/to/riscv64-development-rootfs
make platform PLATFORM=sg2002
```

Then deploy in this order:

```sh
./deploy/deploy-main-program-over-ssh.sh 192.168.28.48
./platforms/sg2002/deploy-sg2002-platform-over-ssh.sh 192.168.28.48
```

Pass a different already-built application binary as the second argument to
`deploy-main-program-over-ssh.sh` when it is not at
`out/linux-riscv64/matter-temperature-humidity-sensor`.

`deploy-main-program-over-ssh.sh` installs the Matter binary, its base systemd
unit, runtime dependencies, and the `matter-sensor` service account. It keeps
the Matter KVS under `/var/lib/matter-temperature-humidity-sensor/chip-kvs`
for persistent commissioning state.

`deploy-sg2002-platform-over-ssh.sh` requires the generic deployment first. It
transfers the prebuilt SHT31 and fixed-reading firmware images, the 8051
loader, RTC reader, configuration, and platform diagnostics. It adds the
SG2002 systemd drop-in that grants raw-MMIO access, hands I2C3 to the 8051,
configures GPIOP20, and loads the production SHT31 firmware when the service
starts.

Both scripts connect as `root` to the target. The SG2002 platform deployer
expects a Debian 13 riscv64 board.

The target network must permit IPv6 and mDNS/DNS-SD between the controller and
the device for Matter commissioning and Home Assistant connectivity.
