#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
overlay_directory="$project_root/third_party/connectedhomeip/examples/matter-temperature-humidity-sensor"

mkdir -p "$overlay_directory"
cp "$project_root/build-support/chip-example.BUILD.gn" "$overlay_directory/BUILD.gn"
