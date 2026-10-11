# Sub for Santa — Product

A holiday gift-matching drive for a nonprofit, replacing a spreadsheet-and-
slides process. Providers refer households; an admin approves them;
donors browse anonymized listings and sponsor a household.

**This repo holds no application code.** It holds Stories, decisions, and the
open questions that gate work. Code lives in
[secret-santa-platform](https://github.com/Alexleop33/secret-santa-platform).

## Start here

| | |
|---|---|
| What's been decided | [docs/decisions.md](docs/decisions.md) |
| What's still blocking | [docs/open-questions.md](docs/open-questions.md) |
| Story drafts, in build order | [docs/stories.md](docs/stories.md) |
| The next slices, and the running order | [docs/slices.md](docs/slices.md) |
| What happened in run 1 | [docs/history/run-1.md](docs/history/run-1.md) |
| How this started (period document, not current) | [docs/handoff.md](docs/handoff.md) |
| `gh` commands | [docs/gh-cheatsheet.md](docs/gh-cheatsheet.md) |

## The three roles

`provider` refers a household, `admin` approves it and runs the drive, `donor`
sponsors one.

**Renamed from `caseworker` and `coordinator` on 9 Oct 2026, because the job
changed.** A caseworker used to type a family's details into the system; a
provider never does — they email a one-time link and the family fills in the
form themselves. "Provider" also covers the therapists and social workers who
refer, not one job title.

Decisions written before that date still use the old words.
[docs/decisions.md](docs/decisions.md) is append-only, so they stay as history
rather than being quietly rewritten.

## Deadlines

| Date | Event |
|---|---|
| **Nov 6, 2026** | Nominations close — provider + admin flows live |
| **Nov 30, 2026** | Donor claims close |
| **Dec 14, 2026** | Gifts due |

Phase one is provider referral + admin approval only.

## How work moves

```
Story (here)  →  Ready  →  Epic (platform)  →  PR  →  UAT  →  Done
   ▲                                                            │
   └──────────────── acceptance criteria traced back ───────────┘
```

A Story labelled `needs:ready` **cannot** be broken into Epics. That gate is
the whole process — everything else is paperwork.

Stage lives on the **Project board** ("Sub for Santa 2026"), not on issues.
Milestones are per-repo and can't span both sides.

## Setup

```bash
gh auth login
gh auth refresh -s project,read:project   # not optional — Projects need it
./scripts/setup.sh
```
