#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "usage: $0 <architecture-profile> [sysroot-directory]" >&2
    exit 2
fi

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
profile=$1
profile_file="$project_root/configs/architectures/$profile.conf"
[[ -r $profile_file ]] || {
    echo "unknown architecture profile: $profile" >&2
    exit 1
}

# Profiles are project-maintained shell assignments, not user-provided input.
source "$profile_file"
sysroot=${2:-"$project_root/sysroot/debian12-$DEBIAN_ARCH"}
sysroot=$(realpath "$sysroot")
[[ -d $sysroot/usr/include ]] || {
    echo "not a usable Debian sysroot: $sysroot" >&2
    exit 1
}

cross_gcc=${CROSS_GCC:-"$GNU_TRIPLET-gcc-$GCC_VERSION"}
cross_gxx=${CROSS_GXX:-"$GNU_TRIPLET-g++-$GCC_VERSION"}
command -v "$cross_gcc" >/dev/null || {
    echo "install $GNU_TRIPLET-gcc-$GCC_VERSION or set CROSS_GCC" >&2
    exit 1
}
command -v "$cross_gxx" >/dev/null || {
    echo "install $GNU_TRIPLET-g++-$GCC_VERSION or set CROSS_GXX" >&2
    exit 1
}
command -v pkg-config >/dev/null || {
    echo "install pkg-config and CHIP's Linux development dependencies first" >&2
    exit 1
}
pkg-config --exists openssl avahi-client dbus-1 gio-2.0 || {
    echo "install libssl-dev, libavahi-client-dev, libdbus-1-dev, and libglib2.0-dev first" >&2
    exit 1
}
command -v gdbus-codegen >/dev/null || {
    echo "install libglib2.0-dev-bin first" >&2
    exit 1
}

cross_version=$("$cross_gcc" -dumpversion | cut -d. -f1)
[[ $cross_version == "$GCC_VERSION" ]] || {
    echo "$cross_gcc reports GCC $cross_version; profile $profile requires GCC $GCC_VERSION" >&2
    exit 1
}

cd "$project_root"
toolchain_wrapper_dir=$(mktemp -d)
trap 'rm -rf "$toolchain_wrapper_dir"' EXIT
export DEBIAN_SYSROOT="$sysroot"
export DEBIAN_CROSS_GCC="$(command -v "$cross_gcc")"
export DEBIAN_CROSS_GXX="$(command -v "$cross_gxx")"
export DEBIAN_CROSS_VERSION="$cross_version"
export DEBIAN_TARGET_TRIPLET="$GNU_TRIPLET"
export DEBIAN_MULTIARCH="$DEBIAN_MULTIARCH"
ln -s "$project_root/scripts/debian-sysroot-compiler-wrapper.sh" "$toolchain_wrapper_dir/$GNU_TRIPLET-gcc"
ln -s "$project_root/scripts/debian-sysroot-compiler-wrapper.sh" "$toolchain_wrapper_dir/$GNU_TRIPLET-g++"
PATH="$toolchain_wrapper_dir:$PATH"

# shellcheck source=/dev/null
set +u
source third_party/connectedhomeip/scripts/activate.sh
set -u
./scripts/generate-data-model.sh
./scripts/prepare-chip-overlay.sh

output_dir="out/debian12-$DEBIAN_ARCH"
gn gen "$output_dir" --args="import(\"//args.gni\") target_os=\"linux\" target_cpu=\"$GN_TARGET_CPU\" sysroot=\"$sysroot\" system_libdir=\"lib/$DEBIAN_MULTIARCH\" pkg_config=\"pkg-config\" is_debug=false"
ninja -C "$output_dir" matter-temperature-humidity-sensor

binary="$output_dir/matter-temperature-humidity-sensor"
file "$binary"
required_glibc=$(readelf --version-info "$binary" | grep -oE 'GLIBC_[0-9.]+' | sort -Vu | tail -n1 || true)
if [[ -n $required_glibc ]] && ! dpkg --compare-versions "${required_glibc#GLIBC_}" le 2.36; then
    echo "binary requires $required_glibc, newer than Debian 12's GLIBC_2.36" >&2
    exit 1
fi
printf 'maximum required glibc version: %s\n' "${required_glibc:-none}"
