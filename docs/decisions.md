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

1. ~~A provider tells the admin, outside the app, that a household should be
   included.~~
2. ~~The admin generates a link for that household and sends it. The provider
   may pass it along, and may sit with the family while they fill it in.~~
3. The household submits the form themselves.
4. The link is single-use, specific to that household, and dead after use.

**Why:** if a therapist types a client's details into our system, we are
handling health-adjacent information on a provider's behalf. If the family
types it themselves, we aren't. ~~The provider never touches the app.~~

~~**Consequence 1 — providers are not users.** No provider login, no provider
screens, no provider table. The prototype's whole caseworker persona is gone.~~

> **Revised 2026-10-09** — steps 1–2 and Consequence 1 are reversed: the
> provider makes the link, from their own account. See *Providers get
> accounts* and *Providers create the family links* below. Steps 3–4, the
> reason, and Consequence 2 all stand.

**Consequence 2 — PII prevention just got harder.** The "make it awkward to
type a name" problem was written with a trained caseworker in mind. Now the
person typing is a parent describing their own kids, who will naturally write
"my son Marcus." Field design matters more, not less. Still needs its own
Story ([open question 9](open-questions.md)).

~~Form fields agreed so far: household size, number of children, each child's
age and pronouns, the story, how long they have been a client, wish list.~~

> **Superseded 2026-10-09** — see *What each party types in* below.

---

### ~~2026-10-06 · The admin is the only account~~

~~One login in the whole system. Everyone else is anonymous or holds a link.~~

| ~~Party~~ | ~~How they get in~~ |
|---|---|
| ~~Admin~~ | ~~Signs in~~ |
| ~~Household~~ | ~~One-time intake link~~ |
| ~~Donor~~ | ~~Nothing to browse; gives a name and email when claiming~~ |
| ~~Provider~~ | ~~Never~~ |

~~**Reverses:** donor magic-link sign-in, and caseworker logins.~~

~~**Consequence that isn't solved yet:** donors tick off items after claiming,
but a donor with no account has no way back to their claim. See *Unresolved*
below.~~

> **Reversed 2026-10-09** — providers sign in too. See *Providers get
> accounts, by the admin's invite only* below. Still true: households and
> donors never sign in, and the donor's way back to a claim is still open.

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
   must name the safe columns one by one, never "every column."
3. **Login is a stand-in.** The rule is "never roll our own auth." The demo's
   sign-ins are labelled placeholders and get thrown away. Nothing about auth
   is de-risked by this build.
4. **No email is sent.** Every "emails a link" step means someone copies a
   URL off the screen. The household's confirmation is a page, not an email.
5. **The one-time link points at `localhost`.** It only opens on Alex's
   machine. To put it on a phone, the server has to listen on the local
   network, which exposes it to everyone on that Wi-Fi. Fine at home, not in
   a café.
6. **The double-claim check has to be real anyway.** The prototype checked in
   the browser, which protects nothing. The server does it as one conditional
   update: mark the household claimed only if it is still available, then
   look at whether a row actually changed. No row changed means someone got
   there first. This is the one piece of the demo that must be
   production-correct, and it ports to Postgres unchanged.
7. **SQLite is looser than Postgres.** Foreign-key enforcement is off until
   switched on for each connection. Columns accept the wrong type unless the
   table is declared strict. There are no boolean, timestamp, or enum types.
   The schema belongs in a migration file from the first table, written so it
   ports. That file lives in the platform repo, not here.
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

### 2026-10-09 · Providers get accounts, by the admin's invite only

**Reverses:** *The admin is the only account* (2026-10-06), three days old.

Two kinds of account now: the admin, and providers.

- The admin invites a provider by name and email. The invite works once and
  dies 24 hours after it was sent. An expired one is resent by the admin.
- The provider uses it to pick a username and password.
- A provider's page has two controls: **create a form link**, and **sign
  out**. Nothing else. A provider never sees a household, a referral, a
  status, or another provider.
- The admin sees every provider account and can delete one. Deleting stops
  that provider signing in. It does not cancel links they already sent.

**What it buys:** under the 2026-10-06 flow a provider had to tell the admin,
outside the app, which family needed a link. Now the provider tells nobody.
The admin learns a household exists when the household submits its own form.

**What it costs:** more than one person now holds a password. That lands on
the platform rule *never roll our own auth*, with a second kind of user to
cover, and a password reset nobody has drawn yet. **Anything built here is an
auth change: stop and flag before starting it.**

| Party | How they get in |
|---|---|
| Admin | Signs in |
| Provider | Signs in. Account exists only by the admin's invite |
| Household | A one-time form link from their provider |
| Donor | Public pages. Gives name, phone and email when claiming |
| Co-sponsor | An invite link from the donor |

---

### 2026-10-09 · Providers create the family links, and a link lasts 48 hours

**Revises:** steps 1–2 of *The household fills in its own form* (2026-10-06).
The household still submits its own form. Who makes the link changed.

1. The provider creates a link. The site asks nothing about the family.
2. The provider emails it to the family **from their own email account**. The
   site never sees that message, and never learns who the link went to or
   when it was sent.
3. The link is for one family, works once, and dies 48 hours after it was
   created, used or not.
4. The household submits. The form reaches the admin as a referral.

**The referral carries the provider's name, as plain text.** It is copied
onto the referral when the family submits and is not a pointer to the
account. Delete the account and the name stays on every referral it produced.

**Accepted cost:** the provider's page keeps no history. Which link went to
which family is the provider's own bookkeeping. That is the point: the site
has nothing to leak about who a provider's clients are.

**Resolves:** how long an unused link lasts.

---

### 2026-10-09 · The family's email is the one piece of family contact data the site holds

**This reopens *No family PII* (2026-09-20) and narrows it. Said plainly,
because that decision is on the locked list.**

The rule as written named three things: names, addresses, phone numbers. All
three stay out. The email comes in, on these terms:

- The family types it into their own form. Nobody else can enter it.
- It is never public and never shown to a donor.
- It is used to send the family a copy of what they submitted.
- The site sees it nowhere else. The link itself travels through the
  provider's own email, not ours.
- It goes in the retention purge with every other contact detail, 60 days
  after the drive closes.

**What changes in the risk picture:** the original reason still holds — a
breach cannot show where a family lives. But a breach can now show a family's
email address, and an address like `first.last@…` is a name. The site holds
less than it would have under any earlier plan, and more than zero.

**What this commits us to:** the site now sends email to families, so email
delivery is part of the live release. Seed data uses `example.com` addresses
only, same as every other rule that follows from the public repo.

**Resolves:** the household-email conflict left open earlier today.

---

### 2026-10-09 · No photos, confirmed

No photo field on any page, optional or otherwise.

*No photos, v1 or later* (2026-09-20) stands. The 2026-10-06 notes that
mentioned an optional photo are not being followed.

**Resolves:** the photo conflict left open earlier today.

---

### 2026-10-09 · A co-sponsor joins by invite link, and the first sponsor stays the contact

Fills in *Co-sponsoring stays in the flow* (2026-10-06).

- At claim the donor picks **solo** or **with a friend**. The second choice
  gives them a link to pass on.
- The friend opens it, gives the same three details the donor gave, and joins
  the household. The link works for one co-sponsor.
- The donor who claimed stays the single point of contact for the drop-off.
- The admin can switch splitting off for the whole drive.

**Resolves:** the tension recorded on 2026-10-06. The admin's objection was
two people muddying who the drop-off contact is. There is still exactly one.

---

### 2026-10-09 · Thank-yous are relayed by the admin

The family thanks the admin, outside the app. The admin types the note in.
The sponsor sees it beside the household they sponsored.

**Reverses:** `thank-you note relay` in the original defer list.
**Settles:** the 2026-10-02 flow diagram dropped it, the 2026-10-04 meeting
kept it. It is in the flow.

It happens after gifts are delivered, so it is the last thing that has to
exist.

---

### 2026-10-09 · What each party types in

| Who | What | Seen by |
|---|---|---|
| Admin, inviting a provider | Provider's name and email | Admin |
| Provider, creating an account | Name, email, username, password | Admin sees the name and status |
| Provider, creating a link | Nothing | — |
| Household | A one-line household summary, number of adults, number of children | Donors, once published |
| Household | The story, with its own consent tick | Donors only if ticked **and** the admin leaves it on |
| Household, per person | Age, pronouns, clothing size, shoe size, needs, would love | Donors, once published |
| Household | Email | Admin only. Never public |
| Household | Two consents: an adult in the household agrees to share the wish list; the form cannot be edited after submitting | Admin |
| Donor | Name, phone, email | Admin. The co-sponsor sees the name |
| Co-sponsor | Name, phone, email | Admin. The donor sees the name |

The admin's choices on a referral are **publish, edit, or reject**. There is
no "send back for changes."

The roster export holds a household's id, description, status, sponsor, and
last update. **No contact details in the export.**

---

## Scope, as of 2026-10-09

Rewritten later the same day to follow the journey flow. The version written
that afternoon had the admin sending links and a single login.

### v1 demo (local)

One pass through the whole chain, on one machine:

1. Admin signs in (stand-in) and invites a provider. The invite is a link on
   the screen.
2. Provider opens the invite and creates an account (stand-in).
3. Provider creates a form link and copies it.
4. Household opens the link, fills in the form, ticks or doesn't tick story
   consent, submits. The link stops working.
5. Admin sees the referral with the provider's name on it, and publishes or
   rejects.
6. A published household appears on the public list: a number, a summary,
   the story if consented, each person's age and sizes, a wish list.
7. Donor claims it, solo or with a friend. The household leaves the public
   list.
8. A second donor trying the same household is told it's gone.
9. Admin sees the claim.

The 24-hour and 48-hour limits are in the demo. They are one stored timestamp
and one comparison each, and they are what makes a link a link.

**Not in the demo:** every email (invite, confirmation, reminder), password
reset, deleting a provider, the co-sponsor's join page, item tick-off and
receipt confirmation, re-listing, the per-sponsor cap, thank-yous, drive
settings, roster export, activity log, exception queue, deploy.

*Assumptions, not decisions:* that both sign-ins are stand-ins, and that the
demo shows the co-sponsor link without the page behind it. Correct either one
if wrong. The provider step added two screens to the demo since this
afternoon; if the demo needs to shrink, that is the piece to seed instead of
build.

### Live release

The whole flow, in the order the calendar needs it:

| Needed by | What |
|---|---|
| Nominations opening | Admin sign-in, provider invites and accounts, form links, household form and confirmation, approval queue |
| Nov 6 → Nov 30 | Public list, listing, claim, the lost-race screen, co-sponsor join, donor confirmation |
| Nov 30 → Dec 14 | Item tick-off, "dropped off", admin confirms receipt, reminders, re-listing |
| After Dec 14 | Thank-yous, close-out, retention purge |
| Throughout | Roster export. It is the fallback if the app fails, so it cannot be last |

Plus what the demo skips entirely: real auth for two kinds of account,
hosting, row-level security or its equivalent, email delivery.

**Still deferred:** SMS, in-app messaging.
**Still cut:** photos, payments, walk-in intake, self-service release.

---

## Unresolved as of 2026-10-09

Rewritten later the same day.

### Closed since this afternoon

- Household email vs. no family PII → *The family's email is the one piece…*
- Photos → *No photos, confirmed*
- How long an unused link lasts → 48 hours; provider invites, 24
- Thank-you notes → *Thank-yous are relayed by the admin*
- Co-sponsor vs. one drop-off contact → *A co-sponsor joins by invite link…*

### Still open

- **Provider passwords vs. "never roll our own auth."** Two kinds of account
  need real sign-in, and password reset has no screen. Nobody has chosen how.
- **How a donor gets back to their claim.** No donor accounts, but donors
  tick items off later. The flow proposes a link in the confirmation email.
  Not decided.
- **What contact the donor sees after claiming.** Open since 2026-10-04.
  Three mockups still carry the prototype's wording — "contact details unlock
  when you confirm," a named family contact on the confirmation page, and a
  locked setting called "hide contact details until a household is claimed."
  *No family PII* says there are no such details to unlock. Either that
  wording goes, or the contact shown is the provider's or the admin's.
- **"How long they have been a client."** Wanted on 2026-10-04. It is not on
  the household form, and a provider entering it is the provider entering
  client information.
- **Does the family hear when a sponsor claims them?** Not discussed.
- **When nominations open.** The settings mockup shows Oct 20 as sample data.
  If that is the real date, the first row of the live-release table is due
  then, not Nov 6.
- **Dave's sign-off:** a gate on going live only, or on building too?
- **Demo: foundation or throwaway?** See the demo entry.
- **Demo: which local server runtime?** See the demo entry.
