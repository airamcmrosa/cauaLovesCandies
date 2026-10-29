#!/usr/bin/env bash
# Fails when line coverage in an lcov file is below a minimum.
# Usage: check-coverage.sh [lcov-file] [min-percent]
set -euo pipefail

lcov="${1:-coverage/lcov.info}"
min="${2:-90}"

if [[ ! -s "$lcov" ]]; then
  echo "coverage file missing or empty: $lcov" >&2
  exit 2
fi

awk -F: -v min="$min" '
  /^LF:/ { lf += $2 }
  /^LH:/ { lh += $2 }
  END {
    if (lf == 0) { print "no instrumented lines found" > "/dev/stderr"; exit 2 }
    pct = 100 * lh / lf
    printf "Line coverage: %.2f%% (%d/%d), minimum %s%%\n", pct, lh, lf, min
    exit (pct + 0 >= min + 0) ? 0 : 1
  }
' "$lcov"
