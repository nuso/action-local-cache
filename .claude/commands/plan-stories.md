---
description: Break a strategy into implementable stories
---

Break a strategy document into numbered, implementable stories.

**Part of the `/plan-*` workflow:**
1. `/plan-explore` - Exploratory research
2. `/plan-strat` - High-level strategy
3. `/plan-stories` - Break into stories (you are here)
4. `/plan-spec` - Detailed spec per story

---

## Input

Tell me:
1. **Which feature?** - The backlog folder name (e.g., `auth-gateway`)

I'll read `.ai/work/{feature}/README.md` for the strategy.

## How I'll work

1. **Read the strategy** - Understand goals, architecture, dependencies
2. **Identify stories** - Break into discrete, implementable pieces
3. **Number and prioritize** - Order by dependencies and logical sequence
4. **Update README** - Add stories section to the strategy doc

## Output

Updates `.ai/work/{feature}/README.md` by adding a Stories section:

```markdown
## Stories

### 01 - {Story title}
{1-2 sentence description of what this accomplishes}
- **Dependencies:** None | {list of story numbers}
- **Scope:** Small | Medium | Large

### 02 - {Story title}
{Description}
- **Dependencies:** 01
- **Scope:** Medium

### 03 - {Story title}
{Description}
- **Dependencies:** 01, 02
- **Scope:** Large
```

## Story Guidelines

**Good stories are:**
- **Independent** - Can be implemented without other incomplete stories (except listed dependencies)
- **Valuable** - Delivers something testable/usable when complete
- **Estimable** - Scope is clear enough to roughly size
- **Small** - Can be completed in a focused session (hours, not days)

**Story format:**
- **Number** - Sequential (01, 02, 03...)
- **Title** - Clear, action-oriented (verb + noun)
- **Description** - What it accomplishes, not how
- **Dependencies** - Which stories must complete first
- **Scope** - Rough size hint (Small/Medium/Large)

## Tips

- Start with foundational pieces (setup, infrastructure)
- Group related changes but keep stories focused
- If a story feels too big, it's probably multiple stories
- Mark parallelizable stories (no dependencies on each other)

## Next step

Run `/plan-spec {feature} {story-number}` to create a detailed spec for a story.
