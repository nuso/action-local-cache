# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A GitHub Action that saves and restores files across job runs using the runner's local filesystem (not GitHub's cache service). Designed for self-hosted runners with persistent storage.

## Commands

- `npm run all` — format, lint, typecheck, build, and test (the full CI check)
- `npm run pack` — build with tsup (outputs `dist/main.js` and `dist/post.js`)
- `npm test` — run Jest tests
- `npm run lint` — ESLint
- `npm run typecheck` — tsc
- `npm run format` — Prettier

**Important:** After changing source code, run `npm run pack` to rebuild `dist/`. The built files in `dist/` are committed to the repo because GitHub Actions loads them directly.

## Architecture

This is a two-phase GitHub Action (main + post):

- **`src/main.ts`** — Runs at step start. Restores cached files from `$RUNNER_TOOL_CACHE` to the workspace. Sets `cache-hit` output.
- **`src/post.ts`** — Runs after job success (`post-if: success()`). Saves workspace files back to the cache location.
- **`src/lib/getVars.ts`** — Shared config: reads action inputs (`path`, `key`, `strategy`) and computes cache/target paths. Cache is stored at `$RUNNER_TOOL_CACHE/<repo>/<key>/<path>`.
- **`action.yml`** — Action definition, declares inputs/outputs and points to `dist/main.js` / `dist/post.js`.

### Caching Strategies

Three strategies controlled by the `strategy` input (default: `move`):

- **`move`** — Uses filesystem move (instant, same-disk only)
- **`copy`** — Recursive copy, refreshes cache each run (works cross-disk)
- **`copy-immutable`** — Copies once, never updates (fastest for static content like `node_modules`)

## CI

The push workflow (`.github/workflows/push.yaml`) runs `npm run all` plus integration tests for each strategy on a `local-action-cache` runner group.
