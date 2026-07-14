#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
chip_root="$project_root/third_party/connectedhomeip"
temperature_zap="$chip_root/examples/temperature-measurement-app/temperature-measurement-common/temperature-measurement.zap"
air_quality_zap="$chip_root/examples/air-quality-sensor-app/air-quality-sensor-common/air-quality-sensor-app.zap"
output="$project_root/data-model/temperature-humidity.zap"
matter_output="$project_root/data-model/temperature-humidity.matter"

command -v jq >/dev/null || {
    echo "jq is required to generate the data model" >&2
    exit 1
}

mkdir -p "$(dirname -- "$output")"
temporary_output=$(mktemp "${output}.XXXXXX")
trap 'rm -f "$temporary_output"' EXIT

jq --slurpfile air_quality "$air_quality_zap" --arg zcl "$chip_root/src/app/zap-templates/zcl/zcl.json" '
  ($air_quality[0].endpointTypes[]
    | select(.name == "Anonymous Endpoint Type")
    | .clusters[]
    | select(.code == 1029)) as $humidity_cluster
  | .endpointTypes |= map(
      if .name == "MA-tempsensor"
      then .clusters += [$humidity_cluster]
      else .
      end
    )
  | .package |= map(
      if .type == "zcl-properties"
      then .pathRelativity = "absolute" | .path = $zcl
      else .
      end
    )
' "$temperature_zap" >"$temporary_output"

mv "$temporary_output" "$output"
trap - EXIT

python "$chip_root/scripts/tools/zap/generate.py" \
    --zcl "$chip_root/src/app/zap-templates/zcl/zcl.json" \
    --matter-file-name "$matter_output" "$output"
