#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

dart analyze --fatal-infos --fatal-warnings
dart analyze --fatal-infos --fatal-warnings packages/lint
