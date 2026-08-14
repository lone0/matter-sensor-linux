#!/usr/bin/env bash
set -euo pipefail

[[ $# == 3 && $1 == devmem && $3 == 32 ]] || exit 2

case $2 in
    0x0502601c) echo 0x4932434f ;;
    0x05026020) echo 0x00000000 ;;
    0x05026024) echo 0x162e0929 ;;
    0x05026028)
        count_file=$FAKE_SHT31_STATE/sequence-count
        count=0
        [[ ! -f $count_file ]] || count=$(<"$count_file")
        count=$((count + 1))
        printf '%s\n' "$count" >"$count_file"
        if ((count <= 3)); then
            echo 0x00000001
        else
            echo 0x00000002
        fi
        ;;
    *) exit 2 ;;
esac
