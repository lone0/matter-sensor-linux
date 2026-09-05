#!/usr/bin/env sh

if [ -n "${SENSOR_STUB_LOG:-}" ]; then
    printf '%s sensor read\n' "$(date -Is)" >> "$SENSOR_STUB_LOG"
fi

printf '%s\n' '{"temperature_c":23.45,"humidity_percent":56.78,"sequence":1}'
