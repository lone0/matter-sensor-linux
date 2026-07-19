#!/usr/bin/env bash
set -euo pipefail

[[ $# == 3 && $1 == devmem && $3 == 32 ]] || exit 2
case $2 in
    0x05026024) echo 0x162e0929 ;;
    0x05026028) echo 0x00000001 ;;
    *) exit 2 ;;
esac
