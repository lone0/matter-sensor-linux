#!/usr/bin/env bash
set -euo pipefail

platform_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
state_dir=$(mktemp -d)
trap 'rm -rf "$state_dir"' EXIT

chmod +x "$platform_root/check-sht31-readings.sh" "$platform_root/read-rtc-info.sh" \
    "$platform_root/tests/fake-busybox-sht31.sh"

output=$(FAKE_SHT31_STATE="$state_dir" SHT31_VALIDATE_INTERVAL_SECONDS=0 \
    SG2002_DEVMEM="$platform_root/tests/fake-busybox-sht31.sh" \
    "$platform_root/check-sht31-readings.sh")
[[ $output == 'SHT31 status=I2CO sequence=1->2 {"temperature_c":23.45,"humidity_percent":56.78,"sequence":1}' ]]
