#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# workspace の packages/* → dart test
mapfile -t dart_pkgs < <(
  yq -r '.workspace[]' pubspec.yaml \
    | awk '/^packages\//' \
    | sort
)
for d in "${dart_pkgs[@]}"; do
  if compgen -G "$d/test/*_test.dart" > /dev/null; then
    (cd "$d" && dart test ./test/)
  fi
done

# workspace の example/* → flutter test
mapfile -t flutter_pkgs < <(
  yq -r '.workspace[]' pubspec.yaml \
    | awk '/^example\//' \
    | sort
)
for d in "${flutter_pkgs[@]}"; do
  if compgen -G "$d/test/*_test.dart" > /dev/null; then
    (cd "$d" && flutter test ./test/)
  fi
done

# packages/lint（workspace 外）
(cd packages/lint && dart test ./test/)
