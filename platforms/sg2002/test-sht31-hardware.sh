#!/usr/bin/env bash
# Prepares I2C3, loads the SHT31 firmware, and checks the resulting publication.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
prepare_i2c="$script_dir/8051/prepare-i2c3.sh"
prepare_led="$script_dir/8051/prepare-gpios.sh"
loader="$script_dir/8051/8051_up"

if [[ ! -x $prepare_i2c ]]; then
    prepare_i2c="$script_dir/prepare-i2c3.sh"
    prepare_led="$script_dir/prepare-gpios.sh"
    loader="$script_dir/8051_up"
    default_firmware=/usr/local/lib/matter-sensor-sg2002/mars_mcu_fw_sht31.bin
else
    default_firmware="$script_dir/8051/build/mars_mcu_fw_sht31.bin"
fi
firmware=${1:-"$default_firmware"}

if (($# > 1)); then
    echo "usage: $0 [firmware-image]" >&2
    exit 2
fi
if [[ ! -r $firmware ]]; then
    echo "SHT31 firmware image is not readable: $firmware" >&2
    exit 2
fi

"$prepare_i2c" --configure
"$prepare_led" --configure-gpiop20
"$loader" "$firmware"
exec "$script_dir/check-sht31-readings.sh"
