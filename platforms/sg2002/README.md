# SG2002 SHT31 Matter Backend

This platform integration keeps Matter platform-neutral: the Linux application
executes `read-rtc-info.sh`, which reads measurements published by the SG2002
RTC-domain 8051.

## Firmware images

Exactly three 8051 firmware sources are retained:

| Source | Binary | Purpose | Built by `make` |
| --- | --- | --- | --- |
| `sht31-firmware.c` | `mars_mcu_fw_sht31.bin` | Production SHT31 temperature/humidity acquisition over I2C3. | Yes |
| `fake-firmware.c` | `mars_mcu_fw_fake.bin` | Fixed `23.45 C` and `56.78 %` debug readings. | Yes |
| `robot-read-benchmark.c` | `robot_read_benchmark.bin` | GPIO bridge timing diagnostic. | No; use `make benchmark`. |

The SSH installer installs all three images. The default
`matter-temperature-humidity-sensor.service` loads
`mars_mcu_fw_sht31.bin`; loading the fake image requires the explicit service
change described below.

## Deploy

First install the main Matter application and its generic systemd service:

```sh
./deploy/deploy-main-program-over-ssh.sh 192.168.28.48
```

Pass an already-built Matter binary as its second argument when it is not at
`out/linux-riscv64/matter-temperature-humidity-sensor`. Then build and deploy
only the SG2002 platform integration:

```sh
sudo apt install -y sdcc
make platform PLATFORM=sg2002
./platforms/sg2002/deploy-sg2002-platform-over-ssh.sh 192.168.28.48
```

Wire the SHT31 at 3.3 V:

```text
GPIOP22 / IIC3_SCL -> SHT31 SCL
GPIOP23 / IIC3_SDA -> SHT31 SDA
3.3 V              -> SHT31 VCC
GND                -> SHT31 GND
```

Use suitable 3.3 V I2C pull-ups when the breakout board does not provide
them. The production image expects the default SHT31 address `0x44`.

The platform installer installs a systemd drop-in. It hands AP I2C3 from Linux
to the 8051 on each service start. It unbinds
Linux device `4030000.i2c`, selects the GPIOP22/23 IIC3 function, restores the
I2C clock/reset, and then loads the SHT31 image. This handoff is reset by a
reboot. Disable `&i2c3` in the board device tree for permanent 8051 ownership.

## Target commands

Run the full disruptive hardware test, which prepares I2C3, loads production
firmware, and checks readings:

```sh
sudo /usr/local/libexec/matter-sensor-sg2002/test-sht31-hardware.sh
```

Run a non-disruptive health check of the already-running production firmware:

```sh
sudo /usr/local/libexec/matter-sensor-sg2002/check-sht31-readings.sh
```

The SHT31 reports `I2CO` when publishing. `I2C!` records the DesignWare abort
source in `RTC_INFO1`; `CRC!` and `RNG!` identify invalid sensor frames and
converted values.

## Using fixed debug readings

The fake image is installed at:

```text
/usr/local/lib/matter-sensor-sg2002/mars_mcu_fw_fake.bin
```

To switch deliberately, edit
`/etc/systemd/system/matter-temperature-humidity-sensor.service` and change
only this `ExecStartPre` image path:

```ini
.../8051_up /usr/local/lib/matter-sensor-sg2002/mars_mcu_fw_fake.bin
```

Then apply it:

```sh
sudo systemctl daemon-reload
sudo systemctl restart matter-temperature-humidity-sensor
```

Restore `mars_mcu_fw_sht31.bin` in the same line and restart to return to
physical sensor readings.

## Benchmark firmware

Build the benchmark only when diagnosing the 8051 AP-GPIO bridge:

```sh
make -C platforms/sg2002/8051 benchmark
```

Temporarily load `robot_read_benchmark.bin` with `8051_up`. It reports `BMOK`
in `RTC_INFO0`; `RTC_INFO1` is calibrated Timer0 ticks/second, `RTC_INFO2` is
the total bridge-read ticks, and `RTC_INFO3` is the read count. Reload the
production SHT31 image after the benchmark.

## RTC publication ABI

| Register | Address | Meaning |
| --- | ---: | --- |
| `RTC_INFO0` | `0x0502601c` | Firmware status. |
| `RTC_INFO1` | `0x05026020` | SHT31 abort source for `I2C!`; otherwise reserved. |
| `RTC_INFO2` | `0x05026024` | Signed temperature centi-degrees C in bits `15:0`; humidity centi-percent in bits `31:16`. |
| `RTC_INFO3` | `0x05026028` | Nonzero publication sequence. |

The writer publishes `RTC_INFO2` before incrementing `RTC_INFO3`.
`read-rtc-info.sh` accepts only a stable sequence/measurement/sequence read.

## Tests

`make test` runs host-side reader and SHT31-health-check tests. `make platform
PLATFORM=sg2002` syntax-checks platform scripts and builds the production and
fake images plus the RISC-V loader. All firmware images are constrained to the
8 KiB RTC SRAM limit.
