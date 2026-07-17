# Propose — the staging workflow

Turn a note into a concrete change the user can read as a diff and promote by
hand. The live skill is never touched here.

## Trigger

Explicit only: "propose an update to `<skill>` for `<observation/note>`". If the
note came from the observation log, reference its `OBS-` id.

## Procedure

1. **Read the live skill, read-only.** Load the current `<skill>/SKILL.md` and
   any reference file the change touches. Understand it before you change it.
2. **Write the full proposed file to staging.** Under
   `<workspace-root>/skill-updates/<skill>/`, write the *complete* new version of
   each changed file at the same relative path (e.g.
   `skill-updates/<skill>/SKILL.md`). Full files, not fragments — so the user can
   diff staged-vs-live directly and copy the whole thing on accept.
3. **Write a rationale.** Alongside it, `skill-updates/<skill>/RATIONALE.md`:
   what changed, why, which `OBS-` id or user request drove it, and what you
   deliberately left alone. Keep it short.
4. **Show the diff, don't apply it.** Present the difference between live and
   staged (a unified diff is ideal) and stop. The user reads it and decides.

## Promotion is a human action

You do not copy the staged file over the live file. When the user says "apply
it", they mean *they* will — or, if they explicitly ask you to perform the copy
in that same turn, you may do exactly that one copy, name the source and
destination paths first, and do nothing else. There is no batch "apply all",
no "small enough to apply directly", no promotion during a Capture or Check run.

## Cross-cutting notes

If a proposal reveals something true of more than one skill (a house style, a
recurring default), note it in `RATIONALE.md` under a "cross-cutting" heading so
the user can decide whether to raise it library-wide. Do not fan out and edit
other skills yourself — flag it, that is all.

## What Propose never does

- Never writes outside `skill-updates/`.
- Never edits the live skill, even by one character, without the explicit
  single-copy request described above.
- Never deletes a prior staged proposal; if superseding one, write the new
  version beside it and say which is current.
