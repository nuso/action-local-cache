#!/usr/bin/env bash
set -euo pipefail

# gh-review-resolve.sh — Reply to and/or resolve GitHub PR review threads.
#
# Usage:
#   gh-review-resolve.sh resolve <thread-id>
#   gh-review-resolve.sh resolve <thread-id> "Reply body text"
#   gh-review-resolve.sh reply <thread-id> "Reply body text"
#   gh-review-resolve.sh batch <file>
#
# The batch subcommand reads lines from a file (or stdin with -), where each
# line is: <thread-id> [TAB] [reply body]
# If no reply body is given, the thread is resolved without a reply.
#
# Requires: gh CLI authenticated with repo access.

usage() {
  echo "Usage:"
  echo "  $(basename "$0") resolve <thread-id> [reply]"
  echo "  $(basename "$0") reply   <thread-id> <body>"
  echo "  $(basename "$0") batch   <file|->"
  exit 1
}

reply_to_thread() {
  local tid="$1"
  local body="$2"
  gh api graphql \
    -f query='mutation ReplyThread($tid: ID!, $body: String!) {
      addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $tid, body: $body}) {
        comment { id }
      }
    }' \
    -f tid="$tid" \
    -f body="$body" \
    </dev/null >/dev/null
}

resolve_thread() {
  local tid="$1"
  gh api graphql \
    -f query='mutation ResolveThread($tid: ID!) {
      resolveReviewThread(input: {threadId: $tid}) {
        thread { id isResolved }
      }
    }' \
    -f tid="$tid" \
    </dev/null >/dev/null
}

cmd_resolve() {
  local tid="${1:?thread-id required}"
  local body="${2:-}"

  if [ -n "$body" ]; then
    if ! reply_to_thread "$tid" "$body"; then
      echo "FAILED (reply): $tid" >&2
      return 1
    fi
  fi
  if ! resolve_thread "$tid"; then
    echo "FAILED (resolve): $tid" >&2
    return 1
  fi
  echo "Resolved: $tid"
}

cmd_reply() {
  local tid="${1:?thread-id required}"
  local body="${2:?reply body required}"

  reply_to_thread "$tid" "$body"
  echo "Replied: $tid"
}

cmd_batch() {
  local file="${1:?file or - required}"
  local input

  if [ "$file" = "-" ]; then
    input="/dev/stdin"
  else
    input="$file"
  fi

  local count=0
  local failed=0

  while IFS=$'\t' read -r tid body rest; do  # rest: ignore extra TSV columns
    # Skip blank lines and comments.
    [ -z "$tid" ] && continue
    [[ "$tid" == \#* ]] && continue

    # Guard: thread IDs are alphanumeric GraphQL node IDs (e.g. PRRT_kwDO...).
    # Skip lines where tid looks like body text (contains whitespace),
    # which happens when a body field contains embedded newlines.
    if [[ "$tid" =~ [[:space:]] ]]; then
      echo "SKIPPED (not a thread ID): ${tid:0:60}…" >&2
      continue
    fi

    if cmd_resolve "$tid" "${body:-}"; then
      count=$((count + 1))
    else
      echo "FAILED: $tid" >&2
      failed=$((failed + 1))
    fi
  done < "$input"

  echo "Batch complete: $count resolved, $failed failed"
}

# Main dispatch.
case "${1:-}" in
  resolve) shift; cmd_resolve "$@" ;;
  reply)   shift; cmd_reply "$@" ;;
  batch)   shift; cmd_batch "$@" ;;
  *)       usage ;;
esac
