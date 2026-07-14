#!/usr/bin/env bash
set -euo pipefail

: "${DEBIAN_SYSROOT:?DEBIAN_SYSROOT must be set}"
: "${DEBIAN_CROSS_GCC:?DEBIAN_CROSS_GCC must be set}"
: "${DEBIAN_CROSS_GXX:?DEBIAN_CROSS_GXX must be set}"
: "${DEBIAN_CROSS_VERSION:?DEBIAN_CROSS_VERSION must be set}"
: "${DEBIAN_TARGET_TRIPLET:?DEBIAN_TARGET_TRIPLET must be set}"
: "${DEBIAN_MULTIARCH:?DEBIAN_MULTIARCH must be set}"

case "$(basename -- "$0")" in
    *g++)
        compiler=$DEBIAN_CROSS_GXX
        ;;
    *)
        compiler=$DEBIAN_CROSS_GCC
        ;;
esac

gcc_library_directory="$DEBIAN_SYSROOT/usr/lib/gcc/$DEBIAN_TARGET_TRIPLET/$DEBIAN_CROSS_VERSION"
[[ -d $gcc_library_directory ]] || {
    echo "missing GCC $DEBIAN_CROSS_VERSION runtime in Debian sysroot: $gcc_library_directory" >&2
    exit 1
}

exec "$compiler" \
    -isystem "$DEBIAN_SYSROOT/usr/include/$DEBIAN_MULTIARCH" \
    -isystem "$DEBIAN_SYSROOT/usr/include" \
    -L"$gcc_library_directory" \
    -L"$DEBIAN_SYSROOT/usr/lib/$DEBIAN_MULTIARCH" \
    "$@"
