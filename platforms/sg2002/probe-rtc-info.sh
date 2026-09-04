#!/usr/bin/env bash
set -euo pipefail

readonly rtc_info_status=0x0502601c
readonly rtc_info_detail=0x05026020
readonly rtc_info_measurement=0x05026024
readonly rtc_info_sequence=0x05026028
readonly status_sht31_starting=0x49324352
readonly status_sht31_ready=0x4932434f
readonly status_sht31_i2c_error=0x49324321
readonly status_sht31_crc_error=0x43524321
readonly status_sht31_range_error=0x524e4721
readonly status_sht31_debounce=0x44454221
readonly status_fake=0x46414b45
readonly status_benchmark_running=0x424d524e
readonly status_benchmark_complete=0x424d4f4b
readonly status_benchmark_overflow=0x4f56464c

devmem=${SG2002_DEVMEM:-busybox}

if (($# != 0)); then
    echo "usage: $0" >&2
    exit 2
fi

read_register() {
    local value

    value=$("$devmem" devmem "$1" 32)
    case $value in
        0x[0-9a-fA-F]* | [0-9]*) printf '%u\n' "$((value))" ;;
        *)
            echo "unexpected devmem output for $1: $value" >&2
            return 1
            ;;
    esac
}

format_centi() {
    local value=$1
    local sign=

    if ((value < 0)); then
        sign=-
        value=$((-value))
    fi
    printf '%s%d.%02d' "$sign" "$((value / 100))" "$((value % 100))"
}

decode_measurement() {
    local measurement=$1
    local temperature=$((measurement & 0xffff))
    local humidity=$((measurement >> 16))

    if ((temperature >= 0x8000)); then
        temperature=$((temperature - 0x10000))
    fi
    printf 'Decoded reading: temperature=%s C humidity=%s %%\n' \
        "$(format_centi "$temperature")" "$(format_centi "$humidity")"
}

echo "== System =="
uname -a
cat /etc/os-release

echo "== RTC information backend =="
printf '/dev/mem: '
if [[ -r /dev/mem ]]; then
    echo readable
else
    echo not-readable
fi
printf 'devmem command: '
if [[ $devmem == busybox ]]; then
    busybox_applets=$(busybox --list 2>/dev/null)
    if grep -qx devmem <<<"$busybox_applets"; then
        echo "BusyBox devmem"
    else
        echo unavailable
    fi
else
    echo "$devmem"
fi

echo "== RTC information registers =="
if [[ ${EUID:-$(id -u)} -ne 0 && ${SG2002_PROBE_ALLOW_UNPRIVILEGED:-0} != 1 ]]; then
    echo "Run this probe with sudo to read physical registers."
else
    status=$(read_register "$rtc_info_status")
    detail=$(read_register "$rtc_info_detail")
    measurement=$(read_register "$rtc_info_measurement")
    sequence=$(read_register "$rtc_info_sequence")
    printf 'RTC_INFO0 firmware status: 0x%08X\n' "$status"
    printf 'RTC_INFO1 detail: 0x%08X\n' "$detail"
    printf 'RTC_INFO2 payload: 0x%08X\n' "$measurement"
    printf 'RTC_INFO3 sequence: %u\n' "$sequence"

    case $status in
        "$((status_sht31_ready))")
            echo "Firmware: SHT31 measurement publisher (I2CO)"
            decode_measurement "$measurement"
            ;;
        "$((status_fake))")
            echo "Firmware: fixed-reading debug publisher (FAKE)"
            decode_measurement "$measurement"
            ;;
        "$((status_sht31_starting))")
            echo "Firmware: SHT31 publisher starting (I2CR); no reading is available yet."
            ;;
        "$((status_sht31_i2c_error))")
            printf 'Firmware: SHT31 I2C transaction failure (I2C!), abort source=0x%08X\n' "$detail"
            ;;
        "$((status_sht31_crc_error))")
            printf 'Firmware: SHT31 CRC failure (CRC!), received CRC bytes: temperature=0x%02X humidity=0x%02X\n' \
                "$((detail >> 8))" "$((detail & 0xff))"
            printf 'SHT31 raw data bytes: temperature=0x%04X humidity=0x%04X\n' \
                "$((measurement >> 16))" "$((measurement & 0xffff))"
            ;;
        "$((status_sht31_range_error))")
            echo "Firmware: SHT31 converted reading is outside its valid range (RNG!)."
            ;;
        "$((status_sht31_debounce))")
            echo "Firmware: SHT31 reading filtered by debounce logic (DEB!)."
            temperature_direction=$((detail >> 16))
            humidity_direction=$((detail & 0xffff))
            if ((temperature_direction >= 0x8000)); then
                temperature_direction=$((temperature_direction - 0x10000))
            fi
            if ((humidity_direction >= 0x8000)); then
                humidity_direction=$((humidity_direction - 0x10000))
            fi
            printf 'Temperature direction: %d, humidity direction: %d\n' \
                "$temperature_direction" "$humidity_direction"
            ;;
        "$((status_benchmark_running))")
            echo "Firmware: GPIO bridge benchmark running (BMRN)."
            ;;
        "$((status_benchmark_complete))")
            echo "Firmware: GPIO bridge benchmark complete (BMOK)."
            printf 'Benchmark: timer=%u ticks/s total=%u ticks reads=%u\n' \
                "$detail" "$measurement" "$sequence"
            if ((detail != 0 && sequence != 0)); then
                printf 'Benchmark average: %s us/read\n' \
                    "$(format_centi "$((100000000 * measurement / detail / sequence))")"
            fi
            ;;
        "$((status_benchmark_overflow))")
            echo "Firmware: GPIO bridge benchmark overflowed (OVFL)."
            ;;
        *)
            echo "Firmware: unknown status."
            ;;
    esac
fi

echo "== Relevant kernel messages =="
dmesg 2>/dev/null | grep -Ei 'rtc|8051|mcu' || true
