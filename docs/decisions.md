# Decisions

Append-only. If a decision gets reversed, strike it and add a new entry below
with the date and the reason — don't edit history.

---

### 2026-09-20 · No family PII in the system

No names, addresses, or phone numbers for referred households. Households are
identified by a reference code (`#14`) only.

**Why:** it removes most of the project's risk surface in one move. A breach of
this system cannot expose where a low-income family lives.

**Consequence that needs flagging to mom:** the prototype's headline feature —
claim a household, unlock their name and phone — *cannot exist*. Delivery
handoff moves offline: donors buy against the household code, drop gifts at a
central location tagged with that code, and mom holds the code → family mapping
in her own records. Better design, worse demo. **She should know the app will
not tell anyone where to drive.**

---

### 2026-09-20 · Caseworker and donor emails are in scope

Needed for login, low sensitivity. Donors sign in by emailed magic link; no
donor passwords anywhere.

---

### 2026-09-20 · Payments go through a Stripe link

Stripe holds card data on their side. We never touch it, store it, or log it.

---

### 2026-09-20 · Campaign-first data model, no `organizations` table

Everything hangs off `campaigns`, so multiple drives can coexist later.

**Why not multi-tenant:** multi-campaign is cheap now and expensive later;
multi-tenant is expensive now and may never be needed.

---

### 2026-09-20 · No photos, v1 or later

**Why:** photos of children in low-income households pull in storage,
moderation, consent revocation, and retention obligations, and they are the
most damaging thing in a breach. Every other cut feature degrades gracefully.
That one doesn't.

---

### 2026-09-20 · The app must never be the single point of failure

If it breaks in December, mom must be able to fall back to a spreadsheet and
still get gifts to families. **Roster CSV export is a safety feature, not a
nice-to-have.**

---

### 2026-09-20 · Two repos, one Project

`secret-santa-product` for product discipline, `secret-santa-platform` for
code. The GitHub Project spans both; milestones cannot.

Revisit if [open question 3](open-questions.md) resolves to "mom will not open
GitHub" — the split loses its main justification and one repo is simpler.

---

## Scope for v1

**Ship:** caseworker referral · coordinator approve/reject queue · donor
browse/claim/release/mark-delivered · roster CSV export · audit log ·
exception queue.

**Defer:** photo upload, co-sponsorship/splitting, thank-you note relay, SMS,
in-app messaging.

---

### 2026-09-20 · Repos stay public — and that's a forcing function

Both repos are public and stay public.

**Why:** not convenience. It's a constraint we're choosing on purpose. If a
public repo would be embarrassing, the system shouldn't hold that data in the
first place. Public SCM makes "no PII" enforceable instead of aspirational —
you can't quietly let a phone number creep into a seed file.

**What this commits us to:**

- **Nothing scary in source control.** No real household data, no real donor
  emails, no secrets, no production dumps, no `.env`. Seed and fixture data is
  synthetic and obviously fake.
- **Sandbox data stays separate from prod.** Different projects/keys, and
  nothing from prod ever gets copied down to develop against.
- **Product-side prevention, not just policy.** The referral form has to make
  it hard for a caseworker or coordinator to type a name, address, or phone
  in the first place — field design, placeholder text, and validation, not a
  paragraph in a training doc. *Needs a Story of its own.*

The last one is the real work. The first two are just discipline.

---

### 2026-09-20 · Staying on personal repos — resolved

No GitHub org. Both repos stay under `Alexleop33/`.

**What we give up:** cross-repo sub-issues, org-level Issue Types
(Epic/Story/Task as real types), and automatic Story → Epic rollup.

**The workaround, which is now the process:**

1. `type:*` labels stand in for Issue Types.
2. An Epic records its parent by URL in the **Parent Story** field.
3. The Project's **Story** text field is set to match on both items.

It's manual. Accepted deliberately: seven weeks, one engineer, and the
migration cost isn't worth it for a hierarchy one person is maintaining.

Revisit only if a second engineer joins.
