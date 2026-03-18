#!/usr/bin/env bash
set -euo pipefail

# review-triage-state.sh — Track triaged PR review threads across rounds.
#
# Maintains a local state file so that `/review-triage` can distinguish
# threads already triaged from genuinely new ones across multiple rounds.
#
# State file location: .review-triage/<pr-number>.tsv
# Format: <thread-id> TAB <disposition> TAB <timestamp> TAB <summary>
#
# Usage:
#   review-triage-state.sh mark <pr> <thread-id> <disposition> [summary]
#   review-triage-state.sh list <pr>
#   review-triage-state.sh ids  <pr>
#   review-triage-state.sh new  <pr> <thread-id> ...
#   review-triage-state.sh clean <pr>
#
# Dispositions: fix, skip, consider, resolved, deferred
#
# The `new` subcommand filters a list of thread IDs, printing only those
# NOT already in the state file. Pipe the output of a GraphQL fetch through
# this to get only untriaged threads.

STATE_DIR=".review-triage"

usage() {
  echo "Usage:"
  echo "  $(basename "$0") mark  <pr> <thread-id> <disposition> [summary]"
  echo "  $(basename "$0") list  <pr>"
  echo "  $(basename "$0") ids   <pr>"
  echo "  $(basename "$0") new   <pr> <thread-id> ..."
  echo "  $(basename "$0") clean <pr>"
  exit 1
}

state_file() {
  local pr="$1"
  echo "${STATE_DIR}/${pr}.tsv"
}

ensure_dir() {
  mkdir -p "$STATE_DIR"
}

cmd_mark() {
  local pr="${1:?pr number required}"
  local tid="${2:?thread-id required}"
  local disposition="${3:?disposition required}"
  local summary="${4:-}"

  case "$disposition" in
    fix|skip|consider|resolved|deferred) ;;
    *) echo "Invalid disposition: $disposition (expected: fix, skip, consider, resolved, deferred)" >&2; exit 1 ;;
  esac

  local ts
  ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

  ensure_dir
  local file
  file=$(state_file "$pr")

  # Remove existing entry for this thread (update case).
  if [ -f "$file" ]; then
    awk -F'\t' -v id="$tid" '$1 != id' "$file" > "${file}.tmp" 2>/dev/null || true
    mv "${file}.tmp" "$file"
  fi

  printf '%s\t%s\t%s\t%s\n' "$tid" "$disposition" "$ts" "$summary" >> "$file"
  echo "Marked: $tid as $disposition"
}

cmd_list() {
  local pr="${1:?pr number required}"
  local file
  file=$(state_file "$pr")

  if [ ! -f "$file" ]; then
    echo "No triage state for PR #${pr}"
    return
  fi

  printf '%-45s  %-10s  %-20s  %s\n' "Thread ID" "Status" "Triaged At" "Summary"
  printf '%s\n' "$(printf '%.0s-' {1..100})"
  while IFS=$'\t' read -r tid disposition ts summary; do
    printf '%-45s  %-10s  %-20s  %s\n' \
      "$tid" "$disposition" "$ts" "$summary"
  done < "$file"
}

cmd_ids() {
  local pr="${1:?pr number required}"
  local file
  file=$(state_file "$pr")

  if [ ! -f "$file" ]; then
    return
  fi

  cut -f1 "$file"
}

cmd_new() {
  local pr="${1:?pr number required}"
  shift

  local file
  file=$(state_file "$pr")

  # If no state file, everything is new.
  if [ ! -f "$file" ]; then
    printf '%s\n' "$@"
    return
  fi

  # Single grep pass: print IDs not already in state file.
  printf '%s\n' "$@" | grep -vxFf <(cut -f1 "$file") || true
}

cmd_clean() {
  local pr="${1:?pr number required}"
  local file
  file=$(state_file "$pr")

  if [ -f "$file" ]; then
    rm "$file"
    echo "Cleaned triage state for PR #${pr}"
  else
    echo "No state to clean for PR #${pr}"
  fi
}

# Main dispatch.
case "${1:-}" in
  mark)  shift; cmd_mark "$@" ;;
  list)  shift; cmd_list "$@" ;;
  ids)   shift; cmd_ids "$@" ;;
  new)   shift; cmd_new "$@" ;;
  clean) shift; cmd_clean "$@" ;;
  *)     usage ;;
esac
