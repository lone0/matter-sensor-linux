#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
gcc_version=12
if [[ ${1:-} == "--profile" ]]; then
    [[ $# -ge 3 && $# -le 4 ]] || {
        echo "usage: $0 --profile <architecture-profile> <sysroot-directory> [suite]" >&2
        exit 2
    }
    profile_file="$project_root/build-profiles/$2.conf"
    [[ -r $profile_file ]] || {
        echo "unknown architecture profile: $2" >&2
        exit 1
    }
    # Profiles are project-maintained shell assignments, not user-provided input.
    source "$profile_file"
    architecture=$DEBIAN_ARCH
    gcc_version=$GCC_VERSION
    sysroot=$3
    suite=${4:-bookworm}
else
    [[ $# -ge 2 && $# -le 3 ]] || {
        echo "usage: $0 <architecture> <sysroot-directory> [suite]" >&2
        exit 2
    }
    architecture=$1
    sysroot=$2
    suite=${3:-bookworm}
fi

command -v mmdebstrap >/dev/null || {
    echo "Install mmdebstrap first (sudo apt install mmdebstrap)." >&2
    exit 1
}
keyring=/usr/share/keyrings/debian-archive-keyring.gpg
[[ -r $keyring ]] || {
    echo "Install debian-archive-keyring first." >&2
    exit 1
}
if [[ -e $sysroot ]]; then
    echo "sysroot directory must not exist: $sysroot" >&2
    exit 1
fi

mkdir -p "$(dirname -- "$sysroot")"
temporary_sysroot=$(mktemp -d "${sysroot}.tmp.XXXXXX")
trap 'rm -rf "$temporary_sysroot"' EXIT

mmdebstrap --mode=unshare --keyring="$keyring" --architectures="$architecture" --variant=essential \
    --include=libc6-dev,libstdc++-"$gcc_version"-dev,libssl-dev,libavahi-client-dev,libdbus-1-dev,libglib2.0-dev \
    "$suite" "$temporary_sysroot" http://deb.debian.org/debian

mv "$temporary_sysroot" "$sysroot"
trap - EXIT
