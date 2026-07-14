# Matter temperature and humidity sensor for Linux

This is a native Linux Matter device application for Debian 12 arm64 systems,
such as an Ethernet-connected Raspberry Pi. It exposes the standard Temperature
Measurement and Relative Humidity Measurement server clusters. It is derived
from Project CHIP/connectedhomeip's Linux application architecture and does not
use Snap or Snapcraft.

The device is commissioned on the local Ethernet/IPv6 network. Bluetooth LE is
disabled. The host network must allow IPv6 and mDNS/DNS-SD traffic between the
controller and device.

## Sensor command contract

The sensor is an external userspace command configured in
`/etc/matter-temperature-humidity-sensor.conf`. The command is invoked directly
with `execvp`; the application never passes it to a shell. It must exit zero and
write exactly one object to stdout:

```json
{"temperature_c":23.45,"humidity_percent":56.78}
```

`temperature_c` must be finite and within -273.15 through 327.67. Humidity must
be finite and between 0 and 100. The application converts these to Matter
signed centi-degrees Celsius and unsigned centi-percent respectively. Failed
commands do not publish a replacement value: the last successful value remains
available and the next poll retries the command.

Use `config/sensor.conf.example` as a starting point. Repeated `sensor_arg`
entries provide command arguments without shell parsing.

For development, `scripts/stub-sensor.sh` emits a deterministic reading.

## Build prerequisites

On Ubuntu, install the connectedhomeip prerequisites according to its current
documentation. For Debian sysroot creation, install:

```sh
sudo apt install mmdebstrap debian-archive-keyring jq
```

The native CHIP tools also require the Linux development packages used by the
application:

```sh
sudo apt install pkg-config libssl-dev libavahi-client-dev libdbus-1-dev libglib2.0-dev libglib2.0-dev-bin
```

For Debian 12 compatibility, install the GCC 12 cross packages for the selected
architecture. Newer Ubuntu cross compilers can generate GLIBC symbol
requirements that Debian 12 cannot satisfy:

```sh
sudo apt install gcc-12-aarch64-linux-gnu g++-12-aarch64-linux-gnu  # arm64
# or
sudo apt install gcc-12-arm-linux-gnueabihf g++-12-arm-linux-gnueabihf  # armhf
```

Initialize the pinned CHIP dependency:

```sh
git submodule update --init --recursive
```

Build a host binary:

```sh
./scripts/build-host.sh
```

Run unit tests with the fixture command:

```sh
./tests/run-unit-tests.sh
```

## Debian 12 cross builds

The Ubuntu apt compiler is used only as a compiler. The target headers and
libraries come from a Debian 12 sysroot, ensuring that the binary does not
accidentally require Ubuntu's newer glibc ABI.

```sh
make sysroot ARCH=arm64
make build ARCH=arm64
```

`make build` creates `out/debian12-<architecture>/matter-temperature-humidity-sensor`.
It wraps the Ubuntu compiler so target headers and runtime libraries are
resolved from the Debian sysroot, then rejects binaries requiring a GLIBC newer
than Debian 12's 2.36.

Architecture profiles in `configs/architectures/` define the Debian
architecture, CHIP GN CPU, GNU compiler triplet, Debian multiarch directory,
and GCC version. `arm64` and `armhf` profiles are included:

```sh
make sysroot ARCH=armhf
make build ARCH=armhf
```

To add another profile, copy one of these files and adapt its values. The
generic equivalents are:

```sh
./scripts/create-debian-sysroot.sh --profile <profile> <sysroot-directory> [suite]
./scripts/build-debian.sh <profile> [sysroot-directory]
```

For CPU families other than CHIP's built-in `x64`, `x86`, `arm`, and `arm64`,
also add a matching GNU toolchain to
`third_party/connectedhomeip/build/toolchain/linux/BUILD.gn`.

## Deploy

Copy the arm64 binary to `/usr/local/bin/matter-temperature-humidity-sensor`,
the sensor configuration to `/etc/matter-temperature-humidity-sensor.conf`,
and install `deploy/matter-temperature-humidity-sensor.service`. Create the
`matter-sensor` service user before enabling the service:

```sh
sudo useradd --system --home /var/lib/matter-temperature-humidity-sensor --shell /usr/sbin/nologin matter-sensor
sudo install -m 0644 deploy/matter-temperature-humidity-sensor.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now matter-temperature-humidity-sensor
```

The CHIP Linux startup output includes the setup payload needed by a Matter
controller. Use its on-network commissioning flow and then read endpoint `1`
Temperature Measurement and Relative Humidity Measurement attributes.

Live-sensor and controller end-to-end validation is intentionally deferred
until the production sensor command is available. The deterministic stub and
unit tests cover command execution, JSON validation, unit conversion, failure,
timeout, and output-size behavior in this phase.
