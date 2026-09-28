#!/usr/bin/env bash
# dotagents uninstall: ownership-based removal with backup/restore.
set -euo pipefail
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$KIT_DIR/scripts/dotagents_lifecycle.py" uninstall "$@"
