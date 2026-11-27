#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Dart workspace members + packages/* outside workspace (e.g. lint)
mapfile -t pkgs < <(
  {
    yq -r '.workspace[]' pubspec.yaml
    find packages -mindepth 1 -maxdepth 1 -type d \
      -exec test -f '{}/pubspec.yaml' \; -print
  } | awk 'NF' | sort -u
)

for d in "${pkgs[@]}"; do
  [ -d "$d/lib" ] && dart format "$d/lib"
  [ -d "$d/test" ] && dart format "$d/test"
done
