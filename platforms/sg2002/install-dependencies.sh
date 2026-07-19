#!/usr/bin/env bash
set -euo pipefail

install=false
binary=
while [[ $# -gt 0 ]]; do
    case $1 in
        --install) install=true ;;
        --binary)
            binary=${2:?--binary requires a path}
            shift
            ;;
        *)
            echo "usage: $0 [--install] [--binary <matter-sensor-linux-binary>]" >&2
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

packages=(avahi-daemon busybox libavahi-client3 libnss-mdns dbus libssl3t64 libglib2.0-0t64 libdbus-1-3 libstdc++6 libatomic1)
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

busybox --list | grep -qx devmem || {
    echo "the installed BusyBox does not provide the devmem applet" >&2
    exit 1
}

if [[ $install == true ]]; then
    systemctl enable --now avahi-daemon
fi
systemctl is-active --quiet avahi-daemon || {
    echo "avahi-daemon is not active; run this script with sudo --install" >&2
    exit 1
}

ip -6 addr show scope global | grep -q 'inet6 ' || {
    echo "no global IPv6 address is configured" >&2
    exit 1
}

[[ -r /dev/mem ]] || {
    echo "/dev/mem is not readable; the RTC information sensor backend requires it" >&2
    exit 1
}

if [[ -n $binary ]]; then
    [[ -x $binary ]] || {
        echo "binary is not executable: $binary" >&2
        exit 1
    }
    if ldd "$binary" | grep -q 'not found'; then
        ldd "$binary" >&2
        echo "binary has unresolved runtime libraries" >&2
        exit 1
    fi
fi

echo "SG2002 Matter RTC information backend prerequisites are satisfied"
