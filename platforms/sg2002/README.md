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
| `8051/` | SDCC firmware, GPIO preflight, and build rules for LED/DHT11 acquisition. |
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

### 8051 LED and DHT11 firmware

Build the firmware on the Ubuntu host. The host package supplies `sdcc` and
`sdobjcopy`; the generated image must not be built on the board.

```sh
sudo apt install -y sdcc
make platform PLATFORM=sg2002
# Output: platforms/sg2002/8051/build/mars_mcu_fw.bin
# Output: platforms/sg2002/8051/build/8051_up
```

The firmware uses **two distinct GPIOA lines**. Its defaults are GPIOA26 for
the DHT11 data line and GPIOA13 for an external diagnostic LED. GPIOA26 has an
eMMC alternate function, so do not assume it is safe merely because it appears
on the header. Before wiring or loading the firmware, verify that both lines
are free on the actual board image. The supplied preflight uses the kernel GPIO
and pinctrl interfaces rather than undocumented raw pinmux writes:

```sh
sudo apt install -y gpiod
cd /path/to/platforms/sg2002/8051
sudo mount -t debugfs none /sys/kernel/debug 2>/dev/null || true
sudo ./prepare-gpios.sh
```

It rejects a line owned by eMMC, SDIO, or a kernel driver and briefly requests
each line so the kernel selects its GPIO function without retaining Linux
ownership. Stop if the preflight fails, or if
`/sys/kernel/debug/pinctrl/*/pinmux-pins` shows either pad muxed to storage;
select verified free header pins and rebuild with:

```sh
make platform PLATFORM=sg2002 DHT_GPIO_PIN=<free-dht-gpioa-line> \
  LED_GPIO_PIN=<free-led-gpioa-line>
```

Connect the DHT11 `VCC` to **3.3 V**, `GND` to board ground, and `DATA` to the
selected DHT GPIO through a 4.7–10 kOhm pull-up to 3.3 V. Connect the LED and
a series resistor to the separate LED GPIO. Never use a 5 V pull-up on either
GPIO, and never put the LED and DHT11 on the same line.

`make platform PLATFORM=sg2002` validates the platform's shell sensor readers,
builds the 8051 firmware, and produces a statically linked RISC-V `8051_up`
loader.
Copy both generated files to the Nano:

```sh
scp platforms/sg2002/8051/build/mars_mcu_fw.bin root@nano:/root/
scp platforms/sg2002/8051/build/8051_up root@nano:/root/
ssh root@nano
cd /root
chmod 0755 8051_up
sudo ./8051_up ./mars_mcu_fw.bin
```

The loader requires root access to `/dev/mem`, bounds the image to the 8 KiB
RTC SRAM, holds the 8051 in reset while loading it, then releases reset. A
serial console is not needed: the LED toggles once per acquisition attempt, and the firmware writes
`0x424C4E4B` (`BLNK`) to `RTC_INFO0` after startup. Error statuses are
`ER01` (no response), `ER02` (timing), `ER03` (checksum), and `ER04` (range).
Observe status and valid publications with:

```sh
sudo busybox devmem 0x0502601c 32  # RTC_INFO0
sudo busybox devmem 0x05026024 32  # packed measurement
sudo busybox devmem 0x05026028 32  # nonzero sequence after a valid read
sudo ./probe-rtc-info.sh
```

After `RTC_INFO2` and `RTC_INFO3` show stable real readings, install the RTC
reader configuration above and restart the Matter service:

```sh
sudo systemctl restart matter-temperature-humidity-sensor
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
SG2002 board or `/dev/mem`. `make platform PLATFORM=sg2002` validates the
sensor reader scripts, compiles the 8051 image, and rejects an image over the
8 KiB RTC-SRAM limit.
