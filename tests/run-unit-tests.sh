#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
output_dir="$project_root/out/unit-tests"
mkdir -p "$output_dir"

chmod +x "$project_root/tests/fixtures/stub-sensor.sh"
g++ -std=c++17 -Wall -Wextra -Werror -pedantic -pthread \
    -I"$project_root/include" \
    "$project_root/src/SensorReading.cpp" \
    "$project_root/src/CommandJsonSensorProvider.cpp" \
    "$project_root/tests/SensorProviderTest.cpp" \
    -o "$output_dir/sensor-provider-test"
(cd "$project_root" && "$output_dir/sensor-provider-test")
