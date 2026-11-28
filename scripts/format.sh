#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Usage: scripts/format.sh [--check]
#   --check  fail if formatting would change files (--set-exit-if-changed)
format_args=()
if [[ "${1:-}" == "--check" ]]; then
  format_args+=(--set-exit-if-changed)
fi

# Dart workspace members + packages/* outside workspace (e.g. lint)
mapfile -t pkgs < <(
  {
    yq -r '.workspace[]' pubspec.yaml
    find packages -mindepth 1 -maxdepth 1 -type d \
      -exec test -f '{}/pubspec.yaml' \; -print
  } | awk 'NF' | sort -u
)

for d in "${pkgs[@]}"; do
  [ -d "$d/lib" ] && dart format "${format_args[@]}" "$d/lib"
  [ -d "$d/test" ] && dart format "${format_args[@]}" "$d/test"
done
