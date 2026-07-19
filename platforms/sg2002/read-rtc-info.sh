#!/usr/bin/env bash
set -euo pipefail

readonly rtc_info_measurement=0x05026024
readonly rtc_info_sequence=0x05026028
devmem=${SG2002_DEVMEM:-busybox}

read_register() {
    local value
    value=$("$devmem" devmem "$1" 32)
    case $value in
        0x[0-9a-fA-F]* | [0-9]*)
            printf '%u\n' "$((value))"
            ;;
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

sequence_before=$(read_register "$rtc_info_sequence")
measurement=$(read_register "$rtc_info_measurement")
sequence_after=$(read_register "$rtc_info_sequence")

if ((sequence_before == 0 || sequence_before != sequence_after)); then
    echo "8051 has not published a stable RTC information reading" >&2
    exit 1
fi

temperature=$((measurement & 0xffff))
if ((temperature >= 0x8000)); then
    temperature=$((temperature - 0x10000))
fi
humidity=$((measurement >> 16))

if ((temperature < -27315 || humidity > 10000)); then
    echo "RTC information registers contain an out-of-range reading" >&2
    exit 1
fi

printf '{"temperature_c":%s,"humidity_percent":%s}\n' "$(format_centi "$temperature")" "$(format_centi "$humidity")"
