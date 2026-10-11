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

### 2026-09-20 · Provider and donor emails are in scope

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

[Open question 3](open-questions.md) resolved to "mom will not open GitHub"
and the split stands anyway: its justification is the no-application-code
rule, not whether she reads it. Revisit only if that rule stops holding.

---

## Scope for v1

**Ship:** provider referral · admin approve/reject queue · donor
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
  it hard for a provider or admin to type a name, address, or phone
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

### 2026-09-23 · SQLite instead of Supabase — for now

The database is a plain SQLite file. No Supabase project, no hosted Postgres,
nothing to sign into in order to run the app.

**Why:** Alex wants to run and test the whole thing alone, on one machine,
with no external service in the loop. For this scale — a handful of
providers, one admin, thirty to three hundred households — SQLite is
a correct choice, not a compromise. It will not be the thing that breaks.

**This one is provisional and says so.** It is scoped to "for now"
deliberately. It does not decide where data lives in December.

**What Supabase was carrying that SQLite does not:**

1. **Auth.** Magic-link login came free with it. SQLite has no users, no
   sessions, no password reset. The locked rule — *never roll our own auth* —
   still stands, so phase one runs on a dev-only "sign in as" switcher that
   must be impossible to enable in a production build, and the real answer is
   [open question 10](open-questions.md).
2. **Row Level Security.** SQLite has no policies, so "RLS on every table,
   default deny, a test proving denial" cannot be implemented as written.
   **Replacement rule:** every read and write goes through one server-side
   data module that takes the acting user and scopes the query to them. No
   table ships without a test proving the wrong user gets nothing back. Same
   requirement, one layer up, and now our job rather than the database's.

**Keep the escape hatch cheap.** Portable SQL only — no SQLite-only syntax,
no JSON blobs where columns belong, dates as ISO strings.

**Revisit when:** the donor side starts (donors need real logins), or before
anything holds real data in production — whichever comes first.

---

### 2026-10-09 · Providers sign in with a one-time link, every time

No username, no password, no account to create. A provider types their email,
gets a link, clicks it, and is in — the same way every time, not just the
first time. This supersedes **P0** in the Oct 9 journey canvas, which had the
provider choosing a username and password.

**Why:** there is nothing to store, hash, reset, or leak, and it's the same
mechanism already decided for donors (see *Provider and donor emails are in
scope*). One login to build instead of two.

**What it simplifies:** the admin's 24-hour invite and a sign-in link are now
nearly the same object. Adding a provider's email on **A0** is what creates
them; their first link is just their first sign-in. P0 may not need to exist.
Deleting a provider stops future links working — their name stays on past
referrals, unchanged.

**What still needs flagging:**

- **Email delivery becomes a hard dependency.** A link in a spam folder is a
  provider who cannot get in, and the admin flow has to be live Nov 6.
- **This narrows *never roll our own auth*, it doesn't satisfy it.** Passwords
  are gone, which is the dangerous half. We still own link generation,
  single-use enforcement, expiry, and session lifetime unless a hosted
  provider does it — and that choice is still [question 10](open-questions.md).
- **Link lifetime is unpicked.** The canvas uses 24h for invites and 48h for
  family form links. A sign-in link should be much shorter. Not decided here.


---

### 2026-10-10 · Families fill in the form themselves — and we store their email

The referral form is filled in by the **family**, not by a provider. A
provider creates a one-time link and emails it; the family opens it, fills it
in, and the submission lands straight in the admin's approval queue.

That means the system now holds **one piece of family contact data**: the email
address the confirmation copy goes to. It lives in its own `household_contacts`
table, keyed by household.

**Why:** a provider never re-types client information into this system, so
nothing about a family passes through a third party on its way in. The family
describes their own needs, in their own words.

**This narrows the no-family-PII rule, and it is recorded as an exception
rather than quietly added to a schema.** Until today that rule was absolute for
households: no names, no addresses, no phone numbers, no contact data of any
kind. A family email is a real departure from it.

**What keeps the blast radius small:**

- **Its own table**, not a column on `households`, so the February retention
  purge removes it with one `DELETE` that touches nothing else.
- **Never** in a donor-facing query, never in the roster CSV, never in a URL,
  never in a log line.
- **Email only. No phone number.** The confirmation copy cannot exist without
  the email; nothing needs the phone.

~~**REVISION NEEDED — revisit before this holds real data.**~~ **Answered later
the same day** — see *The family email: deleted on rejection, kept on approval*
at the end of this file, which carries one narrower item forward. The three
were:

1. **Is the confirmation copy worth the exception?** If a family does not
   actually need an emailed copy of what they submitted, the column should not
   exist at all. Nobody has asked a family.
2. **Does a family hear anything after submitting** — when they are approved,
   or when a sponsor claims them? The draft's H2 notes flag this as never
   discussed. If the answer is no, the email is needed once and could be
   deleted at approval instead of held until February.
3. **The one-time link is still our own code.** Generation, single-use
   enforcement and expiry are the same unresolved problem as
   [question 10](open-questions.md), and this decision adds a second caller for
   it.

---

### 2026-10-10 · The family gives consent on the form screen, and it gates publishing

Consent is collected on the referral form, from the family, at the moment they
submit. It is never assumed, and never given on their behalf by a provider or
the admin.

Two separate ticks, because they are two different permissions:

- **Share the wish list.** An adult in the household confirms they are an adult
  and agrees the wish list can be shown to donors.
- **Share the story.** A separate tick for the paragraph in their own words. A
  family can give the wish list and withhold the story.

**Why two and not one:** the wish list is what the drive needs in order to
function at all. The story is what makes a household easier to sponsor, and it
is the more personal of the two. Bundling them would mean a family who wants
help has to hand over the paragraph as well.

**It gates publishing in the app, not just on paper.** On the admin's
approval screen the *show story* switch is **disabled** when no story consent
was recorded, with the reason shown next to it. The admin cannot publish
a story the family did not agree to, even by accident.

**Where it lives:** `households.story_consent` records what the family chose.
`households.story_published` records what the admin actually switched on.
Two columns, because consent and publication are different facts — and a table
constraint refuses any row where `story_published` is true while
`story_consent` is false, so the rule holds even if the application code is
wrong.

**Already present in the clickable draft** — H1 collects both ticks and A2's
story switch is already gated on them. The gap was the data model, which had
neither column.

---

### 2026-10-10 · SQLite is the development database only

Resolves [question 11](open-questions.md).

SQLite is what the app runs on while it is being built. It is **not** the
production database.

**Why only development:** the point of SQLite was that Alex can run and test
the whole thing alone, on one machine, with nothing to sign into. That reason
holds while building. It does not hold for December — a file on one droplet
dies with the droplet, and the continuous-backup work that would make it safe
is its own piece of work nobody has started.

**What this commits us to:** the move to a real database happens **before any
real family data lands**, not after. Provider emails arrive in late October and
nominations close Nov 6, so that is the outside date.

**What it deliberately does not do:** schedule the move, or pick the
destination today. Supabase is the expected answer, because it carries
Postgres, magic-link auth and row-level security in one, which would also
settle [question 10](open-questions.md). Expected, not committed — and not
being worked on now, on purpose, until there is something running on SQLite
worth showing.

**What keeps the swap cheap, and has to be checked at every slice review:**
portable SQL only. No SQLite-only syntax, no JSON blobs where columns belong,
dates as ISO strings, and every query in one server-side data module rather
than scattered through the app. The schema already works this way —
`users.invite_expires_at` is stored rather than computed precisely because
`datetime(…, '+24 hours')` is SQLite-only syntax that Postgres spells
differently.

**The risk, named:** every week on SQLite is another week of code that might
quietly assume it. The portable-SQL rule is the only thing preventing that, and
a rule nobody checks is not a rule. It belongs on the Epic Definition of Done.

**Revisit:** before any real data. At the latest, before Nov 6.

---

### 2026-10-10 · Households have no login — the admin stays the relay

Families do not sign in. A family opens a one-time link, fills in the form
once, and that is their entire relationship with the app.

**What follows from it:**

- **Thank-you notes stay on the v1 defer list.** A family who wants to thank a
  sponsor tells the admin, who types the note in; the sponsor reads it on their
  own page. That path is drawn (A4 → D7) but is not being built for v1.
- **"No edits after submitting" stands on its own.** There is nowhere to log in
  to, so it is a property of the design rather than a rule to enforce.
- **The family email is needed once** — see the retention entry below.

**Why not give families a login:** an account means a session, a way back in
when it is lost, and a second credential worth stealing — for someone who uses
the app once. All cost, no benefit.

**One thing worth keeping whenever thank-yous do get built:** the admin reading
a note before it reaches a donor is not only relaying, it is a PII filter. A
family may well write "thank you from all of us on Oak Street." Whatever shape
this takes later, a person should still read it first.

**Revisit:** if thank-you notes come back into scope.

---

### 2026-10-10 · One-time links: a development stub now, a hosted provider before real data

Builds on *Providers sign in with a one-time link, every time* (2026-10-09),
which decided the mechanism. This decides how it is built for now.

The one-time referral link is a **development stub**. It makes a random link
and prints it to the terminal. It sends no email, and it claims no security.

**Three things keep it honest:**

1. It refuses to run unless the app is in development mode.
2. The file says at the top that it is throwaway.
3. When the hosted provider arrives, that file is **deleted, not improved.**

It still does link → check → burn, so the screens and the data module are built
against the real shape. Only the "send an email" part is fake.

**Why not build the real thing now:** generating tokens, enforcing single use
without two clicks both winning, expiry, storing a hash rather than the link,
and the session that follows a click are all **auth** — and *never roll our own
auth* is a locked rule. A magic link looks like three lines of code and is not.

**The useful discovery:** a family's way back in and a staff or donor login are
the same mechanism. That is one problem rather than two, and it narrows
[question 10](open-questions.md) instead of adding to it. It can also be solved
on its own — a hosted auth provider does not require moving the database.

**Revisit:** before the referral form is put in front of one real family.

---

### 2026-10-10 · The family email: deleted on rejection, kept on approval

Answers the three items stamped REVISION NEEDED on *Families fill in the form
themselves* above.

| Was unresolved | Answer |
|---|---|
| Is the confirmation copy worth the exception? | **Yes.** Families want a receipt for what they submitted. |
| Does a family hear anything after submitting? | **No.** No login, the admin relays, thank-yous deferred. |
| The one-time link is still our own code | See the stub entry above. |

**The retention rule, as decided today:**

- **Rejected or withdrawn** → the `household_contacts` row is **deleted**.
- **Approved** → the row is **kept, for now.**

**What is honestly still loose.** With thank-you notes deferred and no family
login, nothing in the app needs that email after approval. So "kept on
approval" is holding family contact data that has no live purpose yet. That is
an interim choice taken deliberately, with a date on it — not a justified one.

It is exactly the kind of thing the public-repo rule exists to surface, so it
is written down here rather than left to be noticed in December.

**Revisit before the drive goes public.** The options then are delete at
approval, delete at season close, or hold to the February purge. Whichever is
picked, it should be the narrowest one that still works.

---

### 2026-10-11 · Plain HTML, CSS and JavaScript — nothing else

Replaces **React + Vite**, chosen 2026-09-20. No framework, no bundler, no
TypeScript, no build step.

**Why:** the teaching goal, not performance. Alex has to be able to read every
line of this. A framework puts a layer between him and what the browser is
actually doing, and the whole second deliverable of this project is that he
understands what was built.

**What it costs:** more hand-written DOM code, and no component model. For an
app this small that is a fair trade.

---

### 2026-10-11 · No payments, ever — the app never handles money

Replaces **"payments, if any, go through a Stripe link"**, 2026-09-20, and
answers the long-open *gifts or cash?* question.

Donors buy gifts and drop them off. Nothing is collected, charged or
transferred anywhere in this system: no Stripe link, no card data, no cash.

**Why:** it removes PCI scope, refunds, chargebacks, reconciliation and a
charity's tax-receipt obligations in one line. If money ever changes hands for
this drive, it happens entirely outside the app.

**Consequence:** the donor flow is browse → claim → buy → drop off. There is
no checkout screen to build, and open question 6 (Stripe account and tax
receipts) is closed rather than deferred.

---

### 2026-10-11 · Postgres with row-level security, replacing SQLite

**Reopening a locked decision, deliberately.** SQLite replaced Supabase on
2026-09-23 so Alex could run and test alone with nothing to sign into. That
reason is being given up on purpose.

**Why:** RLS. Without it, keeping one provider out of another provider's
referrals is the application's job — one server-side data module, scoping
every query, with a test on every table proving the wrong user gets nothing.
That rule was sound and it was also entirely ours to get right, every time,
forever. With RLS the database refuses the wrong reader even when the
application code is wrong.

It also removes a scheduled migration. SQLite was development-only, and the
move to Postgres had to happen before any real family data landed — at the
latest Nov 6. Starting on Postgres means that move never has to be made, and
no more weeks of code quietly assuming SQLite.

**What this costs, named honestly:**

- **A dependency may now be the right answer.** Node's built-ins are still
  the first choice, but npm packages are allowed where they genuinely help.
- **"Nothing to sign into" is gone.** There is now a service in the loop
  before the first page renders.
- **RLS is the hardest thing on this project to learn, and a wrong policy
  looks exactly like a right one.** The mitigation is already in the PR
  template: a policy is not done without a test proving denial. That is
  non-negotiable on the first table, not the third.

**Still open:** which host. Managed Postgres and Supabase are both live
options — see [open-questions.md](open-questions.md).

**Dropped as a result:** *portable SQL only*. That rule existed solely to keep
a SQLite-to-Postgres move cheap. With Postgres from day one it has no job.

**Demoted, not dropped:** the one-server-side-data-module rule. RLS is now the
enforcement; the module stays as organisation, not as the security boundary.

---

### 2026-10-11 · Google sign-in is the login; magic links are postponed

Narrows [question 10](open-questions.md) rather than closing it.

Staff and donors sign in with Google. No passwords are stored, which keeps the
dangerous half of *never roll our own auth* satisfied.

**Explicitly postponed, not rejected: email magic links.** The decision to
have them at all is deferred until there is a running site.

**Two gaps this leaves, both dated:**

1. **Families still have no way in.** They never sign in — they open a
   one-time form link, once. Google does not touch that case, so the family
   link is still an unsolved mechanism and still blocks real referrals before
   **Nov 6**.
2. **Anyone without a Google account is excluded.** That is fine for the
   admin and probably fine for providers; for donors it is a real exclusion in
   a charity drive. Revisit when the donor side starts, before **Nov 30**.

---

### 2026-10-11 · Supabase is the host, with Google as the sign-in provider

For now, and marked that way on purpose.

**This fully reopens and reverses the decision of 2026-09-23**, which replaced
Supabase with SQLite. Supabase is back. The reason it left was so Alex could
run and test alone with nothing to sign into; choosing Postgres with RLS and
hosted Google sign-in gives that up anyway, so the reason no longer applies.

**Why Supabase rather than managed Postgres:** RLS only works if the database
knows who is asking. A policy saying *a provider sees only their own
referrals* needs something to tell Postgres who "them" is, on every
connection. Supabase issues the token and puts its claims where policies can
read them. With managed Postgres that bridge is ours to build, and so are
session cookies and Google token verification — which is session management,
the exact thing *never roll our own auth* exists to keep us away from.

**What stays entirely ours:** every RLS policy, all the SQL, all the HTML, CSS
and JavaScript. The only thing handed off is the session plumbing. It also
works with no dependencies if we want — Postgres over REST and auth over
HTTP, both with the built-in `fetch`, Google sign-in as a `<script>` tag —
though a package is fair game where it genuinely helps.

**What it unblocks:** magic links exist in Supabase already, so the family's
one-time form link can be solved later without re-architecting anything.

**The consequence that matters most, stated plainly:** the anon key is public
by design, and both repos are public. **RLS is therefore the only thing
standing between that public key and the data.** Not a layer of defence — the
layer. A table without a policy is a table anyone can read. This is why the
Definition of Done says a policy is not done without a test proving the wrong
user gets nothing.

**Revisit if** the free tier, data residency, or vendor risk becomes a real
problem. The escape hatch is cheap for the data — it is ordinary Postgres, so
`pg_dump` moves it. The part that would *not* come with it is auth, which
would have to be solved again.
