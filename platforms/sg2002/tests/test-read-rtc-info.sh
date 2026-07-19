#!/usr/bin/env bash
set -euo pipefail

platform_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
chmod +x "$platform_root/read-rtc-info.sh" "$platform_root/tests/fake-busybox.sh"

output=$(SG2002_DEVMEM="$platform_root/tests/fake-busybox.sh" "$platform_root/read-rtc-info.sh")
[[ $output == '{"temperature_c":23.45,"humidity_percent":56.78}' ]]
