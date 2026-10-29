#!/usr/bin/env bash
# Deterministic green check for a `flutter test` log.
# Usage: check-green.sh <log-file>
# Exit 0 = GREEN, 1 = RED, 2 = usage/missing/empty log.
# Prints one JSON line on stdout.
set -u

log="${1:-}"
if [[ -z "$log" || ! -s "$log" ]]; then
  echo '{"status":"ERROR","reason":"log file missing or empty"}'
  exit 2
fi

# Strip ANSI escapes and carriage-return progress redraws.
clean="$(sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g' "$log" | tr '\r' '\n')"

# Last progress line looks like "00:07 +25: ..." or "00:07 +25 -2: ...".
last="$(printf '%s\n' "$clean" | grep -E '^[0-9:]+ \+[0-9]+' | tail -n 1)"
passed="$(printf '%s' "$last" | sed -nE 's/^[0-9:]+ \+([0-9]+).*/\1/p')"
failed="$(printf '%s' "$last" | sed -nE 's/^[0-9:]+ \+[0-9]+ .*-([0-9]+).*/\1/p')"
passed="${passed:-0}"
failed="${failed:-0}"

all_passed=0
printf '%s\n' "$clean" | grep -qE 'All tests passed!' && all_passed=1
some_failed=0
printf '%s\n' "$clean" | grep -qE 'Some tests failed\.|\[E\]|Failed to load|Error: Compilation failed' && some_failed=1

if [[ $all_passed -eq 1 && $some_failed -eq 0 && "$failed" -eq 0 && "$passed" -gt 0 ]]; then
  printf '{"status":"GREEN","passed":%s,"failed":0}\n' "$passed"
  exit 0
fi

printf '{"status":"RED","passed":%s,"failed":%s}\n' "$passed" "$failed"
exit 1
