# Sweep — the confidentiality sweep

Before a skill is published anywhere others can read it, scan for things that
should not leave your machine. Reusable skills are exactly where secrets get
leaked, because they get copied around.

## Trigger

"Sweep `<skill>` before I publish", or run it yourself before any public push,
gist, marketplace upload, or share.

## What it looks for

- **Secrets and tokens** — API keys, bearer tokens, `AWS_`/`sk-`/`ghp_`-style
  strings, `.env` contents pasted into examples, connection strings with
  passwords.
- **Credentials in snippets** — example commands that hardcode a real key rather
  than a placeholder.
- **Personal absolute paths** — `/Users/<you>/…`, home-dir leaks, machine names,
  internal hostnames that reveal your setup.
- **PII** — real names, emails, phone numbers, addresses in examples that were
  meant to be dummy data.
- **Internal references** — private repo names, internal URLs, client names,
  anything under NDA that wandered into an example.

## How

Scan every text file in the bundle. Report each hit with file, line, and a
one-line reason. Group by severity: secrets/credentials first (blocking),
personal paths and internal refs next, PII last.

## Output and boundary

Report only. **Never auto-redact.** Redacting silently can mangle a working
example or, worse, leave a partial secret. Show the user each hit and let them
fix it — replacing a real key with `<YOUR_API_KEY>`, swapping a personal path for
`~/…`, or dummying out PII. Re-sweep after they edit.

A clean sweep is not a guarantee — it is a floor. It catches the common,
pattern-matchable leaks; a human still reads the examples for context-dependent
disclosures a regex can't see.
