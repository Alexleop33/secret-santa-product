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
