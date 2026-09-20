# Open questions

These gate real work. Each one should become a Story, a decision in
[decisions.md](decisions.md), or a line in the setup script — not linger here.

## Still open

- [ ] **2. Gifts or cash?**
      Claiming a wish list and sending money are different products with
      different screens. **This is the first Story and it is unanswered.**

- [ ] **3. Will mom actually open GitHub?**
      Now decoupled from the repo split (that's settled), but it still
      decides whether Stories get written in GitHub or somewhere she'll
      actually look.

- [ ] **4. Organization name, coordinator contact, drop-off address,
      caseworker list.** Blocks any real seed data.

- [ ] **5. How many households does this drive typically serve?**
      Thirty and three hundred are different architectures.

- [ ] **6. Nonprofit Stripe account + tax receipts.**
      Needs whoever handles the org's books. Not an engineering decision.

- [ ] **8. `gh` is missing the Projects scope.**
      Current token scopes: `gist`, `read:org`, `repo`. The Project board and
      its `Stage` field can't be created until this is fixed:
      ```bash
      gh auth refresh -s project,read:project
      ```
      Then re-run `scripts/setup.sh` — it skips the Project step cleanly
      until the scope is there.

- [ ] **9. How does the referral form stop PII being typed in?**
      Falls out of the public-repo decision. Policy isn't enough — a
      caseworker in a hurry will put "Maria, 412 Oak St" in a notes field
      unless the form makes that awkward. Field design, placeholders,
      validation. **Needs a Story.**

## Resolved

- [x] **1. GitHub org, or personal repos?** → **Personal.** Labels stand in
      for Issue Types; Story → Epic links are manual via the Parent Story
      field and the Project's Story field.
      See [decisions.md](decisions.md).

- [x] **7. Repo visibility?** → **Public, deliberately.** It's a forcing
      function: if it would be embarrassing in a public repo, the system
      shouldn't hold it. See [decisions.md](decisions.md).
