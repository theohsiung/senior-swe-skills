#!/usr/bin/env bash
# Check a master plan against the plan contract in docs/skill-contracts.md §5
# (header fields, stable increasing T-NNN IDs, withdrawn form, the six task
# sub-blocks with a valid Level, no test code in the plan).
#
# Usage (path is relative to the write-plan skill folder):
#   scripts/check-plan.sh <plan.md> [--slices <slice> [<slice> ...]]
#
# A <slice> is one issue's "covers" list: "T-004..T-008", "T-004, T-006", or
# a mix ("T-001..T-003, T-007"). With --slices, every live task must be
# covered by exactly one slice (no orphans, no double-counts).
#
# Prints one "<file>:<line>: <problem>" per violation and exits 1, or prints
# "OK: ..." and exits 0. Exits 2 on usage errors.
#
# Why a script and not "just re-read the rules in each skill": prose rules
# drift between write-plan, to-issues and where-am-i; a check doesn't.

set -euo pipefail

usage() {
  echo "Usage: scripts/check-plan.sh <plan.md> [--slices <slice> ...]" >&2
  exit 2
}

[ "$#" -ge 1 ] || usage
PLAN="$1"
shift
[ -f "$PLAN" ] || { echo "check-plan: no such file: $PLAN" >&2; exit 2; }

SLICES=""
HAVE_SLICES=0
if [ "$#" -gt 0 ]; then
  [ "$1" = "--slices" ] || usage
  shift
  [ "$#" -gt 0 ] || usage
  HAVE_SLICES=1
  for s in "$@"; do
    SLICES="${SLICES}${s}|"
  done
fi

awk -v file="$PLAN" -v slices="$SLICES" -v have_slices="$HAVE_SLICES" '
function problem(line, msg) {
  printf "%s:%d: %s\n", file, line, msg
  problems++
}

function slice_problem(msg) {
  printf "%s: slices: %s\n", file, msg
  problems++
}

function idnum(id) {
  sub(/^T-/, "", id)
  return id + 0
}

function fmt(n) {
  return sprintf("T-%03d", n)
}

function finish_task(   i, b) {
  if (cur == "") return
  for (i = 1; i <= nblocks; i++) {
    b = blocks[i]
    if (!(cur SUBSEP b in seen_block)) problem(cur_line, cur " missing " b)
  }
  if (!has_level) {
    problem(cur_line, cur " missing \"- Level:\" line under **Public interface this task introduces**")
  }
  cur = ""
}

function register(id, line, live,   n) {
  if (id in ids) {
    problem(line, "duplicate task id " id)
    return
  }
  ids[id] = line
  n = idnum(id)
  if (last_num > 0 && n <= last_num) {
    problem(line, id " is not greater than " fmt(last_num) " (IDs must increase in creation order)")
  }
  if (n > last_num) last_num = n
  if (live) {
    live_ids[id] = line
    nlive++
  } else {
    nwithdrawn++
  }
}

BEGIN {
  nblocks = split("**Behavior to verify**|**Public interface this task introduces**|**Files**|**Test framing hints|**Anti-patterns to refuse**|**Definition of done**", blocks, "|")
  in_header = 1
  cur = ""
  in_fence = 0
  last_num = 0
}

/^[ \t]*(```|~~~)/ {
  in_fence = !in_fence
  fence_flagged = 0
  next
}

in_fence {
  if (cur != "" && !fence_flagged && ($0 ~ /(^|[^A-Za-z_])(it|test|describe|expect)\(/ || $0 ~ /def test_|@Test|func Test|(^|[^A-Za-z_.])assert($|[ (.A-Z_])/)) {
    problem(NR, cur " contains a fenced block that looks like test code; plans describe behavior, /tdd writes the test")
    fence_flagged = 1
  }
  next
}

# Only task headings delimit tasks; any other "### " heading (in the header
# or inside a task) is ordinary content.
/^### (~~)?T-/ {
  if (in_header) {
    in_header = 0
    if (!has_goal) problem(1, "header missing **Goal:**")
    if (!has_design) problem(1, "header missing **Design doc:**")
    if (!has_ids) problem(1, "header missing **Task IDs:**")
  }
  finish_task()
  heading = substr($0, 5)
  if (heading ~ /^~~T-[0-9][0-9][0-9]+~~ Withdrawn/) {
    id = heading
    sub(/^~~/, "", id)
    sub(/~~.*/, "", id)
    register(id, NR, 0)
  } else if (heading ~ /^~~/) {
    problem(NR, "withdrawn task must read \"### ~~T-NNN~~ Withdrawn\"")
    id = heading
    sub(/^~~/, "", id)
    sub(/[^-0-9T].*/, "", id)
    if (id ~ /^T-[0-9]+$/) register(id, NR, 0)
  } else if (heading ~ /^T-[0-9][0-9][0-9]+:/) {
    id = heading
    sub(/:.*/, "", id)
    register(id, NR, 1)
    cur = id
    cur_line = NR
    has_level = 0
  } else if (heading ~ /^T-/) {
    problem(NR, "task heading must read \"### T-NNN: <behavior>\" (3+ digit ID)")
  }
  next
}

in_header {
  if (index($0, "**Goal:**")) has_goal = 1
  if (index($0, "**Design doc:**")) has_design = 1
  if (index($0, "**Task IDs:**")) has_ids = 1
  next
}

cur != "" {
  for (i = 1; i <= nblocks; i++) {
    if (index($0, blocks[i]) == 1) seen_block[cur, blocks[i]] = 1
  }
  if ($0 ~ /^[-*] Level:/) {
    has_level = 1
    sys = index($0, "system-public")
    mod = index($0, "module-public")
    if (!sys && !mod) {
      problem(NR, cur " Level must be system-public or module-public")
    } else if (sys && mod) {
      problem(NR, cur " Level must pick one of system-public or module-public, not both")
    }
  }
}

END {
  if (in_header) {
    problem(1, "no tasks found (expected \"### T-NNN: <behavior>\" headings)")
  }
  finish_task()

  if (have_slices == 1) {
    ns = split(slices, slice_list, "|")
    for (s = 1; s <= ns; s++) {
      if (slice_list[s] == "") continue
      label = "slice " s " (\"" slice_list[s] "\")"
      delete in_this
      ni = split(slice_list[s], items, ",")
      for (k = 1; k <= ni; k++) {
        item = items[k]
        gsub(/[ \t]/, "", item)
        if (item == "") continue
        if (item ~ /^T-[0-9]+\.\.T-[0-9]+$/) {
          lo = item; sub(/\.\..*/, "", lo)
          hi = item; sub(/.*\.\./, "", hi)
          if (idnum(lo) > idnum(hi)) {
            slice_problem(label ": range runs backwards (" item "); write it low..high")
            continue
          }
          if (!(lo in live_ids)) slice_problem(label ": slice references " lo ", which is not a live task")
          if (!(hi in live_ids)) slice_problem(label ": slice references " hi ", which is not a live task")
          for (n = idnum(lo); n <= idnum(hi); n++) {
            if (fmt(n) in live_ids) in_this[fmt(n)] = 1
          }
        } else if (item ~ /^T-[0-9]+$/) {
          if (item in live_ids) in_this[item] = 1
          else slice_problem(label ": slice references " item ", which is not a live task")
        } else {
          slice_problem(label ": cannot parse \"" item "\" (use T-NNN or T-NNN..T-NNN)")
        }
      }
      for (id in in_this) covered[id]++
    }
    for (id in live_ids) {
      if (!(id in covered)) problem(live_ids[id], id " is not covered by any slice")
      else if (covered[id] > 1) problem(live_ids[id], id " is covered by " covered[id] " slices")
    }
  }

  if (problems > 0) {
    printf "%d problem(s) in %s\n", problems, file
    exit 1
  }
  printf "OK: %s — %d live task(s), %d withdrawn\n", file, nlive, nwithdrawn
}
' "$PLAN"
