#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <existing-riscv64-development-sysroot>" >&2
    exit 2
fi

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
chip_root="$project_root/third_party/connectedhomeip"
patch="$project_root/patches/connectedhomeip/0001-add-linux-riscv64-gcc-toolchain.patch"

git -C "$chip_root" apply --check "$patch"
"$project_root/scripts/build-debian.sh" riscv64 "$1"
git -C "$chip_root" apply --check "$patch"
