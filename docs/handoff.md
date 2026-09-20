# Sub for Santa — full context handoff

Written 2026-09-20. Everything established so far, in one place.
Drop this in the repo root as `CLAUDE.md`, or paste it as the opening
context of a Claude Code session.

---

## 1. What this is

A holiday gift-matching drive for a nonprofit, replacing a spreadsheet-and-
slides process. Caseworkers refer households in need; a coordinator approves
them; donors browse anonymized listings and sponsor a household.

**Alex** is building it. **Alex's mom** is the coordinator and the first real
admin user. The nonprofit is real, the donors will be real, and this runs
**this season**.

Alex's second goal is learning software engineering through an agentic SDLC.
Teaching is part of the deliverable, not a side effect.

---

## 2. Hard dates

Today is **2026-09-20**.

| Date | Event |
|---|---|
| **Nov 6, 2026** | Nominations close — caseworker + coordinator flows must be live |
| **Nov 30, 2026** | Donor claims close |
| **Dec 14, 2026** | Gifts due |
| **Feb 12, 2027** | Retention purge (from prototype copy) |

Seven weeks to the first deadline. It splits well: donor claiming doesn't
open until after Nov 6, so **phase one is caseworker referral + coordinator
approval only**. The donor side can land two weeks later.

---

## 3. The prototype

- Artifact: `https://claude.ai/code/artifact/2a8412ec-789a-4233-833d-f666df71903d`
- Publish URL for edits: `https://claude.ai/artifact/6FWA2nfPRAv3CQJKj9heY4`
- Title: "Sub for Santa Prototype (Copy)" · 1,207 lines · ~93 KB

Built by Alex's mom. Single self-contained HTML file, no framework, no build
step, no persistence. Vanilla ES5-flavored JS in one IIFE. State lives in a
single `S` object; `render()` rewrites `innerHTML` on three mount points;
clicks dispatch off `data-act="verb:arg"` through one big switch; inputs bind
via `data-model="path.to.field"`.

**It is the design reference, not the codebase.** We are building the real
thing. A detailed technical breakdown lives in
`claude_sub-for-santa-prototype-handoff.md` in the Claude project files.

### Screens it demonstrates

- **Donor:** browse → story → claim (2-step) → confirmed → my families
  (tick wish items, mark delivered, release)
- **Caseworker:** 5-section referral form → submit → tracker timeline
- **Coordinator:** dashboard → review queue → approve → exceptions → settings

---

## 4. Decisions made

### Locked

- **No family PII in the system.** No names, addresses, or phone numbers for
  referred households. This was Alex's call and it removes most of the risk.
- **Caseworker and donor emails are fine** — needed for login, low sensitivity.
- **Payments, if any, go through a Stripe link.** Stripe holds card data on
  their side; we never touch it.
- **Data model is campaign-first**, so multiple drives/programs can coexist
  later. But v1 is one campaign and shipping beats generality.
- **Two repos:** `Alexleop33/secret-santa-product` (GH Issues + Projects,
  product discipline) and `Alexleop33/secret-santa-platform` (code, eventually
  IaC via GitHub Actions to DigitalOcean).

### Consequence of "no family PII" that needs flagging to mom

The prototype's headline feature — claim a household, unlock their name and
phone — **cannot exist**. Delivery handoff moves offline: donors buy against
an anonymous household code, drop gifts at a central location tagged with that
code, and mom holds the code → family mapping in her own records. Better
design, worse demo. She should know the app won't tell anyone where to drive.

### Open — these gate real work

1. **GitHub org, or stay on personal repos?** (see §6 — this breaks things)
2. **Gifts or cash?** Claiming a wish list and sending money are different
   products with different screens. This is the first Story and it's unanswered.
3. **Will mom actually open GitHub?** If no, the two-repo split loses its
   main justification and one repo is simpler.
4. Organization name, coordinator contact, drop-off address, caseworker list.
5. **How many households does this drive typically serve?** Thirty and three
   hundred are different architectures.
6. Nonprofit Stripe account + tax receipts — needs whoever handles the org's
   books, not an engineering decision.

---

## 5. Proposed stack

Nothing here is committed; it's a starting recommendation.

- **Supabase** — Postgres, Auth, Row Level Security. Alex has prior exposure.
- **React + Vite** front end. Alex has built a React PWA before.
- **DigitalOcean** via GitHub Actions, per Alex's stated intent.

Rules regardless of stack:

- Never roll our own auth, sessions, or password storage.
- Donors sign in by emailed magic link. No donor passwords anywhere.
- RLS on every table from the first migration. Default deny, then open
  specific paths. No table ships without a policy and a test proving denial.
- No PII in URLs, query strings, or logs.
- **The app must never be the single point of failure.** If it breaks in
  December, mom must be able to fall back to a spreadsheet and still get gifts
  to families. Roster CSV export is a safety feature, not a nice-to-have.

### Data model sketch

Everything hangs off `campaigns`:

- `campaigns` — name, year, the three dates, status
- `households` — campaign_id, ref_code (`#14`), story text, status
- `household_members` — household_id, age, gender, notes. **No names.**
- `wish_items` — household_id, label
- `claims` — household_id, donor_id, status, claimed_at, released_at
- `users` — email, role (caseworker / coordinator)
- `activity` — campaign_id, actor, action, target, timestamp

Resist adding an `organizations` table above campaigns. Multi-campaign is
cheap now and expensive later; multi-tenant is expensive now and may never
be needed.

### Scope for v1

**Ship:** caseworker referral · coordinator approve/reject queue · donor
browse/claim/release/mark-delivered · roster CSV export · audit log ·
exception queue.

**Defer:** photo upload, co-sponsorship/splitting, thank-you note relay, SMS,
in-app messaging.

Photos are deliberately cut. Photos of children in low-income households pull
in storage, moderation, consent revocation, and retention obligations, and
they're the most damaging thing in a breach. Every other feature degrades
gracefully; that one doesn't.

---

## 6. The SDLC process Alex wants

1. **Product development happens only in `secret-santa-product`** — Stories,
   milestones, the product discipline.
2. **Engineering happens after and in correlation.** A Story becomes Ready,
   then it's broken into Epics and Issues, then agents action the work, then
   QA validates and does user acceptance + documentation, tracing back to the
   original Story.

### GitHub constraints that break parts of this

Verified, not guessed:

- **Milestones are strictly per-repo.** A milestone in the product repo
  cannot hold platform issues. Use a **Project field** instead — Projects
  span repos, milestones don't.
- **Cross-repo sub-issues require both repos in the same organization.**
  Two personal repos under `Alexleop33/` are not an org, so the Story → Epic
  parent link probably won't work.
- **Issue Types (Epic/Story/Task) are an org-level feature.** On a personal
  account you get labels, which work but don't roll up.
- **A sub-issue can have only one parent.** No many-to-many.

**Recommendation:** create a free GitHub organization and move both repos into
it. Fifteen minutes, and it unlocks all three. Alternative: collapse to one
repo and use labels. What doesn't work is two personal repos with a hierarchy
spanning them.

### Enforcement mechanisms

Process holds when something other than memory enforces it:

- **Issue templates with required fields** (below) — does most of the work
- **Definition of Ready gate** — a Story with the `needs:ready` label cannot
  be broken into Epics. Claude should *refuse* to break one down. That
  refusal is the enforcement.
- **Stage as a Project field**, not a label: Discovery → Ready → In Progress
  → In Review → UAT → Done
- **CI check** failing any PR with no linked issue

### Honest caution

This is a heavy chain for seven weeks and one engineer. The ceremony is worth
it because learning it is the point, but keep each artifact *small* — a Story
should be five lines, not a page. And parallel agent teams will generate more
diff than one person can review, which defeats the purpose. **Agents in
sequence, one vertical slice at a time.**

A slice = schema + policy + API + UI + a test, for one user action. Not
"the donor side."

---

## 7. How to work with Alex

- Plain language and diagrams over jargon. Stated preference.
- Assume React familiarity and some Supabase exposure. Don't assume depth in
  SQL, backend architecture, or RLS.
- **Spec before code.** Every change starts as a short written spec: what
  changes, why, what could break, how we'll know it worked. Wait for approval.
- **Never hand over code Alex can't explain.** After each slice, explain it
  plainly, then ask Alex to say it back. If he can't, the slice was too big.
- **Name the tradeoff.** Two reasonable approaches → give both, recommend one,
  say why.
- **Stop and flag** anything touching auth, PII, payments, or deletion.
- Push back. Agreement is worth less than accuracy.

---

## 8. Tooling reality (why this moved to Claude Code)

- **There is no GitHub MCP tool in Claude chat.** Searched the connector
  directory twice and the available-tools index once. Nothing.
- **The "GitHub Integration" connector is read/context only** — attach repo
  files in chat, sync files into a Project, select repos in Claude Code. It
  feeds GitHub *into* Claude. It does not write back.
- Unauthenticated `api.github.com` calls from the chat container get rate-
  limited on a shared IP, so even read verification failed.
- **Claude Code + `gh` CLI is the working path.** Hence this handoff.

Nothing in §9 has been executed or tested. Treat it as a first draft.

---

## 9. Bootstrap script and templates

### Prereqs

```bash
gh auth login
gh auth refresh -s project,read:project
```

The scope refresh is **not optional** — default `gh` auth excludes Projects
and you'll get an opaque 403 halfway through the script.

### `setup.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ───────────────────────────────────────────────
OWNER="Alexleop33"     # change to the org if you make one
IS_ORG=false           # flip to true if OWNER is an organization

PRODUCT="$OWNER/secret-santa-product"
PLATFORM="$OWNER/secret-santa-platform"
PROJECT_TITLE="Sub for Santa 2026"
# ──────────────────────────────────────────────────────────

say() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

say "Repos"
for repo in "$PRODUCT" "$PLATFORM"; do
  if gh repo view "$repo" >/dev/null 2>&1; then
    echo "  exists: $repo"
  else
    gh repo create "$repo" --private --add-readme --description "Sub for Santa"
    echo "  created: $repo"
  fi
done

# Labels stand in for Issue Types, which are org-only.
say "Labels"
mklabel() {
  gh label create "$2" --repo "$1" --color "$3" --description "$4" --force >/dev/null
  echo "  $1 :: $2"
}
for repo in "$PRODUCT" "$PLATFORM"; do
  mklabel "$repo" "type:story"  "0E8A16" "User-facing outcome. Product owns this."
  mklabel "$repo" "type:epic"   "5319E7" "A slice of a Story sized for engineering."
  mklabel "$repo" "type:task"   "1D76DB" "One unit of work. Lives under an Epic."
  mklabel "$repo" "type:bug"    "D73A4A" "Something is broken."
  mklabel "$repo" "type:chore"  "BFD4F2" "Maintenance. No user-visible change."
  mklabel "$repo" "blocked"     "E99695" "Waiting on something external."
  mklabel "$repo" "needs:ready" "FBCA04" "Fails Definition of Ready."
done

# The Project is the ONE thing spanning both repos.
say "Project"
if gh project list --owner "$OWNER" --format json | grep -q "\"title\":\"$PROJECT_TITLE\""; then
  echo "  exists: $PROJECT_TITLE"
else
  gh project create --owner "$OWNER" --title "$PROJECT_TITLE"
fi

PROJECT_NUMBER=$(gh project list --owner "$OWNER" --format json \
  | python3 -c "import sys,json;print([p['number'] for p in json.load(sys.stdin)['projects'] if p['title']=='$PROJECT_TITLE'][0])")
echo "  number: $PROJECT_NUMBER"

say "Project fields"
gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
  --name "Stage" --data-type SINGLE_SELECT \
  --single-select-options "Discovery,Ready,In Progress,In Review,UAT,Done" \
  2>/dev/null && echo "  created: Stage" || echo "  Stage exists"

gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
  --name "Story" --data-type TEXT \
  2>/dev/null && echo "  created: Story" || echo "  Story exists"
```

**Fragile bit:** the `PROJECT_NUMBER` lookup. If it errors, run
`gh project list --owner "$OWNER"` and hardcode the number.

### Manual steps with no worthwhile CLI equivalent

1. Project → ⋯ → Workflows → enable **Auto-add to project** for *both* repos.
   Without this you'll add items by hand and stop doing it by week two.
2. Project → Settings → set `Stage` default to `Discovery`.
3. Copy issue templates into the **product** repo.
4. Copy the CI workflow into the **platform** repo.

### `.github/ISSUE_TEMPLATE/story.yml`

```yaml
name: Story
description: A user-facing outcome. Product discipline. No implementation detail.
title: "[Story] "
labels: ["type:story", "needs:ready"]
body:
  - type: textarea
    id: outcome
    attributes:
      label: Outcome
      description: One sentence. Who, and what they can now do.
      placeholder: A caseworker can submit a household referral without emailing anyone.
    validations: { required: true }
  - type: textarea
    id: why
    attributes:
      label: Why this matters
      description: What breaks, or stays painful, if we don't build it.
    validations: { required: true }
  - type: textarea
    id: criteria
    attributes:
      label: Acceptance criteria
      description: >
        Observable behaviour only. These become the UAT checklist verbatim,
        so write them for someone who has never seen the code.
    validations: { required: true }
  - type: textarea
    id: out-of-scope
    attributes:
      label: Explicitly not in this Story
      description: >
        The most useful box on this form. Naming what you're NOT doing is how
        a Story stays small enough to finish.
    validations: { required: true }
  - type: dropdown
    id: size
    attributes:
      label: Rough size
      options: ["S — one sitting", "M — a few sittings", "L — needs splitting"]
    validations: { required: true }
  - type: dropdown
    id: milestone
    attributes:
      label: Which deadline does this serve?
      options:
        - Nov 6 — nominations close
        - Nov 30 — claims close
        - Dec 14 — gifts due
        - After the drive
    validations: { required: true }
  - type: checkboxes
    id: ready
    attributes:
      label: Definition of Ready
      description: Remove `needs:ready` only when all are true.
      options:
        - label: Acceptance criteria are observable, not internal
        - label: Out-of-scope is filled in honestly
        - label: No family PII is involved, or it's flagged below
        - label: Someone other than the author has read it
  - type: textarea
    id: risk
    attributes:
      label: Anything touching PII, payments, or deletion?
      description: Blank if no. If yes, say what — this gets a closer review.
```

### `.github/ISSUE_TEMPLATE/epic.yml`

```yaml
name: Epic
description: A slice of a Story, sized for engineering. Only after the Story is Ready.
title: "[Epic] "
labels: ["type:epic"]
body:
  - type: input
    id: parent
    attributes:
      label: Parent Story
      description: >
        Full URL. Cross-repo works only if both repos are in the same org.
        Otherwise paste it here and set the Project's "Story" field to match.
      placeholder: https://github.com/OWNER/secret-santa-product/issues/12
    validations: { required: true }
  - type: textarea
    id: slice
    attributes:
      label: What this slice covers
      description: schema + policy + API + UI + a test, for ONE user action.
    validations: { required: true }
  - type: textarea
    id: which-criteria
    attributes:
      label: Which acceptance criteria does this satisfy?
      description: Copy the specific lines from the parent Story.
    validations: { required: true }
  - type: textarea
    id: approach
    attributes:
      label: Approach
      description: How we're building it, and the alternative we rejected.
    validations: { required: true }
  - type: textarea
    id: breaks
    attributes:
      label: What could break
    validations: { required: true }
  - type: checkboxes
    id: dod
    attributes:
      label: Definition of Done
      options:
        - label: Migration applied
        - label: Access rules written AND tested (a test proving denial)
        - label: Happy path works
        - label: At least one failure path handled
        - label: I can explain this code out loud
        - label: Parent Story's criteria re-checked
```

### `.github/workflows/require-linked-issue.yml`

```yaml
name: Require linked issue

on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Look for a closing keyword
        env:
          BODY: ${{ github.event.pull_request.body }}
          TITLE: ${{ github.event.pull_request.title }}
        run: |
          PATTERN='([Cc]lose[sd]?|[Ff]ixe?[sd]?|[Rr]esolve[sd]?)[[:space:]]+((https://github\.com/[^/]+/[^/]+/issues/[0-9]+)|([A-Za-z0-9._-]+/[A-Za-z0-9._-]+)?#[0-9]+)'
          if printf '%s\n%s' "$TITLE" "$BODY" | grep -Eq "$PATTERN"; then
            echo "✓ Linked issue found."
            exit 0
          fi
          echo "✗ No linked issue. Add 'Closes #12' or 'Closes OWNER/repo#12'."
          exit 1
```

---

## 10. Suggested first moves in Claude Code

1. Answer the org-vs-personal question. Everything downstream depends on it.
2. Run `setup.sh`.
3. Write **one** Story: whichever answers gifts-vs-cash.
4. Break it into one Epic, one slice, and build that.

Don't write twelve Stories before building anything. One Story through the
entire chain — Story → Epic → code → PR → UAT → Done — teaches more than a
full backlog, and you'll redesign the process after the first pass anyway.
