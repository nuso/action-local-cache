---
description: High-level strategy/architecture planning for a feature or project
---

Create a high-level strategy document for a feature or project.

**Part of the `/plan-*` workflow:**
1. `/plan-explore` - Exploratory research
2. `/plan-strat` - High-level strategy (you are here)
3. `/plan-stories` - Break into implementable stories
4. `/plan-spec` - Detailed spec per story

---

## Input

Tell me:
1. **What are you planning?** - Feature, architecture change, or research topic
2. **Any existing context?** - Docs, PRDs, prior discussions to review

I'll check `.ai/repo-docs/` and standard doc locations for existing documentation.

## How I'll work

1. **Gather context** - Read existing documentation in `.ai/repo-docs/` and `docs/`
2. **Explore the codebase** - Find relevant code, patterns, dependencies
3. **Research** - Identify options, tradeoffs, prior art
4. **Document** - Create strategy doc in `.ai/work/{feature}/`

## Output

`.ai/work/{feature}/README.md` containing:

```markdown
# {Feature} Strategy

## Problem Statement
{What problem are we solving? Why now?}

## Goals
- {Goal 1}
- {Goal 2}

## Architecture Decisions

### Decision 1: {topic}
**Choice:** {what we're doing}
**Rationale:** {why}
**Alternatives considered:** {what else we looked at}

## Key Dependencies
- {Dependency 1} - {why it matters}
- {Dependency 2}

## High-Level Phases

### Phase 1: {name}
{Description of what this phase accomplishes}

### Phase 2: {name}
{Description}

## Open Questions
- {Question 1}
- {Question 2}

## References
- {Link to relevant doc}
- {Link to prior art}
```

## Tips

- Focus on the "why" and "what", not detailed "how"
- Identify blockers and dependencies early
- Note open questions that need answers before implementation
- Reference existing patterns in the codebase

## Next step

When strategy is complete, run `/plan-stories` to break into implementable stories.
