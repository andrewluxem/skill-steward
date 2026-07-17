#!/usr/bin/env bash
# check-bundle.sh — read-only pre-delivery check for a Claude skill bundle.
# Verifies frontmatter, referenced-file existence, no empty files, balanced code
# fences. Reads only; never writes. Exits non-zero on any failure.
#
# Usage: check-bundle.sh <bundle-dir>
set -euo pipefail

DIR="${1:?usage: check-bundle.sh <bundle-dir>}"
[ -d "$DIR" ] || { echo "FAIL: not a directory: $DIR"; exit 2; }
SKILL="$DIR/SKILL.md"
[ -f "$SKILL" ] || { echo "FAIL: no SKILL.md in $DIR"; exit 2; }

fail=0
note() { echo "  - $1"; fail=1; }

echo "check-bundle: $DIR"

# 1. Frontmatter: file starts with '---', has a closing '---', name + description.
if [ "$(head -n1 "$SKILL")" != "---" ]; then
  note "SKILL.md does not start with a '---' frontmatter block"
else
  fm="$(awk 'NR>1{if($0=="---"){exit} print}' "$SKILL")"
  grep -Eq '^name:' <<<"$fm"        || note "frontmatter missing 'name:'"
  grep -Eq '^description:' <<<"$fm"  || note "frontmatter missing 'description:'"
fi

# 2. Referenced files exist. Collect references/... and scripts/... mentions
#    from every markdown file, resolve relative to the bundle root.
mapfile -t refs < <(grep -REoh '(references|scripts)/[A-Za-z0-9._/-]+' "$DIR" \
  --include='*.md' 2>/dev/null | sort -u || true)
for r in "${refs[@]:-}"; do
  [ -z "$r" ] && continue
  [ -e "$DIR/$r" ] || note "referenced but missing: $r"
done

# 3. No empty files anywhere in the bundle (excludes .git).
while IFS= read -r f; do
  note "empty file: ${f#"$DIR"/}"
done < <(find "$DIR" -type f -not -path '*/.git/*' -empty 2>/dev/null || true)

# 4. Balanced code fences in every markdown file (odd count = truncation).
while IFS= read -r f; do
  n="$(grep -c '^```' "$f" || true)"
  [ $((n % 2)) -eq 0 ] || note "unbalanced code fence (\`\`\`) in ${f#"$DIR"/}"
done < <(find "$DIR" -type f -name '*.md' -not -path '*/.git/*' 2>/dev/null || true)

if [ "$fail" -eq 0 ]; then
  echo "PASS"
else
  echo "FAIL"
fi
exit "$fail"
