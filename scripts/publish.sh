#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

package="${1:?package is required (annotations|lint)}"
shift || true

dry_run=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

case "$package" in
  annotations) dir="packages/annotations" ;;
  lint) dir="packages/lint" ;;
  *)
    echo "unknown package: $package (expected: annotations|lint)" >&2
    exit 1
    ;;
esac

if [ ! -f "$dir/pubspec.yaml" ]; then
  echo "pubspec.yaml not found: $dir" >&2
  exit 1
fi

if [ "$dry_run" = true ]; then
  dart pub -C "$dir" publish --dry-run
else
  dart pub -C "$dir" publish
fi
