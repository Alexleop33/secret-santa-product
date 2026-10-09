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

### ~~2026-09-20 · Caseworker and donor emails are in scope~~

~~Needed for login, low sensitivity. Donors sign in by emailed magic link; no
donor passwords anywhere.~~

> **Reversed 2026-10-06** — nobody but the admin logs in. See
> *Admin is the only account* below. Donor email is still collected, at claim
> time, as a contact detail rather than a login.

---

### ~~2026-09-20 · Payments go through a Stripe link~~

~~Stripe holds card data on their side. We never touch it, store it, or log it.~~

> **Reversed 2026-10-04** — no payments at all. See *Gifts only, drop-off
> only* below.

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

## ~~Scope for v1~~

~~**Ship:** caseworker referral · coordinator approve/reject queue · donor
browse/claim/release/mark-delivered · roster CSV export · audit log ·
exception queue.~~

~~**Defer:** photo upload, co-sponsorship/splitting, thank-you note relay, SMS,
in-app messaging.~~

> **Superseded 2026-10-09** — see *Scope, as of 2026-10-09* at the bottom.

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

---

### 2026-10-04 · Roles renamed: provider and admin

"Caseworker" becomes **provider** — it has to cover therapists as well as
caseworkers. "Coordinator" becomes **admin**. Entries above this line keep the
old words because history isn't edited; read them as provider and admin.

There are four parties now, not three: **household**, **provider**, **admin**,
**donor**.

---

### 2026-10-04 · Gifts only, drop-off only, no payments

Donors buy gifts and drop them off. The app takes no money and links to no
payment page.

**Reverses:** *Payments go through a Stripe link*.
**Resolves:** [open question 2](open-questions.md) (gifts or cash → gifts) and
makes open question 6 (Stripe account, tax receipts) moot.

**Why:** one product, one set of screens. Cash is a different product.

---

### 2026-10-04 · A donor sponsors a whole household

No partial claims and no claiming individual wish-list items. One claim covers
one household.

Donors tick items off as they drop them off. The admin confirms receipt on
their side. The donor's tick is a claim; the admin's confirmation is the fact.

---

### 2026-10-04 · No self-service release

A donor who needs to back out emails the admin. The admin releases the
household. There is no "cancel sponsorship" button.

**Reverses:** `release` in the original v1 ship list.

**Why:** a released household is the admin's problem to re-home, so the admin
should be the one who knows it happened and why.

---

### 2026-10-04 · Website-only intake, and no edits after submission

No walk-in or phoned-in households, and no offline sponsors. Everything enters
through the site.

A submitted form is final. If something is wrong, the admin fixes it directly.
The prototype's "changes requested → resubmit" loop is gone.

---

### 2026-10-06 · The household fills in its own form, through a one-time link

**Reverses:** provider-submitted referrals — the first item in the original v1
ship list, and what the 2026-10-04 meeting had left as the default.

The flow:

1. A provider tells the admin, outside the app, that a household should be
   included.
2. The admin generates a link for that household and sends it. The provider
   may pass it along, and may sit with the family while they fill it in.
3. The household submits the form themselves.
4. The link is single-use, specific to that household, and dead after use.

**Why:** if a therapist types a client's details into our system, we are
handling health-adjacent information on a provider's behalf. If the family
types it themselves, we aren't. The provider never touches the app.

**Consequence 1 — providers are not users.** No provider login, no provider
screens, no provider table. The prototype's whole caseworker persona is gone.

**Consequence 2 — PII prevention just got harder.** The "make it awkward to
type a name" problem was written with a trained caseworker in mind. Now the
person typing is a parent describing their own kids, who will naturally write
"my son Marcus." Field design matters more, not less. Still needs its own
Story ([open question 9](open-questions.md)).

Form fields agreed so far: household size, number of children, each child's
age and pronouns, the story, how long they have been a client, wish list.

---

### 2026-10-06 · The admin is the only account

One login in the whole system. Everyone else is anonymous or holds a link.

| Party | How they get in |
|---|---|
| Admin | Signs in |
| Household | One-time intake link |
| Donor | Nothing to browse; gives a name and email when claiming |
| Provider | Never |

**Reverses:** donor magic-link sign-in, and caseworker logins.

**Consequence that isn't solved yet:** donors tick off items after claiming,
but a donor with no account has no way back to their claim. See *Unresolved*
below.

---

### 2026-10-06 · Claimed households leave the public list

Once claimed, a household disappears from what donors see and stays visible to
the admin.

The 2026-10-04 meeting said the opposite (stay listed, marked "claimed").
2026-10-06 is the later call and it wins.

---

### 2026-10-06 · The story is collected, shown only with consent

Every household writes a story. Whether donors see it is a checkbox on the
form, worded plainly: *this will be shown to donors*. Unticked means the admin
sees it and donors don't.

---

### 2026-10-06 · Co-sponsoring stays in the flow

A donor can bring in a second sponsor for the same household.

**Reverses:** `co-sponsorship/splitting` in the original defer list, and the
2026-10-04 meeting's call to drop it. Alex's decision, made when the journey
flows were updated.

**Tension to hold:** the 2026-10-04 reason for dropping it was that two
sponsors muddies who the drop-off contact is. Keeping it means one of the two
is still the named point person.

---

### 2026-10-06 · Nothing goes live without Dave's sign-off

Recorded in the 2026-10-06 meeting as a precondition for launch. Read here as
a gate on going live, not on the local demo — confirm that reading with Dave.

---

### 2026-10-09 · The v1 demo runs on Alex's machine, on SQLite, without Supabase

The first thing the admin sees is a local build: plain HTML, CSS, and
JavaScript in the browser, a SQLite file for data. No Supabase, no hosting, no
deploy.

**Why:** get the real flow in front of the admin fast, and find out what's
wrong with it before paying for auth, hosting, and row-level security.

**What this is not:** the live release. Nov 6 still needs a hosted app with
real auth. This decision pushes that work later; it doesn't remove it.

#### It needs one more piece than HTML, CSS, JS, and SQLite

A web page cannot open a database file. Browsers don't allow pages to read or
write arbitrary files on disk. Something has to sit between the page and the
`.db` file, and there are two ways to do it:

| | A. Small local server | B. SQLite inside the browser (WebAssembly) |
|---|---|---|
| What runs | A Node or Python process on `localhost` owns the `.db` file. Pages talk to it over HTTP. | SQLite compiled to WASM, loaded by the page. No server. |
| Where data lives | One file on disk, shared by every browser window | Inside one browser profile's storage |
| Admin and donor in two windows | Both see the same data | Only within the same browser profile; an incognito window sees an empty database |
| What carries over to the live build | The HTTP API and the SQL | Almost nothing |

**Recommended, not committed: A.** The demo's whole point is showing three
parties acting on the same data, and A forces the front end to talk to a back
end through defined requests — the part that survives the move to hosting.

Runtime inside A is open. Node keeps it to one language. Python ships SQLite
in its standard library. Either works.

#### What a local SQLite demo quietly leaves out

Each of these works differently, or doesn't exist, on a laptop. None is a
reason not to do the demo. All are things the demo does not prove.

1. **It has to be served, not double-clicked.** Opening `index.html` from the
   file system (`file://`) blocks the page's own requests. It runs at
   `http://localhost:<port>`.
2. **The security model is absent.** The platform rule is row-level security
   on every table, default deny. SQLite has no such thing. In the demo, the
   server code is the only thing deciding who sees what. The public listing
   must select an explicit list of safe columns, never `SELECT *`.
3. **Login is a stand-in.** The rule is "never roll our own auth." The demo's
   admin login is a labelled placeholder and gets thrown away. Nothing about
   auth is de-risked by this build.
4. **No email is sent.** "Admin sends the link" means the admin copies a URL
   off the screen. The household's confirmation is a page, not an email.
5. **The one-time link points at `localhost`.** It only opens on Alex's
   machine. To put it on a phone, the server has to listen on the local
   network, which exposes it to everyone on that Wi-Fi. Fine at home, not in
   a café.
6. **The double-claim check has to be real anyway.** The prototype checked in
   the browser, which protects nothing. The server does it in one statement —
   `UPDATE … SET status = 'claimed' WHERE id = ? AND status = 'available'` —
   and treats "zero rows changed" as "someone got there first." This is the
   one piece of the demo that must be production-correct, and it ports to
   Postgres unchanged.
7. **SQLite is looser than Postgres.** Foreign keys are off until switched on
   per connection (`PRAGMA foreign_keys = ON`). Columns accept the wrong type
   unless the table is declared `STRICT`. There are no boolean, timestamp, or
   enum types — use `0/1`, ISO-8601 text, and `CHECK` constraints. Write the
   schema as plain portable SQL in a migration file from the first table.
8. **The database file never gets committed.** The repo is public. `*.db` goes
   in `.gitignore`. Seed data is synthetic and comes from a script.
9. **It needs a reset.** A demo that has been clicked through once is used up:
   links spent, households claimed. One command restores the seed state.
10. **Nobody can try it afterwards.** The admin sees it on Alex's screen and
    cannot go home and poke at it. Feedback is limited to what gets shown.

#### What carries forward, and what doesn't

| Carries to the live build | Thrown away |
|---|---|
| Table shapes and the migration SQL | The login stand-in |
| The list of requests the pages make | SQLite-specific bits (pragmas, the file) |
| The atomic claim | Copy-the-link in place of email |
| Screens, wording, the form's fields | Anything that assumed one machine |

The platform repo's stack recommendation was React + Vite. A plain
HTML/CSS/JS demo may mean the screens are rebuilt for the live release.
**Decide before building whether the demo is a foundation or a throwaway** —
it changes how much care the front end deserves.

---

## Scope, as of 2026-10-09

### v1 demo (local)

One pass through the whole chain, on one machine:

1. Admin signs in (stand-in).
2. Admin generates a one-time intake link.
3. Household opens the link, fills in the form, ticks or doesn't tick story
   consent, submits. The link stops working.
4. Admin reviews, then approves or rejects.
5. An approved household appears on the public list as a code, a story (if
   consented), member ages and pronouns, and a wish list.
6. Donor claims it, with a name and email, optionally naming a co-sponsor.
   The household leaves the public list.
7. A second donor trying the same household is told it's gone.
8. Admin sees the claim.

**Not in the demo:** email, CSV export, audit log, exception queue, item
tick-off and admin receipt confirmation, admin-side release, thank-you notes,
photos, payments, deploy.

*Assumptions made here, not decisions:* that the donor gives name and email at
claim, and that the smallest honest version of co-sponsoring is a second
contact on the claim form. Correct either one if wrong.

### Live release (Nov 6 onward)

Everything in the demo, plus what the demo skips: real admin auth, hosting,
row-level security or its equivalent, email delivery, roster CSV export (the
fallback if the app fails in December), audit log, item tick-off with admin
confirmation, admin release.

**Still deferred:** thank-you notes, SMS, in-app messaging.
**Still cut:** photos, payments.

---

## Unresolved as of 2026-10-09

These are places where the meeting notes contradict a standing decision, or
where two decisions leave a hole. None has been decided. Each one is called
out here so that nobody quietly builds one side of it.

- **Household email vs. no family PII.** The 2026-10-06 notes want the link
  sent to the family's personal email and a confirmation emailed back. An
  email address is family contact information. *No family PII* still stands
  until someone reopens it on purpose. Ways through: the admin sends from
  their own mailbox and the app never stores the address, or the rule gets an
  explicit, written exception. The demo sends nothing, so it sidesteps this
  without answering it.
- **Photos.** The 2026-10-06 notes mention an optional photo. *No photos, v1
  or later* still stands and is not reopened by this update.
- **How a donor gets back to their claim.** No donor accounts, but donors
  tick off items later. Likely answer: a private link per claim, the same
  mechanism as the intake link. Not decided.
- **What contact the donor sees after claiming.** Provider, admin, or nothing
  beyond the drop-off instructions. Open since 2026-10-04.
- **How long an unused intake link lasts.** "Dead after use" is decided.
  "Dead after N days unused" is not.
- **Where "length of time as a client" is recorded**, and whether it comes
  from the household or the provider.
- **Thank-you notes.** Removed from the 2026-10-02 flow diagram, kept in the
  2026-10-04 meeting. Out of the demo either way.
- **Demo: foundation or throwaway?** See the 2026-10-09 entry.
- **Demo: which local server runtime?** See the 2026-10-09 entry.
