#!/usr/bin/env bash
# Bootstraps the GitHub side: labels on both repos, the shared Project, and
# the Project's Stage/Story fields. Safe to run more than once.
set -euo pipefail

# ─── CONFIG ───────────────────────────────────────────────
OWNER="Alexleop33"          # change to the org if you make one
PRODUCT="$OWNER/secret-santa-product"
PLATFORM="$OWNER/secret-santa-platform"
PROJECT_TITLE="Sub for Santa 2026"
# ──────────────────────────────────────────────────────────

say()  { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }
warn() { printf '\033[33m  ! %s\033[0m\n' "$1"; }
die()  { printf '\n\033[31m✗ %s\033[0m\n\n' "$1" >&2; exit 1; }

# ─── Preflight ────────────────────────────────────────────
say "Preflight"
command -v gh >/dev/null || die "gh not installed."
command -v jq >/dev/null || die "jq not installed."
gh auth status >/dev/null 2>&1 || die "Not logged in. Run: gh auth login"

SCOPES=$(gh auth status 2>&1 | sed -n 's/.*Token scopes: //p')
echo "  scopes: $SCOPES"
HAS_PROJECT_SCOPE=true
case "$SCOPES" in
  *project*) ;;
  *) HAS_PROJECT_SCOPE=false
     warn "Missing the Projects scope. Repos and labels will still be set up,"
     warn "but the Project and its Stage field will be skipped."
     warn "Fix with:  gh auth refresh -s project,read:project" ;;
esac

# ─── Repos ────────────────────────────────────────────────
say "Repos"
for repo in "$PRODUCT" "$PLATFORM"; do
  if gh repo view "$repo" >/dev/null 2>&1; then
    vis=$(gh api "repos/$repo" --jq '.private | if . then "private" else "PUBLIC" end')
    echo "  exists: $repo ($vis)"
    [ "$vis" = "PUBLIC" ] && warn "  ^ public. Flip with: gh repo edit $repo --visibility private"
  else
    gh repo create "$repo" --private --add-readme --description "Sub for Santa"
    echo "  created: $repo"
  fi
done

# ─── Labels ───────────────────────────────────────────────
# These stand in for Issue Types, which are an org-level feature.
say "Labels"
mklabel() {
  gh label create "$2" --repo "$1" --color "$3" --description "$4" --force >/dev/null
  echo "  ${1##*/} :: $2"
}
for repo in "$PRODUCT" "$PLATFORM"; do
  mklabel "$repo" "type:story"    "0E8A16" "User-facing outcome. Product owns this."
  mklabel "$repo" "type:epic"     "5319E7" "A slice of a Story sized for engineering."
  mklabel "$repo" "type:task"     "1D76DB" "One unit of work. Lives under an Epic."
  mklabel "$repo" "type:bug"      "D73A4A" "Something is broken."
  mklabel "$repo" "type:chore"    "BFD4F2" "Maintenance. No user-visible change."
  mklabel "$repo" "type:decision" "C5DEF5" "A question blocking work."
  mklabel "$repo" "blocked"       "E99695" "Waiting on something external."
  mklabel "$repo" "needs:ready"   "FBCA04" "Fails Definition of Ready."
  mklabel "$repo" "risk:pii"      "B60205" "Touches PII, payments, or deletion. Closer review."
done

if [ "$HAS_PROJECT_SCOPE" = false ]; then
  say "Done (Project skipped — no Projects scope)"
  exit 0
fi

# ─── Project ──────────────────────────────────────────────
# The Project is the ONE thing spanning both repos. Milestones can't.
say "Project"
PROJECT_NUMBER=$(gh project list --owner "$OWNER" --format json \
  | jq -r --arg t "$PROJECT_TITLE" '.projects[] | select(.title==$t) | .number' | head -1)

if [ -z "$PROJECT_NUMBER" ]; then
  gh project create --owner "$OWNER" --title "$PROJECT_TITLE" >/dev/null
  PROJECT_NUMBER=$(gh project list --owner "$OWNER" --format json \
    | jq -r --arg t "$PROJECT_TITLE" '.projects[] | select(.title==$t) | .number' | head -1)
  echo "  created: $PROJECT_TITLE"
else
  echo "  exists: $PROJECT_TITLE"
fi
[ -n "$PROJECT_NUMBER" ] || die "Couldn't find the project number. Run: gh project list --owner $OWNER"
echo "  number: $PROJECT_NUMBER"

say "Project fields"
existing=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json | jq -r '.fields[].name')

if ! grep -qx "Stage" <<<"$existing"; then
  gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
    --name "Stage" --data-type SINGLE_SELECT \
    --single-select-options "Discovery,Ready,In Progress,In Review,UAT,Done" >/dev/null
  echo "  created: Stage"
else
  echo "  exists: Stage"
fi

if ! grep -qx "Story" <<<"$existing"; then
  gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
    --name "Story" --data-type TEXT >/dev/null
  echo "  created: Story"
else
  echo "  exists: Story"
fi

# ─── Manual steps ─────────────────────────────────────────
cat <<EOF

▸ Four things with no worthwhile CLI equivalent

  1. Project → ⋯ → Workflows → enable "Auto-add to project" for BOTH repos.
     Without this you'll add items by hand and stop doing it by week two.
  2. Project → Settings → set Stage's default to Discovery.
  3. Confirm repo visibility (see warnings above, if any).
  4. Decide the org question — docs/open-questions.md, item 1.

  Board: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER

EOF
