#!/usr/bin/env bash
set -euo pipefail

install=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --install) install=true ;;
        *)
            echo "usage: $0 [--install]" >&2
            exit 2
            ;;
    esac
    shift
done

[[ $(dpkg --print-architecture) == riscv64 ]] || {
    echo "this script must run on a riscv64 Debian target" >&2
    exit 1
}
. /etc/os-release
[[ ${VERSION_CODENAME:-} == trixie ]] || {
    echo "this script expects Debian 13 (trixie), found ${PRETTY_NAME:-unknown}" >&2
    exit 1
}

packages=(busybox)
missing=()
for package in "${packages[@]}"; do
    dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null | grep -qx installed || missing+=("$package")
done

if ((${#missing[@]} > 0)); then
    printf 'Missing runtime packages: %s\n' "${missing[*]}" >&2
    if [[ $install != true ]]; then
        printf 'Install them on this board with: sudo %q --install\n' "$0" >&2
        exit 1
    fi
    apt-get update
    apt-get install -y "${missing[@]}"
fi

busybox_applets=$(busybox --list)
grep -qx devmem <<<"$busybox_applets" || {
    echo "the installed BusyBox does not provide the devmem applet" >&2
    exit 1
}

[[ -r /dev/mem ]] || {
    echo "/dev/mem is not readable; the RTC information sensor backend requires it" >&2
    exit 1
}

echo "SG2002 platform prerequisites are satisfied"
