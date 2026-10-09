# Open questions

These gate real work. Each one should become a Story, a decision in
[decisions.md](decisions.md), or a line in the setup script — not linger here.

## Still open

- [ ] **2. Gifts or cash?**
      Claiming a wish list and sending money are different products with
      different screens. **This is the first Story and it is unanswered.**

- [ ] **5. How many households does this drive typically serve?**
      Thirty and three hundred are different architectures.

- [ ] **6. Nonprofit Stripe account + tax receipts.**
      Needs whoever handles the org's books. Not an engineering decision.

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
      caseworker in a hurry will put "Maria, 412 Oak St" in a notes field
      unless the form makes that awkward. Field design, placeholders,
      validation. **Needs a Story.**

- [ ] **10. Where does login come from, now that Supabase is out?**
      SQLite has no auth, and *never roll our own* is a locked rule. Phase
      one is a handful of known people and can run on a dev-only "sign in
      as" switcher that cannot be enabled in a production build. Donors,
      after Nov 6, need the real thing — a hosted magic-link provider.
      **Blocks the donor side. Does not block phase one.**

- [ ] **11. Is SQLite the production database too, or only for development?**
      At this scale it is genuinely fine to run on. The risk isn't load, it's
      that a file on one droplet dies with the droplet — so if yes, continuous
      backup to object storage becomes its own Story. If no, the swap to
      Postgres happens *before* real referrals land, not after.
      **Decide before Nov 6.**

- [ ] **12. Where does mom review and sign off, now that it isn't GitHub?**
      Falls straight out of question 3. She is the first real admin user and
      the UAT gate — something has to show her "here's what was built, does
      this work for you." Candidates: a short emailed summary per Story, a
      shared doc, or just sitting her in front of the running app. Cheapest
      thing that produces a real yes or no wins.
      **Decide before the first Story reaches UAT.**

## Resolved

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

- [x] **4. Organization name, coordinator contact, drop-off address,
      caseworker list.** → **Placeholders, and they stay placeholders.** We
      get a stand-in org name to build against; the real org name, coordinator
      contact, drop-off address, and household mapping live with mom and never
      enter this system or either repo. This isn't a shortcut — it's the same
      rule as *no family PII*, extended to the org's own details, and it means
      seed data is unblocked today.

      **One carve-out, dated:** caseworker *logins* need real email addresses
      before the coordinator flow goes live on **Nov 6**. Placeholders cover
      development; they don't cover launch. Ask mom for that list in late
      October — see [question 10](#still-open) for the login mechanism.

- [x] **7. Repo visibility?** → **Public, deliberately.** It's a forcing
      function: if it would be embarrassing in a public repo, the system
      shouldn't hold it. See [decisions.md](decisions.md).
