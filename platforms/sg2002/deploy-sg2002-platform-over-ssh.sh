#!/usr/bin/env bash
# Deploys the SG2002 platform payload to a target over SSH.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
target_ip=${1:-}

if (($# != 1)); then
    echo "usage: $0 <debian-13-target-ip>" >&2
    exit 2
fi
if ! [[ $target_ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
    echo "target must be an IPv4 address: $target_ip" >&2
    exit 2
fi
for command in make scp ssh; do
    command -v "$command" >/dev/null || {
        echo "missing required host command: $command" >&2
        exit 2
    }
done

make -C "$script_dir/8051" all benchmark loader

target="root@$target_ip"
remote_stage=$(ssh "$target" 'set -eu
    . /etc/os-release
    [ "${VERSION_CODENAME:-}" = trixie ]
    [ "$(dpkg --print-architecture)" = riscv64 ]
    mktemp -d /tmp/matter-sensor-sg2002.XXXXXX')
case $remote_stage in
    /tmp/matter-sensor-sg2002.*) ;;
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
    "$script_dir/install-dependencies.sh" \
    "$script_dir/read-rtc-info.sh" \
    "$script_dir/probe-rtc-info.sh" \
    "$script_dir/check-sht31-readings.sh" \
    "$script_dir/test-sht31-hardware.sh" \
    "$script_dir/sensor.conf.example" \
    "$script_dir/matter-temperature-humidity-sensor-sg2002.conf" \
    "$script_dir/8051/prepare-gpios.sh" \
    "$script_dir/8051/prepare-i2c3.sh" \
    "$script_dir/8051/build/8051_up" \
    "$script_dir/8051/build/mars_mcu_fw_fake.bin" \
    "$script_dir/8051/build/mars_mcu_fw_sht31.bin" \
    "$script_dir/8051/build/robot_read_benchmark.bin" \
    "$target:$remote_stage/"

ssh "$target" "bash -s -- '$remote_stage'" <<'REMOTE'
set -euo pipefail
stage=$1
service=matter-temperature-humidity-sensor.service
libexec=/usr/local/libexec/matter-sensor-sg2002
firmware_dir=/usr/local/lib/matter-sensor-sg2002

[[ -x /usr/local/bin/matter-temperature-humidity-sensor ]] || {
    echo "install the main Matter program before the SG2002 platform." >&2
    exit 1
}
[[ -e /etc/systemd/system/$service ]] || {
    echo "install the main Matter service before the SG2002 platform." >&2
    exit 1
}

systemctl stop "$service" 2>/dev/null || true
install -D -m 0755 "$stage/read-rtc-info.sh" "$libexec/read-rtc-info.sh"
install -m 0755 "$stage/probe-rtc-info.sh" "$libexec/probe-rtc-info.sh"
install -m 0755 "$stage/check-sht31-readings.sh" "$libexec/check-sht31-readings.sh"
install -m 0755 "$stage/test-sht31-hardware.sh" "$libexec/test-sht31-hardware.sh"
install -m 0755 "$stage/prepare-gpios.sh" "$libexec/prepare-gpios.sh"
install -m 0755 "$stage/prepare-i2c3.sh" "$libexec/prepare-i2c3.sh"
install -m 0755 "$stage/8051_up" "$libexec/8051_up"
install -D -m 0644 "$stage/mars_mcu_fw_fake.bin" "$firmware_dir/mars_mcu_fw_fake.bin"
install -m 0644 "$stage/mars_mcu_fw_sht31.bin" "$firmware_dir/mars_mcu_fw_sht31.bin"
install -m 0644 "$stage/robot_read_benchmark.bin" "$firmware_dir/robot_read_benchmark.bin"
install -D -m 0644 "$stage/sensor.conf.example" /etc/matter-temperature-humidity-sensor.conf
install -D -m 0644 "$stage/matter-temperature-humidity-sensor-sg2002.conf" \
    /etc/systemd/system/"$service".d/sg2002.conf
"$stage/install-dependencies.sh" --install
systemctl daemon-reload
systemctl enable --now "$service"
REMOTE

trap - EXIT
cleanup
echo "Installed and started the SG2002 SHT31 platform on $target_ip"
