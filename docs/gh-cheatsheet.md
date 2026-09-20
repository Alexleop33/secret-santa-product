# gh cheatsheet

`gh` is the working path — there is no GitHub MCP tool in Claude. Everything
below runs from the **product** window.

```bash
OWNER=Alexleop33
PRODUCT=$OWNER/secret-santa-product
PLATFORM=$OWNER/secret-santa-platform
```

## Stories

```bash
# open a Story using the template (browser)
gh issue create --repo $PRODUCT --web --template story.yml

# what's not Ready yet
gh issue list --repo $PRODUCT --label needs:ready

# what IS Ready — these are the only ones that may become Epics
gh issue list --repo $PRODUCT --label type:story --search '-label:needs:ready'

# pass the Definition of Ready gate
gh issue edit <N> --repo $PRODUCT --remove-label needs:ready
```

## Across both repos

```bash
gh issue list --repo $PRODUCT  --label type:story
gh issue list --repo $PLATFORM --label type:epic

# everything open, both sides, newest first
gh search issues --owner $OWNER --state open --sort created
```

## The Project board

Needs the Projects scope: `gh auth refresh -s project,read:project`

```bash
gh project list --owner $OWNER
gh project item-list <PROJECT_NUMBER> --owner $OWNER
gh project item-add  <PROJECT_NUMBER> --owner $OWNER --url <issue-url>
gh project field-list <PROJECT_NUMBER> --owner $OWNER
```

Stage lives on the Project, not on the issue — milestones are per-repo and
can't hold platform issues.

## Linking a Story to an Epic

Cross-repo sub-issues need both repos in one org. Until that happens:

1. Paste the Story URL into the Epic's **Parent Story** field.
2. Set the Project's **Story** text field to match on both items.

That's the workaround, and it's manual. It's also
[open question 1](open-questions.md).
