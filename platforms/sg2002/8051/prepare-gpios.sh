#!/usr/bin/env bash
set -euo pipefail

dht_line=${DHT_LINE:-GPIOA26}
led_line=${LED_LINE:-GPIOP20}
dht_chip=${DHT_CHIP:-gpiochip0}
dht_offset=${DHT_OFFSET:-26}
led_pinmux_register=0x030010d8
led_gpio_function=3
configure_led_mux=0

if (($# > 1)) || { (($# == 1)) && [[ $1 != --configure-led-gpio ]]; }; then
    echo "usage: $0 [--configure-led-gpio]" >&2
    exit 2
fi
if (($# == 1)); then
    configure_led_mux=1
fi

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "run as root so libgpiod can request the GPIO lines" >&2
    exit 2
fi

for command in gpioset gpioinfo; do
    command -v "$command" >/dev/null || {
        echo "missing $command; install the gpiod package" >&2
        exit 2
    }
done

if ! busybox --list 2>/dev/null | grep -qx devmem; then
    echo "BusyBox devmem is required to verify the LED pinmux" >&2
    exit 2
fi

find_line() {
    local line=$1
    local chip=$2
    local offset=$3

    if [[ -n $chip || -n $offset ]]; then
        if [[ -z $chip || -z $offset || ! $offset =~ ^[0-9]+$ ]]; then
            echo "set both chip and numeric offset for $line" >&2
            return 2
        fi
        printf '%s %s\n' "$chip" "$offset"
        return
    fi

    gpioinfo | awk -v requested="$line" '
        /^gpiochip[0-9]+/ {
            chip = $1
            sub(/:$/, "", chip)
        }
        /^[[:space:]]*line[[:space:]]+[0-9]+:/ {
            if (match($0, /"[^"]+"/)) {
                name = substr($0, RSTART + 1, RLENGTH - 2)
                if (name == requested) {
                    line_number = $2
                    sub(/:$/, "", line_number)
                    print chip, line_number
                    exit
                }
            }
        }'
}

gpioinfo_chip() {
    if gpioinfo --help 2>&1 | grep -q -- '--chip'; then
        gpioinfo --chip "$1"
    else
        gpioinfo "$1"
    fi
}

select_gpio_function() {
    local chip=$1
    local offset=$2

    if gpioset --help 2>&1 | grep -q -- '--chip'; then
        gpioset --chip "$chip" --toggle 0 "$offset=0"
    else
        gpioset --mode=exit "$chip" "$offset=0"
    fi
}

check_line() {
    local role=$1
    local line=$2
    local chip=$3
    local offset=$4
    local location
    local info

    location=$(find_line "$line" "$chip" "$offset") || return
    if [[ -z $location ]]; then
        echo "$line is not exported by this kernel; set ${role}_CHIP and ${role}_OFFSET after inspecting gpioinfo" >&2
        return 1
    fi
    read -r chip offset <<<"$location"
    info=$(gpioinfo_chip "$chip" | awk -v wanted="$offset" '
        $1 == "line" && ($2 + 0) == wanted {
            print
            exit
        }')
    if [[ -z $info ]]; then
        echo "$chip does not contain GPIO line $offset for $line" >&2
        return 1
    fi
    if grep -Eqi 'consumer=.*(mmc|emmc|sdio)' <<<"$info"; then
        echo "$line is in use and cannot be repurposed:" >&2
        echo "$info" >&2
        exit 1
    fi
    if [[ $role == DHT ]] && grep -Eq 'consumer=' <<<"$info"; then
        echo "$line is in use and cannot be used for DHT11:" >&2
        echo "$info" >&2
        return 1
    fi
    if [[ $role == LED ]] && grep -Eq 'consumer=' <<<"$info"; then
        echo "$line is in use and cannot be used for the external LED:" >&2
        echo "$info" >&2
        return 1
    fi
    printf '%s: %s\n' "$line" "$info"
    printf -v "${role}_LOCATION" '%s' "$location"
}

check_line DHT "$dht_line" "$dht_chip" "$dht_offset"

pinmux_value=$(busybox devmem "$led_pinmux_register" 32)
pinmux_function=$((pinmux_value & 0x7))
printf 'GPIOP20 pinmux: register=%s value=%s selector=%d\n' \
    "$led_pinmux_register" "$pinmux_value" "$pinmux_function"
if ((pinmux_function != led_gpio_function)); then
    if ((configure_led_mux == 0)); then
        echo "GPIOP20 is not muxed as RTC GPIO (expected selector 3); rerun with --configure-led-gpio only after confirming SPI-NOR is unused." >&2
        exit 1
    fi
    if grep -q '^mtd[0-9]' /proc/mtd || find /sys/bus/spi/devices -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
        echo "MTD or SPI devices are present; refusing to repurpose the SPI-NOR write-protect pad." >&2
        exit 1
    fi
    pinmux_value=$(( (pinmux_value & ~0x7) | led_gpio_function ))
    busybox devmem "$led_pinmux_register" 32 "$pinmux_value"
    pinmux_value=$(busybox devmem "$led_pinmux_register" 32)
    if (( (pinmux_value & 0x7) != led_gpio_function )); then
        echo "failed to select GPIOP20 pinmux" >&2
        exit 1
    fi
fi

if compgen -G '/sys/kernel/debug/pinctrl/*/pinmux-pins' >/dev/null; then
    if grep -Eqi "${dht_line}|${led_line}" /sys/kernel/debug/pinctrl/*/pinmux-pins \
        | grep -Eqi '(mmc|emmc|sdio|adc|sar)'; then
        echo "a requested GPIO is muxed to storage or ADC; do not load the firmware" >&2
        exit 1
    fi
fi

read -r chip offset <<<"$DHT_LOCATION"
# A short request selects the kernel's GPIO pinctrl function without retaining
# ownership that would conflict with the 8051 firmware.
select_gpio_function "$chip" "$offset"

echo "GPIO preflight passed; GPIOP20 is muxed as RTC GPIO."
