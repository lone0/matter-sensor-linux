#!/usr/bin/env bash
set -euo pipefail

dht_line=${DHT_LINE:-GPIOA26}
led_line=${LED_LINE:-GPIOA13}

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "run as root so libgpiod can request the GPIO lines" >&2
    exit 2
fi

for command in gpiofind gpioset gpioinfo; do
    command -v "$command" >/dev/null || {
        echo "missing $command; install the gpiod package" >&2
        exit 2
    }
done

for line in "$dht_line" "$led_line"; do
    location=$(gpiofind "$line") || {
        echo "$line is not exported by this kernel; do not load the firmware" >&2
        exit 1
    }
    read -r chip offset <<<"$location"
    info=$(gpioinfo "$chip" "$offset")
    if grep -Eqi 'consumer=.*(mmc|emmc|sdio|kernel)' <<<"$info"; then
        echo "$line is in use and cannot be repurposed:" >&2
        echo "$info" >&2
        exit 1
    fi
    printf '%s: %s\n' "$line" "$info"
done

if compgen -G '/sys/kernel/debug/pinctrl/*/pinmux-pins' >/dev/null; then
    if grep -Eqi "${dht_line}|${led_line}" /sys/kernel/debug/pinctrl/*/pinmux-pins \
        | grep -Eqi '(mmc|emmc|sdio)'; then
        echo "a requested GPIO is muxed to storage; do not load the firmware" >&2
        exit 1
    fi
fi

for line in "$dht_line" "$led_line"; do
    read -r chip offset <<<"$(gpiofind "$line")"
    # A short request selects the kernel's GPIO pinctrl function without
    # retaining ownership that would conflict with the 8051 firmware.
    gpioset --mode=exit "$chip" "$offset=0"
done

echo "GPIO preflight passed; verify the pads remain muxed as GPIO before loading firmware."
