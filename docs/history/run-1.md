# Run 1 — history

**Run 1 is the first pass at this project: 2026-09-20 to 2026-10-11.** It
produced ~2,200 lines of product documentation and zero lines of application
code, then was deliberately cut back. This file is the record of what happened
and why.

It is **history, not instructions.** Nothing here governs current work.
[../../CLAUDE.md](../../CLAUDE.md) is the only authoritative file in this repo.

The artifact run 1 was built around — the full 489-line bootstrap handoff — is
kept in its original 2026-09-20 form at [../handoff.md](../handoff.md), and in
git at commit `14054b4`. Read it as a period document; it is stale by design.

---
The handoff was the bootstrap document: everything established about Sub for Santa in
one place, written to be dropped into a repo root or pasted as the opening
context of a Claude Code session. It did that job. The repo it was bootstrapping
now exists, and the live truth has moved into files that get edited:

| What | Where it lives now |
|---|---|
| How to work in this repo, locked decisions, dates | [../../CLAUDE.md](../../CLAUDE.md) |
| Decisions with reasoning, append-only | [../decisions.md](../decisions.md) |
| What's still blocking work | [../open-questions.md](../open-questions.md) |
| The next slice, and the running order after it | [../slices.md](../slices.md) ¹ |
| Story drafts, in build order | [../stories.md](../stories.md) ¹ |
| `gh` commands | [../gh-cheatsheet.md](../gh-cheatsheet.md) |

¹ **Not written yet as of 2026-10-11.** `slices.md` and `stories.md` are
referenced by [../../README.md](../../README.md), [../../CLAUDE.md](../../CLAUDE.md) and
[../handoff.md](../handoff.md), but neither file exists. That is run 2's first
gap to close.

Nothing should link here for current state. If something does, that link is
the bug.

---

## Why it was cut back: running ahead, then stepping back

By 2026-10-11 this repo held about 2,200 lines of product documentation and the
platform repo held no `package.json`. Not one line of application code existed
in either repo. Most of that writing was real thinking and worth having. Some of
it had run a long way ahead of anything built, and the handoff was the worst
offender — which is the joke, because §6 of it warned, in writing, that *"a
Story should be five lines, not a page"* and then grew to 500.

What running ahead actually looked like:

- **Eleven Story drafts before anything was built**, against this repo's own
  rule not to write twelve Stories before the first one ships. Four survive.
- **Deployment fully specified before a page rendered.** A droplet, a domain, a
  TLS renewal test, a rollback procedure and a test-site banner all had
  acceptance criteria and Definitions of Ready while the app could not yet
  serve a page. They are now one-line items in [../slices.md](../slices.md), which is
  the right size for work nobody has started.
- **Decisions written about columns in a schema file that does not exist.**
  `users.invite_expires_at`, `households.story_consent` and
  `households.story_published` were all discussed as though
  `data-model/schema.sql` were real. It is in neither repo. That is now a
  blocker on Story 1 instead of an assumption underneath everything.
- **§9 of the handoff specified two files that were never created** — an
  `epic.yml` issue template and a `require-linked-issue.yml` workflow. There is
  no `.github/workflows/` directory at all. It also carried an inline copy of
  `setup.sh` that drifted out of step with the real
  [../../scripts/setup.sh](../../scripts/setup.sh).
- **Two files disagreeing on the same day.** On 11 Oct, `slices.md` recorded the
  referral form's PII check as settled on warn-only while `stories.md` still
  carried it as an open choice gating Ready. Specification is the most
  perishable thing in a project, and it had started to rot in under a day.

The lesson, kept because it was learned the expensive way: **write the process
artifacts needed to carry one slice, then build the slice.** The first pass
through Story → Epic → code → PR → UAT → Done changes the shape of everything
downstream of it, so anything specified before that pass gets rewritten anyway.
The decision log was the exception and is the one artifact that earned every
line — it records conversations, which cannot be re-derived from code.

---

## Facts the handoff recorded that live nowhere else

Still current. They belong in [../decisions.md](../decisions.md) eventually; until
then, this is where they are.

### Stack

- **React + Vite** front end. Alex has built a React PWA before.
- **DigitalOcean** for hosting, via GitHub Actions, per Alex's stated intent.
- **SQLite** for development only — that one *is* in
  [../decisions.md](../decisions.md), along with the default-deny data-module rule and
  the portable-SQL rule that replaced Supabase's auth and RLS.

### Data model sketch

Everything hangs off `campaigns`:

- `campaigns` — name, year, the three dates, status
- `households` — campaign_id, ref_code (`#14`), story text, status
- `household_members` — household_id, age, gender, notes. **No names.**
- `wish_items` — household_id, label
- `claims` — household_id, donor_id, status, claimed_at, released_at
- `users` — email, role (provider / admin)
- `activity` — campaign_id, actor, action, target, timestamp

Resist adding an `organizations` table above campaigns. Multi-campaign is cheap
now and expensive later; multi-tenant is expensive now and may never be needed.

### The prototype

Built by Alex's mom: one self-contained HTML file, no framework, no build step,
no persistence. **It is the design reference, not the codebase.**

- Artifact: `https://claude.ai/code/artifact/2a8412ec-789a-4233-833d-f666df71903d`
- Publish URL for edits: `https://claude.ai/artifact/6FWA2nfPRAv3CQJKj9heY4`

### Why this project moved to Claude Code

There is no GitHub MCP tool in Claude chat. The "GitHub Integration" connector
is read/context only — it feeds GitHub *into* Claude and does not write back.
Claude Code plus the `gh` CLI is the working path, which is why the handoff
was written in the first place.
