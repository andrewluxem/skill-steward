# Capture — the observation log

Turn what a session revealed into durable notes, without editing anything.

## When

Only when the user asks ("log observations", "any observations from this
session?"). Never volunteer to write; it is fine to *mention* you noticed
something and offer to log it.

## What counts as an observation

- A correction the user made to a skill's output (the skill could be clearer).
- A gap: the user did something by hand that no skill covered.
- A phrasing or default in a skill that misfired.
- Something about a skill that surprised the user.

Skip trivia. One good observation beats ten vague ones.

## Format

Append one block per observation to
`<workspace-root>/skill-observations/log.md`. Never rewrite existing entries.

```
## OBS-<YYYYMMDD>-<n>
- date: <YYYY-MM-DD>
- skill: <skill-name or "none — candidate for new skill">
- signal: correction | gap | misfire | surprise
- what happened: <one or two sentences, concrete>
- suggested direction: <optional — a lead, not a finished change>
- status: open
```

`<n>` is the next integer for that date. To pick it safely, read the file first,
find the highest existing `<n>` for today, add one. If two entries could collide,
re-read and retry rather than guessing.

## Bounded-mutation discipline

The log is a shared file that other sessions may also append to. Follow this
every time:

1. **Fresh read.** Read the current file immediately before writing. Do not act
   on a copy you read earlier in the session.
2. **Append only.** Add your block at the end. Never edit or delete existing
   blocks — resolving an entry means changing its `status:` line to `applied` or
   `dropped` in place, nothing more.
3. **Verify.** After writing, read the file back and confirm your block is
   present and complete and that no prior block changed. If the numbering
   collided, fix yours (not the other one) and re-verify.

The helper `scripts/append-observation.sh` does this atomically with a lock; use
it when a shell is available. Doing it by hand is fine too — the three steps are
the contract, the script is a convenience.

## What Capture never does

It never opens a skill file, proposes a change inline, or edits the live skill.
Its only output is the log. Turning a note into a change is a separate, later,
explicitly-requested step (see `staging-workflow.md`).
