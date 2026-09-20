# Sub for Santa — PRODUCT side

You are in the **product** repo. Full background: [docs/handoff.md](docs/handoff.md).

## What this repo is

Stories, decisions, and open questions for a holiday gift-matching drive for a
real nonprofit, running **this season**. Alex builds it; Alex's mom is the
coordinator and first real admin user.

The work here is product discipline: deciding *what* gets built and *why*, and
keeping each Story small enough to finish. The code lives in a different repo
and a different VS Code window.

## Hard rule: no application code here

Do not write React, SQL, migrations, or schema in this repo. If a task needs
code, say so and point at the platform window. Writing code here is how the
two-repo split quietly collapses into one confused repo.

What *does* belong here: issue templates, the setup script, docs, and small
scripts that manage GitHub itself.

## Hard rule: the Definition of Ready gate

A Story carrying the `needs:ready` label **cannot be broken into Epics.**

If asked to break one down, **refuse**, name which Definition-of-Ready
checkboxes are unticked, and offer to fix the Story instead. That refusal is
the enforcement mechanism — there is nothing else holding the process up.

## Keep artifacts small

A Story is five lines, not a page. Seven weeks, one engineer. The most useful
box on the Story form is "Explicitly not in this Story."

Do not write twelve Stories before anything is built. One Story through the
whole chain — Story → Epic → code → PR → UAT → Done — teaches more than a
backlog, and the process gets redesigned after the first pass anyway.

## Dates that do not move

| Date | Event |
|---|---|
| **Nov 6, 2026** | Nominations close — caseworker + coordinator flows must be live |
| **Nov 30, 2026** | Donor claims close |
| **Dec 14, 2026** | Gifts due |
| **Feb 12, 2027** | Retention purge |

Phase one is **caseworker referral + coordinator approval only**. Donor
claiming does not open until after Nov 6, so it can land two weeks later.

## Locked decisions

Do not reopen these without saying plainly that you are reopening them:

- **No family PII.** No names, addresses, or phone numbers for referred
  households, ever. This removes most of the project's risk.
- **Both repos are public, on purpose.** It's a forcing function: if it would
  be embarrassing in a public repo, the system shouldn't hold it. Nothing
  scary in source control — no real data, no secrets, no prod dumps. Sandbox
  data stays separate from prod.
- **Personal repos, no org.** `type:*` labels stand in for Issue Types;
  Story → Epic links are manual (Parent Story field + the Project's Story
  field). Settled — don't re-propose the org.
- Caseworker and donor emails are fine — needed for login, low sensitivity.
- Payments, if any, go through a **Stripe link**. We never touch card data.
- Data model is **campaign-first**. No `organizations` table above campaigns.
- **No photos.** Cut deliberately — see [docs/decisions.md](docs/decisions.md).

Full list with reasoning: [docs/decisions.md](docs/decisions.md).
Still open and gating work: [docs/open-questions.md](docs/open-questions.md).

## Working with Alex

- Plain language and diagrams over jargon.
- **Name the tradeoff.** Two reasonable options → give both, recommend one,
  say why.
- **Stop and flag** anything touching auth, PII, payments, or deletion.
- Push back. Agreement is worth less than accuracy.

## GitHub shape

- `gh` CLI is the working path. There is no GitHub MCP tool.
- Project **"Sub for Santa 2026"** is the one thing spanning both repos.
  Milestones are per-repo and cannot hold platform issues — use the Project's
  `Stage` field instead.
- `Stage`: Discovery → Ready → In Progress → In Review → UAT → Done.
- Issue Types (Epic/Story/Task) are org-only, so we use `type:*` labels.
- Cross-repo sub-issues need an org we don't have. An Epic records its parent
  by **URL** in its Parent Story field, and both items get the Project's
  **Story** text field set to match. Manual, and that's the accepted cost.

Common commands live in [docs/gh-cheatsheet.md](docs/gh-cheatsheet.md).
