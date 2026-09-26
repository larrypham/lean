#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<'EOF'
Usage: scripts/release_dmg.sh

Creates arm64 and x86_64 release DMGs. The same environment variables as
build_dmg.sh apply. Set VERSION and BUILD_NUMBER to override project values.
EOF
    exit 0
fi

"$SCRIPT_DIR/build_dmg.sh" arm64
"$SCRIPT_DIR/build_dmg.sh" x86_64

echo "Release DMGs are ready in ${OUTPUT_DIR:-$SCRIPT_DIR/../dist}."
