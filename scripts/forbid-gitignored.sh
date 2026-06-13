#!/usr/bin/env bash
# Block a commit that stages any path .gitignore would exclude (e.g. force-added
# with `git add -f`). .gitignore is the single source of truth: whatever you have
# chosen to ignore should never be committed, so there is no second list to drift.
#
# Wired as a pre-commit `local` hook (id: forbid-gitignored). On this machine git's
# core.hooksPath points at the global hooks, which delegate to `pre-commit run`, so
# this runs on every manual commit without `pre-commit install`.
#
# Bypass (discouraged): git commit --no-verify
set -uo pipefail

staged="$(git diff --cached --name-only)"
[ -z "$staged" ] && exit 0

# --no-index is REQUIRED. `git add -f` puts the file in the index, and by default
# git check-ignore trusts the index and reports a tracked path as "not ignored".
# --no-index forces evaluation against the .gitignore rules regardless of the index.
offenders="$(printf '%s\n' "$staged" | git check-ignore --no-index --stdin)"

if [ -n "$offenders" ]; then
    {
        printf 'BLOCKED: gitignored path(s) staged, refusing to commit:\n'
        printf '  %s\n' "$offenders"
        printf 'Unstage them (git reset <path>) or, if truly intended, commit --no-verify.\n'
    } >&2
    exit 1
fi

exit 0
