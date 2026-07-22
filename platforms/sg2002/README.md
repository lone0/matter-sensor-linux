# SG2002 RTC Information Backend

This is the SG2002 platform integration for the generic Linux Matter
application. The Matter binary remains platform-neutral: it invokes
`read-rtc-info.sh`, which emits the normal sensor JSON contract. The 8051
firmware acquires DHT11 data and publishes it through RTC information
registers.

## Deploy

Complete the generic application installation in the repository root
[`README.md`](../../README.md#deploy) first.

### 1. Build the platform artifacts on the Ubuntu host

```sh
sudo apt install -y sdcc
make platform PLATFORM=sg2002
```

This produces:

```text
platforms/sg2002/8051/build/mars_mcu_fw.bin
platforms/sg2002/8051/build/8051_up
```

### 2. Wire and install the 8051 firmware

Wire the DHT11 at 3.3 V:

```text
GPIOA26 -> DHT11 DATA, with a 4.7-10 kOhm pull-up to 3.3 V
3.3 V    -> DHT11 VCC
GND      -> DHT11 GND
```

Wire the external LED:

```text
GPIOP20 -> 1 kOhm resistor -> LED anode
GND     -> LED cathode
```

Never use a 5 V pull-up on the DHT11 data line.

Copy the firmware, loader, and GPIO preparation script to the Nano:

```sh
scp platforms/sg2002/8051/build/mars_mcu_fw.bin root@nano:/root/
scp platforms/sg2002/8051/build/8051_up root@nano:/root/
scp platforms/sg2002/8051/prepare-gpios.sh root@nano:/root/

ssh root@nano
chmod 0755 /root/8051_up /root/prepare-gpios.sh
install -D -m 0755 /root/prepare-gpios.sh \
  /usr/local/libexec/matter-sensor-sg2002/prepare-gpios.sh
install -m 0755 /root/8051_up \
  /usr/local/libexec/matter-sensor-sg2002/8051_up
install -D -m 0644 /root/mars_mcu_fw.bin \
  /usr/local/lib/matter-sensor-sg2002/mars_mcu_fw.bin
```

The SG2002 service runs `prepare-gpios.sh --configure-led-gpio` and `8051_up`
as root before starting the unprivileged Matter process. Therefore GPIOP20
preparation and 8051 loading occur automatically on every service start and
after every reboot. The preparation command refuses to repurpose GPIOP20 when
MTD or SPI devices are present, because its boot function is SPI-NOR
write-protect. The LicheeRV Nano Debian 13 image verified for this integration
boots from SD and has neither.

### 3. Install and enable the Matter sensor reader

On the Nano, from this copied `platforms/sg2002` directory:

```sh
./install-dependencies.sh --install

install -D -m 0755 read-rtc-info.sh \
  /usr/local/libexec/matter-sensor-sg2002/read-rtc-info.sh
install -m 0644 sensor.conf.example \
  /etc/matter-temperature-humidity-sensor.conf
install -m 0644 matter-temperature-humidity-sensor.service \
  /etc/systemd/system/matter-temperature-humidity-sensor.service

systemctl daemon-reload
systemctl enable --now matter-temperature-humidity-sensor
```

The dependency script installs `gpiod`, BusyBox `devmem`, and Matter runtime
packages required by the pre-start and reader commands. If either pre-start
command fails, systemd does not start the Matter process; inspect the failure
with:

```sh
journalctl -u matter-temperature-humidity-sensor -b
```

For commissioning without the 8051/DHT11, install `read-fake-sensor.sh` and
`sensor-fake.conf.example` instead. The fake reader reports `23.45 C` and
`56.78 %`.

## Linux and 8051 interaction

The two cores have distinct responsibilities:

| Component | Responsibility |
| --- | --- |
| Linux core | Runs Matter, starts the 8051 loader, reads RTC publications, and exposes them as standard Matter attributes. |
| 8051 core | Drives the DHT11 waveform, validates its checksum, controls the diagnostic LED, and publishes sensor data. |
| RTC information registers | Stable, small handoff channel from 8051 firmware to the Linux sensor command. |
| RTC power GPIO20 | GPIOP20 LED output controlled directly by the 8051. It is not a Linux `gpiochip`. |

The design avoids platform MMIO in the generic Matter process. It also avoids
using a Linux-owned AP GPIO for the LED: competing Linux and 8051 writes would
be last-writer-wins. GPIOP20 is instead muxed to RTC power GPIO20, which the
8051 accesses directly.

The systemd service is the lifecycle boundary: its privileged pre-start steps
prepare GPIOP20 and reset/load the 8051 firmware, then its unprivileged main
process reads the 8051 publications through `read-rtc-info.sh`. Restarting the
service intentionally resets the 8051 and restarts acquisition.

For every valid measurement, the 8051 writes `RTC_INFO2` first and then a
nonzero incremented `RTC_INFO3` sequence. `read-rtc-info.sh` reads sequence,
measurement, sequence and only emits JSON when the sequence is stable. Failed
or partial publications therefore leave the Matter device's previous valid
value intact.

## Diagnosis

All commands in this section are manual diagnostics; the service only invokes
`read-rtc-info.sh`.

### Diagnostic tools

| Tool | Purpose |
| --- | --- |
| `probe-rtc-info.sh` | Human-readable board report: system, `/dev/mem`, BusyBox `devmem`, RTC registers, decoded reading, and relevant kernel messages. It is not used by the service. |
| `read-rtc-info.sh` | Production `sensor_command`; emits exactly one JSON object after a stable RTC read. |
| `read-fake-sensor.sh` | Fixed-value commissioning/debug sensor command. |
| `prepare-gpios.sh` | Checks DHT GPIOA26 ownership and configures GPIOP20's pinmux only when the SPI-NOR safety conditions hold. |
| `8051_up` | Holds the 8051 in reset, loads `mars_mcu_fw.bin` into RTC SRAM, and releases reset. It is safe to rerun serially. |

### RTC information registers

| Register | Address | Meaning |
| --- | ---: | --- |
| `RTC_INFO0` | `0x0502601c` | Firmware status: `BLNK` (`0x424c4e4b`), `ER01` no DHT response, `ER02` timing, `ER03` checksum, `ER04` range. |
| `RTC_INFO1` | `0x05026020` | Reserved command register. |
| `RTC_INFO2` | `0x05026024` | Packed measurement: signed temperature centi-degrees C in bits `15:0`, unsigned humidity centi-percent in bits `31:16`. |
| `RTC_INFO3` | `0x05026028` | Nonzero publication sequence. |

Read the current values:

```sh
busybox devmem 0x0502601c 32
busybox devmem 0x05026024 32
busybox devmem 0x05026028 32
./probe-rtc-info.sh
```

`ER01` confirms the 8051 firmware is executing but the DHT11 did not respond.

### GPIOP20 mux and RTC power GPIO control

GPIOP20 is physically on the right header directly above GPIOA14. Its mux
register is `0x030010d8`; its low three-bit selector must be `3` to route the
pad to RTC power GPIO20:

```sh
value=$(busybox devmem 0x030010d8 32)
printf 'GPIOP20 mux selector: %d\n' "$((value & 0x7))"
```

RTC power GPIO registers use bit 20 for GPIOP20:

| Register | Address | Bit 20 meaning |
| --- | ---: | --- |
| Data output | `0x05021000` | Output latch: `1` high, `0` low. |
| Direction | `0x05021004` | `1` output, `0` input. |
| Input sample | `0x05021050` | Physical pad level. |

Inspect the current LED state:

```sh
for register in 0x05021000 0x05021004 0x05021050; do
  value=$(busybox devmem "$register" 32)
  printf '%s bit20=%d\n' "$register" "$(((value >> 20) & 1))"
done
```

For a manual LED test, first hold the 8051 in reset, then update bit 20 with
read-modify-write operations:

```sh
busybox devmem 0x05025018 32 0x8107fffd

mask=$((1 << 20))
direction=$(busybox devmem 0x05021004 32)
busybox devmem 0x05021004 32 "$((direction | mask))"

data=$(busybox devmem 0x05021000 32)
busybox devmem 0x05021000 32 "$((data | mask))"   # LED high
busybox devmem 0x05021000 32 "$((data & ~mask))"  # LED low
```

Reload the firmware with `8051_up` when the manual test is complete.

Do not use `gpiod`, `gpioset`, or `gpiochip3` for GPIOP20: those refer to AP
GPIO controller `0x03023000`, not RTC power GPIO `0x05021000`. Manual writes
to the RTC GPIO registers compete with the 8051 firmware; reload the firmware
after any manual LED test.

### DHT GPIOA26

GPIOA26 is the left-header pin immediately above the two 5 V pins. It has an
eMMC alternate function, so retain the `prepare-gpios.sh` check before loading
firmware. The DHT11 data line is open-drain: the 8051 drives low, releases it
to input, and relies on the external 3.3 V pull-up.

## Contents

| File | Purpose |
| --- | --- |
| `install-dependencies.sh` | Installs and checks SG2002 Matter runtime dependencies and BusyBox `devmem`. |
| `matter-temperature-humidity-sensor.service` | Service unit granting the RTC reader `CAP_SYS_RAWIO`. |
| `read-rtc-info.sh` | Production RTC reader. |
| `read-fake-sensor.sh` | Fixed-value commissioning reader. |
| `sensor.conf.example` | Configuration selecting the RTC reader. |
| `sensor-fake.conf.example` | Configuration selecting the fake reader. |
| `probe-rtc-info.sh` | Manual RTC diagnostic report. |
| `8051/` | SDCC firmware, loader source, and GPIO preparation script. |

## Tests

`make test` runs the RTC and fake-reader tests without requiring an SG2002
board. `make platform PLATFORM=sg2002` validates the platform scripts, builds
the 8051 firmware and RISC-V loader, and rejects firmware images larger than
the 8 KiB RTC SRAM.
