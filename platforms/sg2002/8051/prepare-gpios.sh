#!/usr/bin/env bash
set -euo pipefail

readonly gpiop20_pinmux=0x030010d8
readonly rtc_gpio_function=3

if (($# != 1)) || [[ $1 != --configure-gpiop20 ]]; then
    echo "usage: $0 --configure-gpiop20" >&2
    exit 2
fi
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "run as root to configure GPIOP20 pinmux" >&2
    exit 2
fi
busybox_applets=$(busybox --list 2>/dev/null)
if ! grep -qx devmem <<<"$busybox_applets"; then
    echo "BusyBox devmem is required to configure GPIOP20 pinmux" >&2
    exit 2
fi

value=$(busybox devmem "$gpiop20_pinmux" 32)
busybox devmem "$gpiop20_pinmux" 32 "$(((value & ~0x7) | rtc_gpio_function))"
actual=$(busybox devmem "$gpiop20_pinmux" 32)
if (((actual & 0x7) != rtc_gpio_function)); then
    printf 'failed to select GPIOP20 RTC GPIO function: register=%s value=%s\n' \
        "$gpiop20_pinmux" "$actual" >&2
    exit 1
fi

printf 'GPIOP20 is muxed as RTC GPIO: register=%s value=%s selector=%d\n' \
    "$gpiop20_pinmux" "$actual" "$rtc_gpio_function"
