# Check — the pre-delivery bundle check

Verify a skill bundle is complete and well-formed before it ships or is
uploaded. A truncated or dangling bundle is a common, silent failure.

## Trigger

"Check the `<skill>` bundle", or run it yourself as the last step before you
hand a skill back to the user or stage it for upload.

## What it verifies

1. **Frontmatter parses.** `SKILL.md` starts with a YAML frontmatter block with
   at least `name` and `description`.
2. **Referenced files exist.** Every file the `SKILL.md` (and each reference
   file) points at — `references/<x>.md`, `scripts/<y>.sh`, assets — actually
   exists in the bundle at the stated path.
3. **No danglers.** Every file in `references/` and `scripts/` is reachable from
   at least one document (nothing orphaned that should have been wired in, or was
   left behind from an old layout).
4. **Nothing truncated.** No file is zero bytes; no document ends mid-sentence or
   mid-code-fence (unbalanced ``` counts).
5. **Manifest matches, if present.** If the bundle declares a file manifest, the
   files on disk match it exactly — no missing, no extra.

## Output

A short report: `PASS` or a list of specific problems with file paths. Do not
"fix" anything as part of a check — report, and let Propose (or the user) make
changes. A check that silently repairs is a check you can't trust.

## Automation

`scripts/check-bundle.sh <bundle-dir>` performs items 1–4 as a read-only pass and
exits non-zero on any failure, so you can wire it into your own pre-publish step.
It reads; it never writes. Item 5 (manifest) is checked by hand unless your
bundles carry a manifest file.
