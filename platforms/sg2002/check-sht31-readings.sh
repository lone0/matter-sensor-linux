#!/usr/bin/env bash
# Checks the published SHT31 status and stable RTC reading without reloading firmware.
set -euo pipefail

readonly rtc_info_status=0x0502601c
readonly rtc_info_detail=0x05026020
readonly rtc_info_sequence=0x05026028
readonly status_ready=0x4932434f
readonly interval_seconds=${SHT31_VALIDATE_INTERVAL_SECONDS:-2}
devmem=${SG2002_DEVMEM:-busybox}
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if ! [[ $interval_seconds =~ ^[0-9]+$ ]]; then
    echo "SHT31_VALIDATE_INTERVAL_SECONDS must be a non-negative integer" >&2
    exit 2
fi

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

status=$(read_register "$rtc_info_status")
detail=$(read_register "$rtc_info_detail")
sequence_before=$(read_register "$rtc_info_sequence")
if ((status != status_ready)); then
    printf 'SHT31 firmware is not publishing valid readings: status=0x%08X detail=0x%08X\n' \
        "$status" "$detail" >&2
    exit 1
fi

reading=$(SG2002_DEVMEM="$devmem" "$script_dir/read-rtc-info.sh")
sleep "$interval_seconds"
sequence_after=$(read_register "$rtc_info_sequence")
if ((sequence_before == 0 || sequence_before == sequence_after)); then
    echo "SHT31 firmware did not publish a new RTC reading" >&2
    exit 1
fi

printf 'SHT31 status=I2CO sequence=%u->%u %s\n' "$sequence_before" "$sequence_after" "$reading"
