#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${ROOT_DIR}/pygeoapi"
TARGET_BRANCH="master"
MERGE_UPSTREAM=1
DRY_RUN=0

is_git_repo() {
  git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

usage() {
  cat <<'EOF'
Usage: ./sync-upstream.sh [options]

Sync local pygeoapi checkout with fork and upstream remotes.

Options:
  --no-merge-upstream   Only pull origin/master; do not merge upstream/master
  --dry-run             Show what would run and exit
  -h, --help            Show this help text

What this script does:
  1. Verifies pygeoapi repo and required remotes
  2. Stashes local changes (including untracked) if needed
  3. Checks out master
  4. Fetches origin and upstream
  5. Pulls origin/master with rebase + autostash
  6. Merges upstream/master into local master (unless disabled)
  7. Restores stashed local changes
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-merge-upstream)
      MERGE_UPSTREAM=0
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! is_git_repo "${REPO_DIR}"; then
  echo "Expected git repository at ${REPO_DIR}, but none was found." >&2
  exit 1
fi

run_cmd() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    eval "$*"
  fi
}

cd "${REPO_DIR}"

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Missing origin remote in ${REPO_DIR}." >&2
  exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "Missing upstream remote in ${REPO_DIR}." >&2
  echo "Add it with: git remote add upstream git@github.com:geopython/pygeoapi.git" >&2
  exit 1
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
needs_stash=0
stash_ref=""

if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  needs_stash=1
fi

restore_stash() {
  if [[ "${needs_stash}" -eq 1 && -n "${stash_ref}" ]]; then
    echo "Restoring stashed local changes..."
    if ! git stash pop --index "${stash_ref}"; then
      echo "WARNING: Could not auto-apply stash cleanly." >&2
      echo "Your changes are still in stash. Inspect with: git stash list" >&2
      return 1
    fi
  fi
}

if [[ "${needs_stash}" -eq 1 ]]; then
  echo "Stashing local changes..."
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "[dry-run] git stash push -u -m auto-sync-upstream"
  else
    git stash push -u -m auto-sync-upstream >/dev/null
    stash_ref="$(git stash list | head -n 1 | cut -d: -f1)"
  fi
fi

trap 'restore_stash' EXIT

echo "Checking out ${TARGET_BRANCH}..."
run_cmd "git checkout ${TARGET_BRANCH}"

echo "Fetching remotes..."
run_cmd "git fetch origin --prune"
run_cmd "git fetch upstream --prune"

echo "Pulling origin/${TARGET_BRANCH}..."
run_cmd "git pull --rebase --autostash origin ${TARGET_BRANCH}"

if [[ "${MERGE_UPSTREAM}" -eq 1 ]]; then
  echo "Merging upstream/${TARGET_BRANCH}..."
  run_cmd "git merge --no-edit upstream/${TARGET_BRANCH}"
else
  echo "Skipping upstream merge (--no-merge-upstream)."
fi

trap - EXIT
restore_stash

echo
echo "Sync complete."
if [[ "${current_branch}" != "${TARGET_BRANCH}" ]]; then
  echo "You started on branch ${current_branch}. You are now on ${TARGET_BRANCH}."
fi

echo "Final status:"
if [[ "${DRY_RUN}" -eq 0 ]]; then
  git status --short
fi
