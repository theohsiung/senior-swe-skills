#!/usr/bin/env bash
# Regression tests for scripts/check-plan.sh. Run from the repo root:
#   scripts/tests/check-plan/run.sh

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CHECK="$HERE/../../check-plan.sh"
FAILS=0

expect() {
  local name="$1" want_code="$2" want_text="$3"
  shift 3
  local out code
  out="$("$CHECK" "$@" 2>&1)"
  code=$?
  if [ "$code" -ne "$want_code" ]; then
    echo "FAIL [$name]: exit $code, want $want_code"; echo "$out" | sed 's/^/    /'
    FAILS=$((FAILS + 1)); return
  fi
  if [ -n "$want_text" ] && ! grep -qF -- "$want_text" <<<"$out"; then
    echo "FAIL [$name]: output lacks: $want_text"; echo "$out" | sed 's/^/    /'
    FAILS=$((FAILS + 1)); return
  fi
  echo "ok   [$name]"
}

GOOD="$HERE/good.md"
BAD="$HERE/bad.md"

expect "good plan passes"                0 "OK"                               "$GOOD"
expect "missing header fields"           1 "header missing **Design doc:**"   "$BAD"
expect "missing Task IDs header"         1 "header missing **Task IDs:**"     "$BAD"
expect "ids not increasing"              1 "T-001 is not greater than T-002"  "$BAD"
expect "duplicate id"                    1 "duplicate task id T-001"          "$BAD"
expect "invalid level"                   1 "Level must be system-public or module-public" "$BAD"
expect "test code in plan"               1 "looks like test code"             "$BAD"
expect "missing sub-block"               1 "missing **Public interface this task introduces**" "$BAD"
expect "bad withdrawn form"              1 "withdrawn task must read"         "$BAD"
expect "slices cover exactly once"       0 "OK"   "$GOOD" --slices "T-001" "T-003"
expect "slices with range syntax"        0 "OK"   "$GOOD" --slices "T-001..T-003"
expect "orphan task"                     1 "T-003 is not covered by any slice" "$GOOD" --slices "T-001"
expect "double-counted task"             1 "T-001 is covered by 2 slices"     "$GOOD" --slices "T-001" "T-001, T-003"
expect "slice names unknown id"          1 "slice references T-009, which is not a live task" "$GOOD" --slices "T-001, T-003, T-009"
expect "slice names withdrawn id"        1 "slice references T-002, which is not a live task" "$GOOD" --slices "T-001..T-003" "T-002"
expect "missing file"                    2 "no such file"                     "$HERE/nope.md"
expect "no args"                         2 "Usage"

if [ "$FAILS" -gt 0 ]; then
  echo "$FAILS check(s) failed"; exit 1
fi
echo "all checks passed"
