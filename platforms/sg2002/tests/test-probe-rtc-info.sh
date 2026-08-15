#!/usr/bin/env bash
set -euo pipefail

platform_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
state_dir=$(mktemp -d)
trap 'rm -rf "$state_dir"' EXIT

chmod +x "$platform_root/probe-rtc-info.sh" "$platform_root/tests/fake-busybox.sh"

ready_probe=$(SG2002_PROBE_ALLOW_UNPRIVILEGED=1 \
    SG2002_DEVMEM="$platform_root/tests/fake-busybox.sh" \
    "$platform_root/probe-rtc-info.sh")
grep -Fqx 'Firmware: SHT31 measurement publisher (I2CO)' <<<"$ready_probe"
grep -Fqx 'Decoded reading: temperature=23.45 C humidity=56.78 %' <<<"$ready_probe"

error_probe=$(FAKE_RTC_STATUS=0x49324321 FAKE_RTC_DETAIL=0x00000001 SG2002_PROBE_ALLOW_UNPRIVILEGED=1 \
    SG2002_DEVMEM="$platform_root/tests/fake-busybox.sh" \
    "$platform_root/probe-rtc-info.sh")
grep -Fqx 'Firmware: SHT31 I2C transaction failure (I2C!), abort source=0x00000001' <<<"$error_probe"
