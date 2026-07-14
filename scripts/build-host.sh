#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

command -v pkg-config >/dev/null || {
    echo "Install pkg-config and CHIP's Linux development dependencies first." >&2
    exit 1
}
pkg-config --exists openssl avahi-client dbus-1 gio-2.0 || {
    echo "Install libssl-dev, libavahi-client-dev, libdbus-1-dev, and libglib2.0-dev first." >&2
    exit 1
}
command -v gdbus-codegen >/dev/null || {
    echo "Install libglib2.0-dev-bin first." >&2
    exit 1
}

# shellcheck source=/dev/null
set +u
source third_party/connectedhomeip/scripts/activate.sh
set -u
./scripts/generate-data-model.sh
./scripts/prepare-chip-overlay.sh
gn gen out/host --args='import("//args.gni") target_os="linux" target_cpu="x64" is_debug=false'
ninja -C out/host matter-temperature-humidity-sensor
