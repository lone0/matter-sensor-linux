#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "usage: $0 <architecture-profile> [sysroot-directory]" >&2
    exit 2
fi

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
profile=$1
profile_file="$project_root/build-profiles/$profile.conf"
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
chip_root="$project_root/third_party/connectedhomeip"
chip_patch_applied=false

cleanup() {
    if [[ $chip_patch_applied == true ]]; then
        git -C "$chip_root" apply --reverse "$chip_patch"
    fi
    rm -rf "$toolchain_wrapper_dir"
}

if [[ $GN_TARGET_CPU == riscv64 ]]; then
    chip_patch="$project_root/patches/connectedhomeip/0001-add-linux-riscv64-gcc-toolchain.patch"
    [[ -r $chip_patch ]] || {
        echo "missing connectedhomeip riscv64 patch: $chip_patch" >&2
        exit 1
    }
    if git -C "$chip_root" apply --reverse --check "$chip_patch" 2>/dev/null; then
        :
    elif git -C "$chip_root" apply --check "$chip_patch"; then
        git -C "$chip_root" apply "$chip_patch"
        chip_patch_applied=true
    else
        echo "connectedhomeip riscv64 patch does not apply; rebase it for the current submodule revision" >&2
        exit 1
    fi
fi
trap cleanup EXIT

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

output_dir="out/${OUTPUT_DIR:-debian12-$DEBIAN_ARCH}"
gn gen "$output_dir" --args="import(\"//args.gni\") target_os=\"linux\" target_cpu=\"$GN_TARGET_CPU\" sysroot=\"$sysroot\" system_libdir=\"lib/$DEBIAN_MULTIARCH\" pkg_config=\"pkg-config\" is_debug=false"
ninja -C "$output_dir" matter-temperature-humidity-sensor

binary="$output_dir/matter-temperature-humidity-sensor"
file "$binary"
required_glibc=$(readelf --version-info "$binary" | grep -oE 'GLIBC_[0-9.]+' | sort -Vu | tail -n1 || true)
maximum_glibc_version=${GLIBC_MAX_VERSION:-2.36}
if [[ -n $required_glibc ]] && ! dpkg --compare-versions "${required_glibc#GLIBC_}" le "$maximum_glibc_version"; then
    echo "binary requires $required_glibc, newer than profile maximum GLIBC_$maximum_glibc_version" >&2
    exit 1
fi
printf 'maximum required glibc version: %s\n' "${required_glibc:-none}"
