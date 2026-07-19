#!/usr/bin/env bash
set -euo pipefail

platform_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
output=$("$platform_root/read-fake-sensor.sh")
[[ $output == '{"temperature_c":23.45,"humidity_percent":56.78}' ]]
