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
    for address in 0x0502601c 0x05026020 0x05026024 0x05026028; do
        printf '%s: ' "$address"
        busybox devmem "$address" 32
    done
fi

echo "== Relevant kernel messages =="
dmesg | grep -Ei 'rtc|8051|mcu' || true
