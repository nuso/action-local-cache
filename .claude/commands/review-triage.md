---
description: Triage PR review comments - fetch, assess applicability, and plan fixes
---

# Triage PR Review Comments

You are tasked with fetching and triaging code review comments from a pull request, determining which are applicable, and creating a plan to address the valid ones.

## Step 0: Check Prior Triage State

If the user provided a PR number, check whether previous triage rounds have been recorded:
```bash
hack/review-triage-state.sh list {pr_number}
```

If state exists, show a brief summary (e.g. "Prior round: 8 threads triaged — 4 fix, 2 skip, 2 resolved") so the user knows what's already been handled. New threads will be filtered automatically in Step 2.

If no state exists, this is the first round — proceed normally.

## Step 1: Determine Input Source

The user will provide review comments in one of these ways:

**Option A — PR number** (e.g. `/review-triage 2902`):
- Fetch comments directly from GitHub using the gh CLI
- Continue to Step 2

**Option B — Pasted comments** (user pastes text from email or GitHub):
- Parse the pasted text to extract individual comments
- For each comment, identify: file path, line number (if available), and the feedback text
- Skip to Step 3

If no input is provided, check if the current branch has an associated PR:
```bash
gh pr view --json number,title,url 2>/dev/null
```
If found, ask the user if they want to triage comments for that PR.

## Step 2: Fetch PR Review Comments

Get repository info:
```bash
gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
```

Fetch review threads and their comments via GraphQL (preferred — gives us thread IDs needed for resolution later):
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
            comments(first: 10) {
              nodes {
                id
                body
                author { login }
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -f owner='{owner}' -f repo='{repo}' -F pr={pr_number}
```

This returns thread IDs (format `PRRT_kwDO...`) alongside comments, which we'll need for resolving threads later. Each thread's first comment is the root review point; subsequent comments are replies.

If the GraphQL query fails or for additional context like `diff_hunk`, supplement with the REST API:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate \
  --jq '.[] | {
    id: .id,
    path: .path,
    line: .line,
    original_line: .original_line,
    diff_hunk: .diff_hunk,
    body: .body,
    author: .user.login,
    html_url: .html_url,
    in_reply_to_id: .in_reply_to_id,
    created_at: .created_at
  }'
```

Also fetch top-level review summaries for context:
```bash
gh pr view {pr_number} --json reviews \
  --jq '.reviews[] | {author: .author.login, state: .state, body: .body}'
```

**Important:** The REST API has no concept of review threads or resolution status. Thread resolution is exclusively a GraphQL feature. Always use the GraphQL query above as the primary data source so you have thread IDs available.

### Filtering already-triaged threads

After collecting unresolved thread IDs from the GraphQL response, filter out threads that were triaged in prior rounds:
```bash
hack/review-triage-state.sh new {pr_number} {thread_id_1} {thread_id_2} ...
```

This prints only thread IDs **not** already in the state file. Use the filtered list for the rest of the triage — this prevents stale threads from reappearing across rounds. If the filtered list is empty, inform the user that all unresolved threads have already been triaged.

### Cleaning up bot noise

Bot comments (Augment, CodeRabbit, Copilot, etc.) embed noise: badge images, URL-encoded prompts, HTML tags, reaction prompts. When processing comment bodies:
- Extract the actual feedback text (usually the first paragraph(s) before any `[![` badge or `<sub>` footer)
- Preserve any severity indicators (e.g. `severity: warning`, `critical`, `suggestion`)
- Strip out "Fix in Augment/CodeRabbit" action links
- Keep code suggestions (```suggestion blocks) intact as they contain the proposed fix

### Grouping threaded comments

Comments with `in_reply_to_id` are replies in a conversation thread. Group them together — only the root comment (no `in_reply_to_id`) represents a distinct review point. Replies may contain additional context or the author's response.

## Step 3: Triage Each Comment

For each distinct comment/review point:

1. **Read the referenced file** at the mentioned line to understand the current state of the code
2. **Compare against the diff_hunk** to determine if the code has changed since the comment was made
3. **Assess applicability** — categorize as one of:
   - **Fix** — Valid issue with a clear remediation (e.g. remove console.log, add null check, fix typo)
   - **Consider** — Valid concern that needs human judgment (e.g. security implications, architectural questions)
   - **Skip** — Not applicable (e.g. code already changed, false positive, stylistic preference with no project convention)
   - **Resolved** — The issue has already been addressed in a subsequent commit

4. **For each comment, note:**
   - The file and line reference
   - A brief summary of the feedback
   - Your assessment (Fix/Consider/Skip/Resolved) with reasoning
   - For "Fix" items: what the fix would be

5. **Record the triage decision** so subsequent rounds skip this thread:
   ```bash
   hack/review-triage-state.sh mark {pr_number} {thread_id} {disposition} "Brief summary"
   ```
   Where `{disposition}` is one of: `fix`, `skip`, `consider`, `resolved`, `deferred`. Do this for every thread assessed in this round.

### Triage guidelines

Comments that should typically be **Fixed**:
- Leftover `console.log` / debug statements
- Missing null/undefined handling
- Duplicate or shadowed variable names
- Security issues with clear remediation
- Incorrect error messages or typos in user-facing strings
- Missing cleanup (event listeners, subscriptions, temp files)

Comments that should typically be **Considered** (need human input):
- Security concerns requiring architectural decisions
- Performance suggestions with unclear trade-offs
- "Should this be..." questions about design intent
- Suggestions that would change public API surface

Comments that should typically be **Skipped**:
- Stale comments on lines that have since been modified
- Pure formatting/style comments when the project has no strong convention
- Bot false positives or low-confidence suggestions
- Comments that are questions with no actionable fix

## Step 4: Present Triage Summary

Present a clear summary organized by assessment:

```markdown
## PR Review Triage: #{pr_number}

### Fix (N comments) — Ready to implement
| # | File | Line | Issue | Proposed Fix |
|---|------|------|-------|-------------|
| 1 | src/api.ts | 45 | Leftover console.log | Remove debug statement |
| 2 | src/auth.ts | 112 | Missing null check | Add guard clause |

### Consider (N comments) — Needs your input
| # | File | Line | Issue | Question |
|---|------|------|-------|----------|
| 3 | src/db.ts | 78 | SQL injection concern | Should we use parameterized queries here? |

### Skip (N comments) — Not applicable
| # | File | Line | Issue | Reason |
|---|------|------|-------|--------|
| 4 | src/old.ts | 22 | Style suggestion | Code already refactored in later commit |

### Resolved (N comments) — Already addressed
| # | File | Line | Issue | How |
|---|------|------|-------|-----|
| 5 | src/util.ts | 10 | Missing return type | Added in commit abc123 |
```

## Step 5: Get User Approval

Ask the user:
1. Which "Fix" items should be implemented? (default: all)
2. For "Consider" items: get a decision on each
3. Whether to resolve GitHub conversation threads for "Skip" and "Resolved" items

## Step 6: Resolve Skipped/Resolved Conversations

For comments the user confirms as Skip or Resolved, offer to resolve their GitHub conversation threads.

Thread IDs (format `PRRT_kwDO...`) were already fetched in Step 2 via the GraphQL query. Each thread's `id` field is the thread node ID needed for resolution.

If Step 2 was done via pasted text (Option B) and you need thread IDs now, fetch them:
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

Match threads to triaged comments by comparing `path`, `line`, and comment `body` content.

### Resolving threads

Use `gh-review-resolve.sh` instead of raw GraphQL mutations — it handles variable encoding correctly (multiline bodies, special characters like em-dashes from bot comments that break inline `gh api graphql` queries).

Resolve a single thread (no reply):
```bash
hack/gh-review-resolve.sh resolve {thread_id}
```

Reply and resolve:
```bash
hack/gh-review-resolve.sh resolve {thread_id} "Fixed in latest commit."
```

Reply without resolving (e.g. for "Consider" items where you want to leave context):
```bash
hack/gh-review-resolve.sh reply {thread_id} "Flagged for review — see triage summary."
```

For multiple threads, use the batch subcommand with a TSV file (thread-id TAB reply-body):
```bash
hack/gh-review-resolve.sh batch resolve-batch.tsv
```

Or pipe from stdin:
```bash
printf '%s\t%s\n' "PRRT_kwDO..." "Not applicable — code refactored" \
                   "PRRT_kwDO..." "Already fixed in abc123" \
  | hack/gh-review-resolve.sh batch -
```

Threads with no reply body in the TSV are resolved silently.

## Step 7: Hand Off to Fix

For approved "Fix" items, present a summary of what will be fixed and suggest:
- Running `/review-fix` with the list of approved comments
- Or implementing the fixes directly in this session

If implementing directly:
- Work through fixes one at a time
- After each fix, show what changed
- After all fixes, resolve the corresponding GitHub conversation threads (if user approved in Step 5)

## Important Notes

- **Always read the actual file** before assessing a comment — don't rely solely on the diff_hunk
- **Group related comments** — multiple comments on the same file/function may be related
- **Respect human judgment** — when in doubt, categorize as "Consider" rather than "Skip"
- **Preserve conversation context** — if a thread has replies with additional context, include that in your assessment
- **Don't auto-resolve without approval** — always confirm before resolving GitHub threads
- **Clean up state when done** — after the PR is merged or closed, run `hack/review-triage-state.sh clean {pr_number}` to remove the local triage state. The `.review-triage/` directory is auto-gitignored but accumulates across PRs
