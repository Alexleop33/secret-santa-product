# Open questions

These gate real work. Each one should become a Story, a decision in
[decisions.md](decisions.md), or a line in the setup script — not linger here.

- [ ] **1. GitHub org, or stay on personal repos?**
      Breaks three things if we stay personal: cross-repo sub-issues need one
      org; Issue Types (Epic/Story/Task) are org-only; Story → Epic parent
      links won't span `Alexleop33/x` and `Alexleop33/y`.
      *Recommendation: create a free org, move both repos in. ~15 minutes,
      unlocks all three. Alternative: collapse to one repo and use labels.
      What does not work is two personal repos with a hierarchy across them.*

- [ ] **2. Gifts or cash?**
      Claiming a wish list and sending money are different products with
      different screens. **This is the first Story and it is unanswered.**

- [ ] **3. Will mom actually open GitHub?**
      If no, the two-repo split loses its main justification.

- [ ] **4. Organization name, coordinator contact, drop-off address,
      caseworker list.** Blocks any real seed data.

- [ ] **5. How many households does this drive typically serve?**
      Thirty and three hundred are different architectures.

- [ ] **6. Nonprofit Stripe account + tax receipts.**
      Needs whoever handles the org's books. Not an engineering decision.

---

## Added during setup, 2026-09-20

- [ ] **7. Both GitHub repos are currently public.**
      The handoff specified `--private`. Nothing sensitive is in them yet, and
      there is no family PII by design — but household story text and the
      nonprofit's name will land in issues. Decide before the first real Story.

- [ ] **8. `gh` is missing the Projects scope.**
      Current token scopes: `gist`, `read:org`, `repo`. The Project board and
      its `Stage` field cannot be created until this is fixed:
      ```bash
      gh auth refresh -s project,read:project
      ```
      `scripts/setup.sh` will stop and tell you if this hasn't been done.
