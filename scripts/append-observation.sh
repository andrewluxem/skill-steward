#!/usr/bin/env bash
# append-observation.sh — append-only, locked, verified write to the shared
# observation log. Implements the bounded-mutation discipline: acquire an
# exclusive lock, fresh-read to pick a non-colliding id, append, verify.
# It only ever appends. It never edits or deletes an existing entry.
#
# Usage: append-observation.sh <workspace-root> <skill> <signal> <text> [suggested]
#   signal: correction | gap | misfire | surprise
set -euo pipefail

ROOT="${1:?usage: append-observation.sh <workspace-root> <skill> <signal> <text> [suggested]}"
SKILL="${2:?missing <skill>}"
SIGNAL="${3:?missing <signal>}"
TEXT="${4:?missing <text>}"
SUGGEST="${5:-}"

case "$SIGNAL" in correction|gap|misfire|surprise) ;; *)
  echo "FAIL: signal must be correction|gap|misfire|surprise"; exit 2;; esac

DIR="$ROOT/skill-observations"
LOG="$DIR/log.md"
LOCK="$DIR/.log.lock"
mkdir -p "$DIR"

# Portable exclusive lock via atomic mkdir (works without flock, e.g. on macOS).
tries=0
until mkdir "$LOCK" 2>/dev/null; do
  tries=$((tries+1))
  [ "$tries" -gt 100 ] && { echo "FAIL: could not acquire lock $LOCK"; exit 3; }
  sleep 0.1
done
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

[ -f "$LOG" ] || : > "$LOG"

# Fresh read: highest existing id for today, then +1.
today="$(date +%Y%m%d)"
n="$(grep -Eo "^## OBS-${today}-[0-9]+" "$LOG" 2>/dev/null \
     | grep -Eo '[0-9]+$' | sort -n | tail -1 || true)"
n="$(( ${n:-0} + 1 ))"
id="OBS-${today}-${n}"

{
  printf '\n## %s\n' "$id"
  printf -- '- date: %s\n' "$(date +%Y-%m-%d)"
  printf -- '- skill: %s\n' "$SKILL"
  printf -- '- signal: %s\n' "$SIGNAL"
  printf -- '- what happened: %s\n' "$TEXT"
  [ -n "$SUGGEST" ] && printf -- '- suggested direction: %s\n' "$SUGGEST"
  printf -- '- status: open\n'
} >> "$LOG"

# Verify: our id is present exactly once.
if [ "$(grep -c "^## ${id}\$" "$LOG")" -eq 1 ]; then
  echo "OK: appended ${id} to ${LOG}"
else
  echo "FAIL: verification failed for ${id}"; exit 4
fi
