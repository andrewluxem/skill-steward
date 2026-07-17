# skill-steward

A hand-operated companion for keeping a Claude skill library healthy — without
ever letting an agent change your library on its own.

You invoke it. It proposes. You decide. It does four small jobs and refuses to
do anything unattended.

## The four jobs

- **Capture** — when you ask, it reviews the session you just had and logs what
  the work revealed about the skills you used (a correction, a gap, a misfire).
  Notes only, never edits.
- **Propose** — it turns a note into a *staged* change: a full proposed file
  under `skill-updates/` plus a rationale. You read the diff and promote it by
  hand.
- **Check** — before a skill ships, it verifies the bundle is complete:
  frontmatter parses, referenced files exist, nothing is empty or truncated.
- **Sweep** — before a skill is published, it scans for secrets, tokens,
  personal paths, and PII, and reports what it finds.

## Why it's built this way

It's the deliberately-defanged counterpart to autonomous "self-improving
observer" skills. Those are powerful and, at library scale, risky: an
always-loaded meta-skill that runs on a schedule and can apply changes across
every skill you own is a single point of failure for your whole toolchain. The
failure mode isn't malice — it's an unattended edit you didn't want, propagating
into every future session.

skill-steward keeps the genuinely useful patterns and drops the reach:

| Kept                                   | Dropped                                  |
|----------------------------------------|------------------------------------------|
| Full-file staging to `skill-updates/`  | Editing live skill files                 |
| Pre-delivery bundle completeness check | "Small changes may be applied directly"  |
| Fresh-read, locked, append-only log    | Scheduled / unattended review runs       |
| Confidentiality sweep before publish   | Auto-load via CLAUDE.md / SessionStart   |
| Human promotes every change            | Auto-deletion / "keep only last N"       |
| Local files are the only authority     | Fetching external URLs as instructions   |

If a request would cross one of those lines, the skill stops and says so instead
of routing around it.

## Install

It's a standard skill bundle: `SKILL.md` plus `references/` and `scripts/`.

- **Claude (web / desktop / mobile / Cowork):** put the folder's contents into
  one folder, zip it, upload via Settings → Capabilities.
- **Claude Code:** place the folder at `.claude/skills/skill-steward/`
  (project-level) or in your user-level skills directory, keeping `references/`
  and `scripts/` intact.

Do **not** wire it into `CLAUDE.md` or a session-start hook. Invoking it
explicitly is the design, not a limitation.

## Scripts

Both are optional conveniences; the workflow works by hand without them.

- `scripts/check-bundle.sh <bundle-dir>` — read-only bundle check. Exits
  non-zero on any problem, so you can drop it into a pre-publish step.
- `scripts/append-observation.sh <workspace-root> <skill> <signal> <text> [suggested]`
  — append-only, locked, verified write to the observation log. Only ever
  appends; never edits or deletes an entry.

## Workspace

You name one absolute workspace root the first time you use it. Everything lands
there and nothing is ever pruned automatically:

```
<workspace-root>/
  skill-observations/    # append-only notes
  skill-updates/         # staged proposals you promote by hand
```

## Credits

The four patterns here were distilled from ideas in Eoghan Henn's
[task-observer](https://github.com/rebelytics/one-skill-to-rule-them-all)
(CC BY 4.0) — specifically its full-bundle staging discipline, pre-delivery
bundle check, bounded-mutation log writes, and pre-publish confidentiality
sweep. skill-steward keeps those and intentionally omits the autonomous
apparatus. See `NOTICE`.

## License

CC BY 4.0. See `LICENSE.txt`. Reuse and adapt freely, including commercially,
with attribution.
