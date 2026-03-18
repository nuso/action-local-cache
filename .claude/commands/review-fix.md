---
description: Fix approved PR review comments and resolve their GitHub conversations
---

# Fix PR Review Comments

You are tasked with implementing fixes for approved PR review comments and optionally resolving their GitHub conversation threads.

## Step 1: Understand the Input

The user will provide fix items in one of these ways:

**Option A — From `/review-triage` output:**
- The user has already triaged comments and approved specific fixes
- They may paste the approved items or reference the triage summary from conversation history

**Option B — Direct input:**
- The user provides specific review feedback to fix (pasted from email, GitHub, or described verbally)
- For each item, identify: file path, line number (if available), what needs to change, and why

**Option C — PR number with instructions to fix everything:**
- Given a PR number, fetch all review comments, do a quick assessment, and fix the clearly valid ones
- For ambiguous items, ask first

If a PR number is provided or can be inferred from the current branch, fetch repo info:
```bash
gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
gh pr view --json number,title,url,headRefName 2>/dev/null
```

## Step 2: Plan the Fixes

Before making any changes:

1. **Read each referenced file fully** — understand the surrounding context, not just the flagged line
2. **Group related fixes** — multiple comments on the same file or function should be fixed together
3. **Identify dependencies** — some fixes may affect others (e.g. removing a variable that's used elsewhere)
4. **Plan the order** — fix independent items first, then dependent ones

Present your fix plan:
```markdown
## Fix Plan

### Group 1: {file_path}
- [ ] Fix #1: {description} (line {N})
- [ ] Fix #2: {description} (line {M})

### Group 2: {other_file}
- [ ] Fix #3: {description} (line {N})

Estimated changes: {N} files, {M} edits
```

Ask "Shall I proceed?" if there are more than 3 fixes or if any fix is non-trivial.

## Step 3: Implement Fixes

For each fix:

1. **Read the file** to get the current state
2. **Make the change** — apply the minimum edit needed to address the review feedback
3. **Verify the fix** — ensure the change is correct and doesn't break surrounding code
4. **Note what you changed** for the summary

### Fix guidelines

- **Minimal changes** — fix exactly what was flagged, don't refactor surrounding code
- **Preserve style** — match the existing code style (indentation, naming, patterns)
- **Don't over-engineer** — if the review says "add a null check", add a null check, don't restructure the function
- **Keep suggestions intact** — if the reviewer provided a `suggestion` block, prefer using their exact code
- **Test if possible** — if there are obvious test commands (npm test, make test, etc.), run them after fixes

## Step 4: Resolve GitHub Conversations

After fixes are implemented, resolve the corresponding GitHub conversation threads using the helper script.

### Get thread IDs

If thread IDs weren't provided from a prior `/review-triage` round, fetch them:
```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            path
            line
            comments(first: 1) {
              nodes {
                body
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -f owner='{owner}' -f repo='{repo}' -F pr={pr_number}
```

Match threads to fixed comments by comparing `path`, `line`, and comment `body` content.

### Resolve threads

Use `hack/gh-review-resolve.sh` instead of raw GraphQL mutations — it handles variable encoding correctly (multiline bodies, special characters like em-dashes from bot comments that break inline `gh api graphql` queries).

Resolve a single thread (no reply):
```bash
hack/gh-review-resolve.sh resolve {thread_id}
```

Reply and resolve (e.g. to note what was fixed):
```bash
hack/gh-review-resolve.sh resolve {thread_id} "Fixed — removed debug statement."
```

For multiple threads, use the batch subcommand with a TSV file (thread-id TAB reply-body):
```bash
hack/gh-review-resolve.sh batch resolve-batch.tsv
```

Or pipe from stdin:
```bash
printf '%s\t%s\n' "PRRT_kwDO..." "Fixed in abc123" \
                   "PRRT_kwDO..." "" \
  | hack/gh-review-resolve.sh batch -
```

Threads with no reply body in the TSV are resolved silently.

### Record triage state

After resolving, record the disposition so subsequent `/review-triage` rounds don't resurface these threads:
```bash
hack/review-triage-state.sh mark {pr_number} {thread_id} fix "Brief summary of fix"
```

For threads resolved without a fix (e.g. skipped or deferred):
```bash
hack/review-triage-state.sh mark {pr_number} {thread_id} skip "Not applicable — reason"
```

**Ask before resolving** — confirm with the user before resolving threads, especially if:
- The fix was a judgment call rather than a clear-cut change
- The reviewer was a human (not a bot) who may want to verify the fix
- The comment thread has ongoing discussion

For bot reviewers (augmentcode[bot], coderabbitai[bot], github-actions[bot], copilot, etc.), it's generally safe to resolve after fixing — but still confirm on first use.

## Step 5: Present Summary

After all fixes are applied:

```markdown
## Review Fixes Applied

### Changes Made
| # | File | Fix | Lines Changed |
|---|------|-----|---------------|
| 1 | src/api.ts | Removed console.log | 45 |
| 2 | src/auth.ts | Added null check for user.id | 112-115 |

### Conversations Resolved
| # | File | Thread | Status |
|---|------|--------|--------|
| 1 | src/api.ts | console.log removal | Resolved |
| 2 | src/auth.ts | null check | Resolved |

### Not Resolved (needs human review)
| # | File | Thread | Reason |
|---|------|--------|--------|
| 3 | src/db.ts | SQL injection concern | Architectural decision needed |

### Next Steps
- [ ] Review the changes: `git diff`
- [ ] Run tests: `{test_command}`
- [ ] Commit when satisfied: `/commit`
```

## Step 6: Commit Guidance

Do NOT automatically commit the fixes. Instead, suggest the user review changes and commit when ready.

If the user asks you to commit:
- Group all review fixes into a single commit
- Use a descriptive message like: `fix: address PR review feedback`
- In the commit body, briefly list what was fixed

## Important Notes

- **Read files before editing** — never assume code hasn't changed since the review
- **One concern per fix** — don't bundle unrelated changes
- **Respect reviewer intent** — understand what the reviewer was asking for, not just the literal words
- **Bot vs human reviewers** — bot comments can generally be resolved more freely; human comments deserve more care
- **Don't resolve without fixing** — only resolve threads for comments that have actually been addressed (or confirmed as not applicable by the user)
- **Pagination** — if the PR has many review threads (>100), add pagination to the GraphQL query
