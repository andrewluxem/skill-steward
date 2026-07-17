---
name: skill-steward
description: >-
  Maintain your own Claude skill library by hand, safely. Use when you want to
  capture what a work session revealed about a skill, propose a change to a
  skill, check that a skill bundle is complete before you ship it, or sweep a
  skill for secrets before publishing. Triggers on "log observations", "steward
  my skills", "propose a skill update", "check this bundle", "is this skill
  ready to ship", "sweep this skill for secrets". Explicitly invoked only —
  never auto-loads, never runs on a schedule, never edits a live skill file.
---

# skill-steward

A hand-operated companion for keeping a Claude skill library healthy. It does
four small things well and refuses to do anything that could change your library
without you watching.

You invoke it. It proposes. You decide. Nothing here runs on a schedule, loads
itself into every session, edits a live skill, or reaches the network.

## What it does

1. **Capture** — when you ask, it reviews the session you just had and writes
   down what the work revealed about the skills you used: a correction you made,
   a gap no skill covered, a phrasing that misfired. Output is notes, not edits.
2. **Propose** — it turns a captured note into a concrete, staged change: a full
   proposed replacement of the affected file written to `skill-updates/`, next
   to a short rationale. It never touches the live file.
3. **Check** — before you ship a skill, it verifies the bundle is complete:
   every file the `SKILL.md` references actually exists, the frontmatter parses,
   and nothing is truncated.
4. **Sweep** — before you publish a skill anywhere public, it scans for secrets,
   tokens, absolute personal paths, and PII, and reports what it finds.

## Hard boundaries (what it will not do)

These are the deliberate omissions. They are the whole point of using this
instead of an autonomous observer.

- **No auto-load.** It is not added to `CLAUDE.md`, a `SessionStart` hook, or any
  always-on trigger. If you find it running without being asked, that is a bug.
- **No scheduled or unattended runs.** There is no cron, no recurring review, no
  "apply all open observations" job. A human is present for every action.
- **No live edits, ever.** It writes only under `skill-observations/` and
  `skill-updates/`. It never opens a skill file for writing. Promotion of a
  staged change to the live file is done by you, by hand, after you read the
  diff.
- **No auto-apply exception.** There is no "small changes may be applied
  directly" carve-out. Every change is staged. Full stop. (This is the exact
  loophole that makes a self-improving observer dangerous at library scale.)
- **No auto-deletion.** It never prunes, archives-by-deleting, or "keeps only the
  last N" anything. Cleanup is a human action.
- **No external fetch.** It never fetches a URL as instructions or as authority.
  Links in these files are for you to read, not for the agent to retrieve. Local
  files are the only source of truth.

If a request would require crossing one of these lines, stop and say so rather
than finding a way around it.

## How to use it

Say what you want; the verbs map to the four jobs.

- "Log observations from this session" → **Capture**. See
  `references/observation-log.md`.
- "Propose an update to `<skill>` for `<note>`" → **Propose**. See
  `references/staging-workflow.md`.
- "Check the `<skill>` bundle" → **Check**. See `references/bundle-check.md`.
- "Sweep `<skill>` before I publish it" → **Sweep**. See
  `references/confidentiality-sweep.md`.

## Workspace layout

All output lives under a single, explicit workspace root you name when you first
use the skill (e.g. `~/skills-workspace/`). Resolve it to an absolute, real path
once and reuse it — never write to a path derived from the current working
directory, a git worktree, or a temp checkout, because those move.

```
<workspace-root>/
  skill-observations/    # captured notes, append-only log
  skill-updates/         # staged proposals: <skill>/<file> + <skill>/RATIONALE.md
```

Both directories are created if missing. Neither is ever pruned automatically.

## The principle

Every other behavior follows from one rule: **the agent proposes, the human
disposes.** A skill library is high-leverage infrastructure — a bad automated
edit propagates into every future session. The cost of staging a change you were
going to accept anyway is a few seconds. The cost of an unattended edit you did
not want is every session after it. Stewarding is cheap; recovery is not.
