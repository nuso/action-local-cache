---
description: Generate or optimize a project's CLAUDE.md for context efficiency
---

Help create or optimize a CLAUDE.md file for this repository.

**Goal**: Create a slim, focused CLAUDE.md (~600-1000 words) that follows the on-demand loading pattern for maximum context efficiency.

---

## How I'll work

### Phase 1: Analysis

First, I'll check what already exists:

**Check for existing AI guidance files:**
- `CLAUDE.md` - If present, I'll analyze and optimize it
- `.ai/repo-docs/AGENTS.md` - Auto-generated docs (see note below)
- `.github/copilot-instructions.md` - If present, I'll review for useful context

**Then explore the repository:**
- What this repository is and does (purpose, tech stack)
- Key commands (build, test, lint, deploy)
- Directory structure and organization
- Existing documentation (in `docs/`, README.md, etc.)
- Languages used (for standards directives)

### Phase 2: Create or Optimize

**If no CLAUDE.md exists** → I'll draft a new one from scratch.

**If CLAUDE.md exists** → I'll analyze and suggest improvements:
- Is it too long? (>1000 words = context bloat)
- Does it have the Language Standards directive pattern?
- Is content duplicated that should be in `.ai/standards/`?
- Are there sections that could be moved to `docs/`?

**If `.ai/repo-docs/AGENTS.md` exists** → I'll use it as a reference:
- This is auto-generated documentation that MAY be out of date
- Do NOT link to it from CLAUDE.md - extract useful content instead
- Compare against it to find useful info (entry points, config, dependencies)
- Verify any extracted information is still accurate before including

### Phase 3: Standards Setup

I'll check if `.ai/standards/` exists and recommend:
- Which language standards files to create based on detected languages
- What content to move from CLAUDE.md into standards files
- How to update the standards README with your specific conventions

---

## Target Structure

A well-optimized CLAUDE.md follows this pattern:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Overview

[1-2 sentences: what this repo is, tech stack]

## Language Standards

**IMPORTANT**: Before writing or modifying code, you MUST read the relevant standards:

- **Go code**: `.ai/standards/go.md`
- **TypeScript code**: `.ai/standards/typescript.md`
- **[Language] code**: `.ai/standards/[language].md`
- **All code**: `.ai/standards/general.md`

These files contain prescriptive rules, naming conventions, and required patterns.

## Essential Commands

[Most-used commands: build, test, lint, common workflows]

## Repository Structure

[Key directories and their purpose]

## Quick Reference

[Imports, patterns, common snippets]

## Documentation

- **Standards (normative)**: `.ai/standards/` - prescriptive rules
- **AI-generated docs**: `.ai/repo-docs/` - regenerable documentation
- **Human-facing docs**: `docs/` - detailed explanations
```

---

## Key Principles

**On-demand loading**: Detailed standards go in `.ai/standards/` files, not CLAUDE.md. The root file just points to them with directive language ("MUST read before writing").

**Slim root file**: ~600-1000 words max. Every word in CLAUDE.md loads on every conversation, so keep it focused on what's universally needed.

**Prescriptive standards**: Standards files use MUST/DO NOT language for rules agents can follow mechanically. Explanations and rationale go in `docs/`.

**Directive pattern**: The "Language Standards" section triggers on-demand loading:
```markdown
**IMPORTANT**: Before writing or modifying code, you MUST read the relevant standards:
```

---

## What I Need From You

Tell me:
1. **Create new or optimize existing?** (I'll check what files exist)
2. **Any specific conventions?** - Commit style, testing requirements, deployment patterns
3. **Key commands I should highlight?** - What do developers run most often?

I'll start by checking for existing CLAUDE.md, `.ai/repo-docs/AGENTS.md`, and exploring the repository structure.
