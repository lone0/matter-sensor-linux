#!/usr/bin/env bash
set -euo pipefail

output=${1:-sg2002-rtc-info-probe.txt}
exec >"$output" 2>&1

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
printf 'BusyBox devmem: '
if busybox --list 2>/dev/null | grep -qx devmem; then
    echo available
else
    echo unavailable
fi

echo "== RTC information registers =="
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "Run this probe with sudo to read physical registers."
else
    status=$(busybox devmem 0x0502601c 32)
    command=$(busybox devmem 0x05026020 32)
    measurement=$(busybox devmem 0x05026024 32)
    sequence=$(busybox devmem 0x05026028 32)
    printf 'RTC_INFO0 firmware status: %s\n' "$status"
    printf 'RTC_INFO1 command: %s\n' "$command"
    printf 'RTC_INFO2 packed reading: %s\n' "$measurement"
    printf 'RTC_INFO3 sequence: %s\n' "$sequence"

    measurement=$((measurement))
    temperature=$((measurement & 0xffff))
    ((temperature >= 0x8000)) && temperature=$((temperature - 0x10000))
    humidity=$((measurement >> 16))
    if ((temperature < 0)); then
        temperature_sign=-
        temperature=$((-temperature))
    else
        temperature_sign=
    fi
    printf 'Decoded reading: temperature=%s%d.%02d C humidity=%d.%02d %%\n' \
        "$temperature_sign" "$((temperature / 100))" "$((temperature % 100))" \
        "$((humidity / 100))" "$((humidity % 100))"
fi

echo "== Relevant kernel messages =="
dmesg | grep -Ei 'rtc|8051|mcu' || true
