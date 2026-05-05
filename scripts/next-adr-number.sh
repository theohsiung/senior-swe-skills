#!/usr/bin/env bash
# Allocate the next ADR number atomically.
#
# Usage:
#   scripts/next-adr-number.sh [adr_root]
#
# Default adr_root is docs/adr/ relative to the current working directory.
# Prints the next zero-padded number (e.g. "0007") to stdout.
#
# Why a script and not "just grep in each skill": parallel sessions would
# collide on the same number. This uses an mkdir-based lock so two concurrent
# allocations serialize.

set -euo pipefail

ADR_ROOT="${1:-docs/adr}"
mkdir -p "$ADR_ROOT"

LOCK_DIR="$ADR_ROOT/.next-adr.lock"
TRIES=0
while ! mkdir "$LOCK_DIR" 2>/dev/null; do
  TRIES=$((TRIES + 1))
  if [ "$TRIES" -gt 50 ]; then
    echo "next-adr-number: could not acquire lock at $LOCK_DIR after 50 tries" >&2
    exit 1
  fi
  sleep 0.1
done
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

# Find highest existing NNNN-*.md, default 0 if none.
HIGHEST=0
shopt -s nullglob
for f in "$ADR_ROOT"/[0-9][0-9][0-9][0-9]-*.md; do
  base="$(basename "$f")"
  num="${base%%-*}"
  # Strip leading zeros without invoking arithmetic on octal-looking strings.
  num_dec=$((10#$num))
  if [ "$num_dec" -gt "$HIGHEST" ]; then
    HIGHEST=$num_dec
  fi
done
shopt -u nullglob

NEXT=$((HIGHEST + 1))
printf "%04d\n" "$NEXT"
