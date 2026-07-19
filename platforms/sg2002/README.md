# SG2002 RTC Information Backend

This directory is the SG2002-specific DHT11 integration for the generic Linux
Matter application. The main application remains configured with its normal
`sensor_command` interface and has no SG2002 MMIO code.

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

## Install on the board

```sh
sudo ./install-dependencies.sh --install
sudo ./probe-rtc-info.sh

sudo install -D -m 0755 read-rtc-info.sh \
  /usr/local/libexec/matter-sensor-sg2002/read-rtc-info.sh
sudo install -m 0644 sensor.conf.example \
  /etc/matter-temperature-humidity-sensor.conf
sudo install -m 0644 matter-temperature-humidity-sensor.service \
  /etc/systemd/system/matter-temperature-humidity-sensor.service
sudo systemctl daemon-reload
sudo systemctl enable --now matter-temperature-humidity-sensor
```

The SG2002 service grants `CAP_SYS_RAWIO` to its unprivileged account, allowing
the child `busybox devmem` command to read `/dev/mem`. Do not use the generic
service unit for this backend.
