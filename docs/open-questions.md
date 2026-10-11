# Open questions

These gate real work. Each one should become a Story, a decision in
[decisions.md](decisions.md), or a line in the setup script — not linger here.

## Still open

- [ ] **5. How many households does this drive typically serve?**
      Thirty and three hundred are different architectures.

- [ ] **8. The `gh` login isn't allowed to touch Projects yet.**
      When you logged into the `gh` CLI, GitHub handed it a token — a key with
      a fixed list of things it's permitted to do. Right now that list is
      `gist`, `read:org`, `repo`: it can work with repos and issues, but
      *Projects* isn't on it, so every Project API call comes back denied.

      That matters because the Project board **"Sub for Santa 2026"** is the
      one thing that spans both repos, and its `Stage` field is how work moves
      Discovery → Ready → In Progress → In Review → UAT → Done. No Projects
      permission, no board, no `Stage`.

      The fix is adding two permissions to the existing login — not a new
      account, not a new token to paste anywhere:
      ```bash
      gh auth refresh -s project,read:project
      ```
      It prints a one-time code and opens GitHub in your browser; approve, and
      the terminal picks it up. Then re-run `scripts/setup.sh`. The script is
      already written to skip the Project step cleanly until the permission is
      there, so running it twice is safe.

- [ ] **9. How does the referral form stop PII being typed in?**
      Falls out of the public-repo decision. Policy isn't enough — a
      provider in a hurry will put "Maria, 412 Oak St" in a notes field
      unless the form makes that awkward. Field design, placeholders,
      validation. **Nothing is decided and nothing is built** — this is form
      design, and there is no form yet. Needs a Story when the referral form
      is the slice being built, not before.

- [ ] **10. What covers the family's one-time form link?**
      Narrowed twice on 2026-10-11 and now down to one piece. Google sign-in
      covers staff and donors; Supabase is the host and already carries magic
      links whenever they are wanted.
      **Families never sign in at all** — they open a one-time link, once, and
      that is their whole relationship with the app. Supabase magic links are
      the obvious candidate, but nothing has been decided and nothing built.
      **Blocks real referrals before Nov 6.**

- [ ] **12. Where does mom review and sign off, now that it isn't GitHub?**
      Falls straight out of question 3. She is the first real admin user and
      the UAT gate — something has to show her "here's what was built, does
      this work for you." Candidates: a short emailed summary per Story, a
      shared doc, or just sitting her in front of the running app. Cheapest
      thing that produces a real yes or no wins.
      **Decide before the first Story reaches UAT.**

## Resolved

- [x] **2. Gifts or cash?** → **Gifts. The app never handles money.**
      No Stripe link, no card data, no cash. Donors buy and drop off.
      See [decisions.md](decisions.md), 2026-10-11.

- [x] **6. Nonprofit Stripe account + tax receipts.** → **Closed, not
      deferred.** Falls away entirely with the no-payments decision. If the
      org ever wants to take money, that happens outside this system.

- [x] **11. Is SQLite the production database too, or only for development?**
      **Superseded 2026-10-11** — SQLite is out altogether, replaced by
      Postgres from the first table, so the question no longer has a subject.
      The original answer is kept below for its reasoning.
      → **Development only.** It is what the app runs on while it is built.
      Production is a separate decision, expected to be Supabase but
      deliberately not worked on until there is something running worth
      showing. The move happens *before* any real family data lands — at the
      latest before Nov 6 — and portable SQL only is what keeps it cheap.
      See [decisions.md](decisions.md).

- [x] **1. GitHub org, or personal repos?** → **Personal.** Labels stand in
      for Issue Types; Story → Epic links are manual via the Parent Story
      field and the Project's Story field.
      See [decisions.md](decisions.md).

- [x] **3. Will mom actually open GitHub?** → **No.** She will not be
      reviewing anything in GitHub. Stories, Epics, and the Project board are
      Alex's working tools and don't need to be legible to her. Her review
      surface is now [question 12](#still-open).

      **This does not reopen the repo split.** That was decoupled from this
      question in 35a9c27 and stands on the no-application-code rule, which
      holds whether or not she ever opens GitHub.

- [x] **4. Organization name, admin contact, drop-off address,
      provider list.** → **Placeholders, and they stay placeholders.** We
      get a stand-in org name to build against; the real org name, admin
      contact, drop-off address, and household mapping live with mom and never
      enter this system or either repo. This isn't a shortcut — it's the same
      rule as *no family PII*, extended to the org's own details, and it means
      seed data is unblocked today.

      **One carve-out, dated:** provider *logins* need real email addresses
      before the admin flow goes live on **Nov 6**. Placeholders cover
      development; they don't cover launch. Ask mom for that list in late
      October — see [question 10](#still-open) for the login mechanism.

- [x] **7. Repo visibility?** → **Public, deliberately.** It's a forcing
      function: if it would be embarrassing in a public repo, the system
      shouldn't hold it. See [decisions.md](decisions.md).
