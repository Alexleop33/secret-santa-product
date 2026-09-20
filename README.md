# Sub for Santa — Product

A holiday gift-matching drive for a nonprofit, replacing a spreadsheet-and-
slides process. Caseworkers refer households; a coordinator approves them;
donors browse anonymized listings and sponsor a household.

**This repo holds no application code.** It holds Stories, decisions, and the
open questions that gate work. Code lives in
[secret-santa-platform](https://github.com/Alexleop33/secret-santa-platform).

## Start here

| | |
|---|---|
| Full background | [docs/handoff.md](docs/handoff.md) |
| What's been decided | [docs/decisions.md](docs/decisions.md) |
| What's still blocking | [docs/open-questions.md](docs/open-questions.md) |
| `gh` commands | [docs/gh-cheatsheet.md](docs/gh-cheatsheet.md) |

## Deadlines

| Date | Event |
|---|---|
| **Nov 6, 2026** | Nominations close — caseworker + coordinator flows live |
| **Nov 30, 2026** | Donor claims close |
| **Dec 14, 2026** | Gifts due |

Phase one is caseworker referral + coordinator approval only.

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
