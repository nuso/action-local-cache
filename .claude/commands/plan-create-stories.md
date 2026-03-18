---
description: Create story-focused implementation plan (higher level than plan-create)
model: opus
---

# Story-Focused Implementation Plan

Create an implementation plan focused on **stories** (work breakdown) rather than code-level details. Use this for larger efforts where you need to break work into discrete, implementable chunks before diving into code specifics.

## When to Use This vs `/plan-create`

| Use `/plan-create-stories` when | Use `/plan-create` when |
|--------------------------------|------------------------|
| Large feature spanning multiple sessions | Single-session implementation |
| Need to parallelize work across people/agents | One person implementing sequentially |
| Want to track progress at story level | Want step-by-step code guidance |
| Architecture decisions made, need work breakdown | Need to figure out the code approach |

## OUTPUT DESTINATION
- **NEVER** use Claude Code's built-in plan mode (EnterPlanMode tool)
- **NEVER** write to ~/.claude/plans/ or any Claude-internal directories
- **ALL** output goes to `thoughts/shared/plans/` in the current repository
- Creates a STORIES PLAN, not a code-level implementation plan

## Initial Setup

When this command is invoked:

1. **Check if parameters were provided**:
   - If a research doc path was provided, read it FULLY
   - If no parameters, prompt for input

2. **If no parameters provided**, respond with:
```
I'll help you create a story-focused implementation plan.

Please provide:
1. The research/exploration document (e.g., `thoughts/shared/research/2026-01-29-explore-feature.md`)
2. Or describe the feature/project to break into stories

I'll analyze the scope and create a plan with discrete, implementable stories.
```

Then wait for the user's input.

## Session State Display

After creating the plan document, **every response** must follow this format:

**At the START of every response:**
```
Plan Document: `[PLAN_DOC_PATH]`
```

**At the END of every response:**
```
---
Open Questions:
- [List questions; otherwise write "None."]

Would you like to:
1. Keep iterating - [specific suggestion, e.g., "break Story 03 into smaller pieces"]
2. Start implementing: `/plan-create Story 01 from [PLAN_DOC_PATH]`
```

## Process Steps

### Step 1: Context Gathering

1. **Read all mentioned files FULLY**
2. **If research doc provided**, extract:
   - Strategy Decision (if present)
   - Options chosen
   - Constraints identified
   - Success criteria

3. **Spawn research tasks** to understand scope:
   - Use **codebase-locator** to find affected areas
   - Use **codebase-analyzer** to understand current patterns
   - Use **thoughts-locator** for related prior work

### Step 2: Identify Story Boundaries

Good stories are:
- **Independent** - Can be implemented without other incomplete stories (except dependencies)
- **Valuable** - Delivers something testable when complete
- **Estimable** - Scope is clear enough to roughly size
- **Small** - Can be completed in a focused session (hours, not days)

Present initial breakdown:
```
Based on the research, I propose breaking this into {N} stories:

1. **{Story title}** - {what it accomplishes}
   - Scope: Small/Medium/Large
   - Dependencies: None

2. **{Story title}** - {what it accomplishes}
   - Scope: Medium
   - Dependencies: Story 1

...

Does this breakdown make sense? Any stories feel too big or too small?
```

### Step 3: Write the Plan

After alignment on structure, write to `thoughts/shared/plans/YYYY-MM-DD-{topic}-stories.md`:

```markdown
---
date: [ISO timestamp]
author: [name]
topic: "[feature/project name]"
type: stories
tags: [plan, stories, relevant-tags]
status: ready
source_research: [path to research doc if any]
---

# {Feature} - Story Plan

## Overview

{2-3 sentence description of what we're building and why}

## Source

- Research: `{research_doc_path}` (if applicable)
- Strategy Decision: {brief summary of chosen approach}

## Stories

### Story 01: {Title}

**Goal**: {What this story accomplishes - one sentence}

**Scope**: Small | Medium | Large

**Dependencies**: None | Story {nn}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] Tests pass

**Key Files** (likely to touch):
- `path/to/file1.ext`
- `path/to/file2.ext`

**Notes**: {Any specific considerations, gotchas, or approach hints}

---

### Story 02: {Title}

**Goal**: {What this story accomplishes}

**Scope**: Medium

**Dependencies**: Story 01

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}

**Key Files**:
- `path/to/file.ext`

---

[Additional stories...]

---

## Parallelization

Stories that can run in parallel (no dependencies on each other):
- Stories 01 and 02 (if applicable)
- Stories 04 and 05 (if applicable)

## What We're NOT Doing

{Explicitly list out-of-scope items}

## Implementation Order

Recommended sequence:
1. Story 01 - {reason it's first}
2. Story 02 - {blocked by 01}
3. ...

## Success Criteria (Overall)

When all stories are complete:
- [ ] {End-to-end criterion 1}
- [ ] {End-to-end criterion 2}
- [ ] {Integration test passes}

## References

- Research: `{path}`
- Similar implementation: `{path:line}`
- Related ticket: `{ticket_ref}`
```

### Step 4: Sync and Review

1. Run `humanlayer thoughts sync`
2. Present the plan for review
3. Iterate on story boundaries, scope estimates, dependencies

## Story Sizing Guidelines

| Size | Description | Session Estimate |
|------|-------------|------------------|
| **Small** | Single file, clear change | 1-2 hours |
| **Medium** | Multiple files, some complexity | Half day |
| **Large** | Many files, significant logic | Full day |

If a story is larger than "Large", break it into smaller stories.

## Dependency Tracking

**Explicit dependencies only** - list only stories that MUST complete first:
- Don't list transitive dependencies (if 03 depends on 02, and 02 depends on 01, story 03 only lists "02")
- Stories with no dependencies can run in parallel

## Important Guidelines

1. **Stay at Story Level**
   - Don't write code snippets
   - Don't specify implementation details
   - Focus on "what" not "how"

2. **Keep Stories Atomic**
   - Each story should be mergeable independently
   - Avoid stories that leave the codebase in a broken state

3. **Include Acceptance Criteria**
   - Every story needs testable criteria
   - "It works" is not a criterion

4. **Identify Key Files**
   - Help future implementers know where to look
   - Use codebase-locator to find these

## Transitioning to Implementation

When ready to implement a story, invoke `/plan-create` and reference the story:

```
/plan-create Story 01 from thoughts/shared/plans/2026-01-29-feature-stories.md
```

Or:
```
/plan-create implement the "Add authentication middleware" story from thoughts/shared/plans/2026-01-29-auth-stories.md
```

The `/plan-create` command will read the story plan, find the referenced story, and create a detailed code-level implementation plan for it.
