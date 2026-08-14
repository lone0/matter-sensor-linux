#!/usr/bin/env bash
# Deploys the generic Matter program to a target over SSH.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
project_root=$(cd -- "$script_dir/.." && pwd)
target_ip=${1:-}
matter_binary=${2:-"$project_root/out/linux-riscv64/matter-temperature-humidity-sensor"}

if (($# < 1 || $# > 2)); then
    echo "usage: $0 <target-ip> [matter-sensor-binary]" >&2
    exit 2
fi
if ! [[ $target_ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
    echo "target must be an IPv4 address: $target_ip" >&2
    exit 2
fi
if [[ ! -x $matter_binary ]]; then
    echo "Matter binary is not executable: $matter_binary" >&2
    exit 2
fi
for command in scp ssh; do
    command -v "$command" >/dev/null || {
        echo "missing required host command: $command" >&2
        exit 2
    }
done

target="root@$target_ip"
remote_stage=$(ssh "$target" 'set -eu; mktemp -d /tmp/matter-sensor-main.XXXXXX')
case $remote_stage in
    /tmp/matter-sensor-main.*) ;;
    *)
        echo "target returned an unsafe staging directory: $remote_stage" >&2
        exit 1
        ;;
esac
cleanup() {
    ssh "$target" "rm -rf -- '$remote_stage'" >/dev/null 2>&1 || true
}
trap cleanup EXIT

scp \
    "$matter_binary" \
    "$script_dir/matter-temperature-humidity-sensor.service" \
    "$project_root/runtime-config/sensor.conf.example" \
    "$target:$remote_stage/"

ssh "$target" "bash -s -- '$remote_stage'" <<'REMOTE'
set -euo pipefail
stage=$1
service=matter-temperature-humidity-sensor.service
legacy_kvs=/tmp/chip_kvs
persistent_kvs=/var/lib/matter-temperature-humidity-sensor/chip-kvs
packages=(avahi-daemon libavahi-client3 libnss-mdns dbus libssl3t64 libglib2.0-0t64 libdbus-1-3 libstdc++6 libatomic1)
missing=()

for package in "${packages[@]}"; do
    dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null | grep -qx installed || missing+=("$package")
done
if ((${#missing[@]} > 0)); then
    apt-get update
    apt-get install -y "${missing[@]}"
fi

id -u matter-sensor >/dev/null 2>&1 ||
    useradd --system --home /var/lib/matter-temperature-humidity-sensor \
        --shell /usr/sbin/nologin matter-sensor
systemctl stop "$service" 2>/dev/null || true
if [[ -e $legacy_kvs && ! -e $persistent_kvs ]]; then
    install -D -m 0600 "$legacy_kvs" "$persistent_kvs"
    chown matter-sensor:matter-sensor "$persistent_kvs"
fi
install -D -m 0755 "$stage/matter-temperature-humidity-sensor" \
    /usr/local/bin/matter-temperature-humidity-sensor
install -D -m 0644 "$stage/matter-temperature-humidity-sensor.service" \
    "/etc/systemd/system/$service"
if [[ ! -e /etc/matter-temperature-humidity-sensor.conf ]]; then
    install -m 0644 "$stage/sensor.conf.example" \
        /etc/matter-temperature-humidity-sensor.conf
fi
systemctl enable --now avahi-daemon
systemctl is-active --quiet avahi-daemon
if ldd /usr/local/bin/matter-temperature-humidity-sensor | grep -q 'not found'; then
    ldd /usr/local/bin/matter-temperature-humidity-sensor >&2
    exit 1
fi
systemctl daemon-reload
systemctl enable "$service"
REMOTE

trap - EXIT
cleanup
echo "Installed the main Matter program on $target_ip"
