# SG2002 Troubleshooting

Follow these steps in order. Begin with checks that do not interrupt Matter or
reload the 8051. Do not proceed to firmware replacement or benchmarking unless
the earlier steps identify a reason to do so.

## 1. Confirm the service is running

```sh
sudo systemctl status matter-temperature-humidity-sensor
sudo journalctl -u matter-temperature-humidity-sensor -b --no-pager -n 100
```

The service should be `active (running)`. If a pre-start command failed, the
journal identifies whether I2C3 preparation, GPIOP20 pinmux, or 8051 firmware
loading failed. The service writes all application diagnostics to the systemd
journal; it does not create dedicated log files.

### Observe the optional GPIOP20 heartbeat LED

GPIOP20 is a debugging/status output. When an external LED is wired as shown
below, production and fake firmware toggle it once per acquisition cycle:

```text
GPIOP20 -> 1 kOhm resistor -> LED anode
GND     -> LED cathode
```

A toggling LED confirms that the 8051 started and is executing its acquisition
loop. A static LED or no LED activity points to firmware loading, GPIOP20
pinmux, or 8051 execution trouble. It does not prove that the SHT31 reading is
valid; run Step 2 or Step 3 for that.

## 2. Check the current SHT31 reading

This command is non-disruptive. It does not change pinmux, reload firmware, or
restart Matter:

```sh
sudo /usr/local/libexec/matter-sensor-sg2002/check-sht31-readings.sh
```

Expected output includes `I2CO`, an advancing sequence, and decoded
temperature/humidity JSON. If this succeeds but Home Assistant is unavailable,
skip to [Step 5](#5-check-matter-fabric-state).

## 3. Collect an RTC/8051 probe report

The probe reads and decodes the current firmware ABI without changing board
state:

```sh
sudo /usr/local/libexec/matter-sensor-sg2002/probe-rtc-info.sh \
  > /tmp/sg2002-rtc-info.txt
cat /tmp/sg2002-rtc-info.txt
```

| Status | Meaning | Next action |
| --- | --- | --- |
| `I2CO` | SHT31 is publishing a valid measurement. | Continue with Matter checks if HA is unavailable. |
| `I2CR` | SHT31 firmware is starting. | Wait one sensor cycle and repeat Step 2. |
| `I2C!` | I2C transaction failed; the probe prints the DesignWare abort source. | Check 3.3 V, common ground, GPIOP22/23 wiring, pull-ups, and address `0x44`. |
| `CRC!` | Sensor frame CRC failed; the probe includes the raw frame bytes. | Check wiring quality and pull-ups. |
| `RNG!` | Converted reading was outside the supported range. | Check sensor operation and collect a new report. |
| `FAKE` | Fixed-reading debug firmware is active. | Restore production SHT31 firmware in Step 7. |
| `BMRN`, `BMOK`, `OVFL` | GPIO bridge benchmark is running, complete, or overflowed. | Restore production firmware in Step 8. |

## 4. Run the complete hardware test

Use this only when I2C3 handoff, GPIOP20 setup, or 8051 loading is suspect. It
reconfigures I2C3 and GPIOP20, reloads production firmware, and then validates
an advancing SHT31 reading:

```sh
sudo /usr/local/libexec/matter-sensor-sg2002/test-sht31-hardware.sh
```

It is disruptive to the running service; normal operation resumes when the
service next loads the production image.

## 5. Check Matter fabric state

When SHT31 checks pass but Home Assistant is unavailable, inspect the
persistent KVS and service logs:

```sh
sudo ls -l /var/lib/matter-temperature-humidity-sensor/chip-kvs
sudo journalctl -u matter-temperature-humidity-sensor -b --no-pager | \
  grep -E 'Operational device|Key not found|CASE'
```

The service must start with:

```text
--KVS /var/lib/matter-temperature-humidity-sensor/chip-kvs
```

`Operational device` indicates the node retained its fabric. `Key not found`
indicates Home Assistant has stale fabric credentials; remove and recommission
the device in HA.

## 6. Isolate Matter and RTC reporting with fixed readings

Use fixed readings only after the physical SHT31 path is suspect. This proves
the 8051-to-RTC-to-Matter path with `23.45 C` and `56.78 %`.

Edit the SG2002 service drop-in:

```sh
sudoedit /etc/systemd/system/matter-temperature-humidity-sensor.service.d/sg2002.conf
```

Change the firmware image in the final `ExecStartPre` line to:

```text
/usr/local/lib/matter-sensor-sg2002/mars_mcu_fw_fake.bin
```

Apply the change and verify the probe reports `FAKE`:

```sh
sudo systemctl daemon-reload
sudo systemctl restart matter-temperature-humidity-sensor
sudo /usr/local/libexec/matter-sensor-sg2002/probe-rtc-info.sh \
  > /tmp/sg2002-rtc-info.txt
grep -E 'Firmware:|Decoded reading:' /tmp/sg2002-rtc-info.txt
```

Restore `mars_mcu_fw_sht31.bin` in the same drop-in line, reload systemd, and
restart the service before returning the device to normal operation.

## 7. Benchmark the 8051 AP-GPIO bridge

The benchmark is not built or deployed by default. Use it only to investigate
AP-GPIO bridge timing; it does not perform sensor acquisition.

On the build host:

```sh
make -C platforms/sg2002/8051 benchmark
scp platforms/sg2002/8051/build/robot_read_benchmark.bin root@<nano-ip>:/tmp/
```

On the Nano:

```sh
sudo systemctl stop matter-temperature-humidity-sensor
sudo /usr/local/libexec/matter-sensor-sg2002/8051_up \
  /tmp/robot_read_benchmark.bin
sleep 3
sudo /usr/local/libexec/matter-sensor-sg2002/probe-rtc-info.sh \
  > /tmp/sg2002-rtc-info.txt
grep -E 'Firmware:|Benchmark' /tmp/sg2002-rtc-info.txt
sudo systemctl start matter-temperature-humidity-sensor
```

`BMOK` reports calibrated timer ticks, total bridge-read ticks, read count, and
the calculated microseconds per read. The final service start restores the
production SHT31 image.
