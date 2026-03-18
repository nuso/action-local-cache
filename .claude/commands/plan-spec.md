---
description: Create detailed implementation spec for a story from the backlog
---

Create a detailed implementation specification for a single story.

**Part of the `/plan-*` workflow:**
1. `/plan-explore` - Exploratory research
2. `/plan-strat` - High-level strategy
3. `/plan-stories` - Break into stories
4. `/plan-spec` - Detailed spec per story (you are here)

---

## Input

Tell me:
1. **Which feature?** - The backlog folder name (e.g., `auth-gateway`)
2. **Which story?** - The story number or name (e.g., `01` or `redis-client`)

I'll read `.ai/work/{feature}/README.md` for context.

## How I'll work

1. **Read the README** - Understand overall strategy and story list
2. **Identify the story** - Find the specific story to spec
3. **Explore the codebase** - Find relevant files, patterns, dependencies
4. **Create detailed spec** - Concrete implementation steps
5. **Write spec file(s)** - `.ai/work/{feature}/{nn}-{story}.md`

## Output

`.ai/work/{feature}/{nn}-{story-name}.md` containing:

```markdown
# Story: {Title}

> Implementing story {nn} from [{feature}](./README.md)

## Goal
{What this story accomplishes}

## Context
{Relevant findings from codebase exploration}

## Implementation Steps

### Step 1: {action}
- File: `path/to/file.ts`
- Changes: {description}

### Step 2: {action}
...

## Files to Create/Modify
- `path/to/new/file.ts` - {purpose}
- `path/to/existing/file.ts` - {changes}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}
- [ ] Tests pass
- [ ] No linting errors

## Open Questions
{Any decisions needed during implementation}
```

## Tips

- The spec should be accurate to the **current** codebase, not the high-level plan
- Reference actual file paths and function names
- If the story is too large, suggest breaking it down
- Include test requirements

## Next step

Implement the spec! Use the acceptance criteria to validate completion.
