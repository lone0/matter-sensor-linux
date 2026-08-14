#!/usr/bin/env bash
set -euo pipefail

readonly i2c3_device=4030000.i2c
readonly i2c3_driver=/sys/bus/platform/drivers/i2c_designware
readonly i2c3_base=0x04030000
readonly i2c3_comp_type=0x44570140
readonly pinmux_scl=0x030010e0
readonly pinmux_sda=0x030010e4
readonly i2c3_pinmux_function=2
readonly clock_enable=0x0300200c
readonly clock_i2c_bit=7
readonly clock_apb_i2c3_bit=20
readonly reset_control=0x03003000
readonly reset_i2c3_bit=30

if (($# != 1)) || [[ $1 != --configure ]]; then
    echo "usage: $0 --configure" >&2
    exit 2
fi
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "run as root to dedicate I2C3 to the 8051" >&2
    exit 2
fi
busybox_applets=$(busybox --list 2>/dev/null)
if ! grep -qx devmem <<<"$busybox_applets"; then
    echo "BusyBox devmem is required to configure I2C3" >&2
    exit 2
fi
if [[ ! -d /sys/bus/platform/devices/$i2c3_device ]]; then
    echo "SG2002 I2C3 platform device is absent: $i2c3_device" >&2
    exit 1
fi
if [[ -L /sys/bus/platform/devices/$i2c3_device/driver ]]; then
    [[ $(readlink -f "/sys/bus/platform/devices/$i2c3_device/driver") == "$i2c3_driver" &&
       -e $i2c3_driver/unbind ]] || {
        echo "I2C3 is bound to an unexpected Linux driver; refusing to unbind it." >&2
        exit 1
    }
    printf '%s\n' "$i2c3_device" >"$i2c3_driver/unbind"
fi

for adapter in /sys/class/i2c-dev/i2c-*; do
    [[ -e $adapter ]] || continue
    if [[ $(readlink -f "$adapter/device") == *"$i2c3_device"* ]]; then
        echo "Linux still owns I2C3 through ${adapter##*/}; refusing to continue." >&2
        exit 1
    fi
done

if ! compgen -G '/sys/kernel/debug/pinctrl/*/pinmux-pins' >/dev/null; then
    echo "kernel pinctrl debug information is unavailable; cannot verify I2C3 release." >&2
    exit 2
fi
if grep -R -q "$i2c3_device" /sys/kernel/debug/pinctrl/*/pinmux-pins; then
    echo "Linux pinctrl still claims I2C3 pads; refusing to continue." >&2
    exit 1
fi

scl_mux=$(busybox devmem "$pinmux_scl" 32)
sda_mux=$(busybox devmem "$pinmux_sda" 32)
busybox devmem "$pinmux_scl" 32 "$(((scl_mux & ~0x7) | i2c3_pinmux_function))"
busybox devmem "$pinmux_sda" 32 "$(((sda_mux & ~0x7) | i2c3_pinmux_function))"

clocks=$(busybox devmem "$clock_enable" 32)
busybox devmem "$clock_enable" 32 \
    "$((clocks | (1 << clock_i2c_bit) | (1 << clock_apb_i2c3_bit)))"
reset=$(busybox devmem "$reset_control" 32)
busybox devmem "$reset_control" 32 "$((reset | (1 << reset_i2c3_bit)))"

actual_scl_mux=$(busybox devmem "$pinmux_scl" 32)
actual_sda_mux=$(busybox devmem "$pinmux_sda" 32)
actual_comp_type=$(busybox devmem "$((i2c3_base + 0xfc))" 32)
if (((actual_scl_mux & 0x7) != i2c3_pinmux_function ||
     (actual_sda_mux & 0x7) != i2c3_pinmux_function ||
     actual_comp_type != i2c3_comp_type)); then
    printf 'failed to prepare dedicated I2C3: SCL mux=%s SDA mux=%s COMP_TYPE=%s\n' \
        "$actual_scl_mux" "$actual_sda_mux" "$actual_comp_type" >&2
    exit 1
fi

printf 'I2C3 dedicated to 8051: GPIOP22=SCL mux=%s GPIOP23=SDA mux=%s COMP_TYPE=%s\n' \
    "$actual_scl_mux" "$actual_sda_mux" "$actual_comp_type"
