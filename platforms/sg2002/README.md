# SG2002 RTC Information Backend

This directory is the SG2002-specific DHT11 integration for the generic Linux
Matter application. The main application remains configured with its normal
`sensor_command` interface and has no SG2002 MMIO code.

## Contents

| File | Purpose |
| --- | --- |
| `install-dependencies.sh` | Installs and checks SG2002 Matter runtime dependencies and BusyBox `devmem`. |
| `probe-rtc-info.sh` | Reads the RTC information registers on the board before deploying the RTC reader. |
| `read-rtc-info.sh` | Production sensor command that reads 8051-published DHT11 values. |
| `sensor.conf.example` | Configuration selecting `read-rtc-info.sh`. |
| `read-fake-sensor.sh` | Fixed-value sensor command for commissioning and reporting tests. |
| `sensor-fake.conf.example` | Configuration selecting `read-fake-sensor.sh`. |
| `matter-temperature-humidity-sensor.service` | SG2002 service unit with the raw-MMIO capability required by the RTC reader. |
| `tests/test-read-rtc-info.sh` | Host test for RTC reader decoding and stable-sequence behavior. |
| `tests/fake-busybox.sh` | Deterministic `busybox devmem` fixture used only by the RTC reader test. |
| `tests/test-read-fake-sensor.sh` | Host test for the fixed-value reader output. |

`read-rtc-info.sh` uses BusyBox's `devmem` applet to read the RTC-domain 8051
registers:

| Register | Address | Use |
| --- | ---: | --- |
| `RTC_INFO2` | `0x05026024` | Temperature in signed centi-degrees C (`15:0`), humidity in unsigned centi-percent (`31:16`) |
| `RTC_INFO3` | `0x05026028` | Nonzero publication sequence |

The 8051 must write `RTC_INFO2` before incrementing `RTC_INFO3`. The command
reads sequence, measurement, and sequence again; it exits unsuccessfully if
the sequence is zero or changes, so the generic sensor poller preserves the
last valid Matter value.

## Deployment

First complete the generic binary installation in the repository root
[`README.md`](../../README.md#deploy). Then choose one of the following sensor
deployments before enabling the service. Run `install-dependencies.sh` and
`probe-rtc-info.sh` from the copied `platforms/sg2002` directory on the board.

### RTC information reader

Use this after the 8051 DHT11 firmware publishes readings to `RTC_INFO2` and
`RTC_INFO3`.

```sh
sudo ./install-dependencies.sh --install
sudo ./probe-rtc-info.sh

sudo install -D -m 0755 read-rtc-info.sh \
  /usr/local/libexec/matter-sensor-sg2002/read-rtc-info.sh
sudo install -m 0644 sensor.conf.example \
  /etc/matter-temperature-humidity-sensor.conf
```

### Fixed-value debug reader

Use this to commission and verify Matter reporting before the 8051/DHT11
firmware is available. It reports `23.45 C` and `56.78 %`.

```sh
sudo install -D -m 0755 read-fake-sensor.sh \
  /usr/local/libexec/matter-sensor-sg2002/read-fake-sensor.sh
sudo install -m 0644 sensor-fake.conf.example \
  /etc/matter-temperature-humidity-sensor.conf
```

### Enable the SG2002 service

Both sensor choices use the SG2002 service unit. It grants `CAP_SYS_RAWIO` to
the unprivileged service account so the RTC reader's child `busybox devmem`
command can read `/dev/mem`; it is also safe to use with the fixed-value
reader.

```sh
sudo install -m 0644 matter-temperature-humidity-sensor.service \
  /etc/systemd/system/matter-temperature-humidity-sensor.service
sudo systemctl daemon-reload
sudo systemctl enable --now matter-temperature-humidity-sensor
```

## Tests

The repository's `make test` runs both reader tests. They use
`tests/fake-busybox.sh` instead of physical MMIO, so they do not require an
SG2002 board or `/dev/mem`.
