# Sub for Santa — PRODUCT side

You are in the **product** repo. Full background: [docs/handoff.md](docs/handoff.md).
The handoff was written Sep 20 and predates the current flow. Where it and
this file disagree, this file and [docs/decisions.md](docs/decisions.md) win.

## What this repo is

Stories, decisions, and open questions for a holiday gift-matching drive for a
real nonprofit, running **this season**. Alex builds it; Alex's mom is the
admin and the first real user.

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

## The flow, as agreed through Oct 9

Source of truth for screens: the **Sub for Santa — User Journey Flows**
canvas (`https://claude.ai/artifact/6Ls9A2WHrxt6SyfffKUPiK`). Screen codes
below are its mockup names. The original prototype is older and wrong in
places; do not read requirements off it.

### Words

Say **provider**, **admin**, **household**, **donor**, **co-sponsor**. Never
"caseworker" or "coordinator" — those are the Sep 20 names. A provider is a
therapist or a caseworker.

### Five roles, two kinds of account

| Role | Gets in by | Can do |
|---|---|---|
| **Admin** | Signing in | Everything: invite and delete providers, review referrals, publish, edit, reject, confirm receipt, re-list, relay thank-yous, export, close the drive |
| **Provider** | Signing in. The account exists only by the admin's invite | Create a one-time form link. Sign out. **Nothing else, and sees no family** |
| **Household** | A one-time form link from their provider | Fill in one form, once |
| **Donor** | Public pages, no login | Browse, claim a whole household, tick items off, mark dropped off |
| **Co-sponsor** | An invite link from the donor | Join a household a friend already claimed |

### The chain

1. **Admin invites a provider** by name and email. The invite works once and
   expires 24 hours after it is sent. (A0)
2. **Provider creates an account** — username and password. (P0)
3. **Provider creates a form link** and emails it to the family from their
   own email account. One family per link, single use, dead 48 hours after
   creation. The site asks nothing about the family. (P1)
4. **Household fills in the form** themselves: household summary, each
   person's age, pronouns, sizes, needs and wants, an optional story with its
   own consent tick, and an email for their confirmation. No edits after
   submitting. (H1, H2)
5. **Admin reviews the referral**, which carries the provider's name as plain
   text. Publish, edit, or reject. No "send back." (A2)
6. **Donor browses** anonymous listings and **claims a whole household**, solo
   or split with a friend. The household leaves the public list on claim and
   stays visible to the admin. Two donors racing: one wins, the other is told.
   (D1–D5, D9, J1)
7. **Donor shops, ticks items off, marks them dropped off.** The admin
   confirms receipt. A donor who can't finish emails the admin; there is no
   cancel button. (D6, A3)
8. **Family thanks the admin; the admin relays it** to the sponsor. (A4, D7)
9. **Admin closes the drive.** Roster export, then the retention purge. (A5, A6)

Gifts only, dropped off. No payments, no walk-in intake, no photos.

## Two builds: the demo and the live release

**The v1 demo runs on Alex's machine only**: plain HTML, CSS and JavaScript, a
small local server, a SQLite file. No Supabase, no hosting. It exists to put
the real flow in front of the admin. It proves the flow and nothing about
auth, security, or email. Scope and the full list of what it leaves out:
[docs/decisions.md](docs/decisions.md), the 2026-10-09 entries.

**The live release** is the hosted app with real sign-in. The demo postpones
that work; it does not replace it.

A Story should say which build it is for.

## Dates that do not move

| Date | Event |
|---|---|
| **Nov 6, 2026** | Nominations close |
| **Nov 30, 2026** | Donor claims close |
| **Dec 14, 2026** | Gifts due |
| **Feb 12, 2027** | Retention purge |

What has to be live, in order:

| Needed by | What |
|---|---|
| Nominations opening (date not confirmed) | Admin sign-in, provider invites and accounts, form links, household form, approval queue |
| Nov 6 → Nov 30 | Public list, claim, co-sponsor join |
| Nov 30 → Dec 14 | Item tick-off, drop-off, receipt confirmation, reminders |
| After Dec 14 | Thank-yous, close-out, purge |

Roster export is the fallback if the app fails, so it is never "last."

## Locked decisions

Do not reopen these without saying plainly that you are reopening them:

- **No family PII — with one stated exception.** No names, addresses, or
  phone numbers for households, ever. The exception, decided Oct 9: the
  family's own **email**, typed by the family into their own form, never
  public, used to send their confirmation, purged with the drive.
- **The household submits its own form.** A provider never enters anything
  about a client. That is what keeps the drive clear of handling health
  information on a provider's behalf.
- **A provider's account can create form links and nothing else.** No view of
  any household, referral, or status.
- **Households and donors never get accounts.**
- **No payments.** Gifts only, drop-off only. No Stripe, no payment links.
- **No photos.** No photo field on any page, optional or otherwise.
- **A claim covers a whole household**, and only the admin can release one.
- **A submitted form is final.** The admin edits it directly if needed.
- **Co-sponsoring stays.** The donor who claimed remains the one drop-off
  contact.
- **Both repos are public, on purpose.** It's a forcing function: if it would
  be embarrassing in a public repo, the system shouldn't hold it. Nothing
  scary in source control — no real data, no secrets, no prod dumps. Sandbox
  data stays separate from prod.
- **Personal repos, no org.** `type:*` labels stand in for Issue Types;
  Story → Epic links are manual (Parent Story field + the Project's Story
  field). Settled — don't re-propose the org.
- Data model is **campaign-first**. No `organizations` table above campaigns.

Full list with reasoning, including what each of these reversed:
[docs/decisions.md](docs/decisions.md).

## Still open

Flow questions live at the bottom of [docs/decisions.md](docs/decisions.md)
under *Unresolved*. The ones most likely to be decided by accident:

- **How providers sign in.** Passwords run into "never roll our own auth,"
  and password reset has no screen.
- **How a donor gets back to their claim** with no account.
- **What contact a donor sees after claiming.** Some mockups still say
  "contact details unlock." Under *No family PII* there are none to unlock.
  Do not build that wording.
- **When nominations open.**

Process and setup questions: [docs/open-questions.md](docs/open-questions.md).
Its items 2 (gifts or cash) and 6 (Stripe account) are settled by the
no-payments decision.

## Working with Alex

- Plain language and diagrams over jargon.
- **Name the tradeoff.** Two reasonable options → give both, recommend one,
  say why.
- **Stop and flag** anything touching auth, PII, payments, or deletion.
  Provider accounts and the family email both sit in that category now.
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
