---
description: Exploratory research to understand a problem space before planning
---

Explore and understand a problem space before committing to a strategy.

**Part of the `/plan-*` workflow:**
1. `/plan-explore` - Exploratory research (you are here)
2. `/plan-strat` - High-level strategy
3. `/plan-stories` - Break into implementable stories
4. `/plan-spec` - Detailed spec per story

---

## Input

Tell me:
1. **What are you curious about?** - Problem, opportunity, or question to explore
2. **What triggered this?** - Why now? What prompted the investigation?
3. **Starting points?** - Any files, docs, or areas to look at first

**If continuing exploration**, point me to the research file.

## How I'll work

1. **Start broad** - Search docs and code without assuming what matters
2. **Follow threads** - When something interesting emerges, dig deeper
3. **Surface unknowns** - Identify what we don't know, not just what we do
4. **Check in frequently** - Share findings and ask what direction to explore next
5. **Capture everything** - Document findings even if we're not sure they're relevant yet

## Mindset

- **Curiosity over conclusions** - I'm gathering, not deciding
- **Questions over answers** - Good exploration surfaces new questions
- **Options over recommendations** - Present what's possible, not what to do
- **Tradeoffs over judgments** - Lay out the considerations, don't hide complexity

## Output

`.ai/work/{feature}/00-research.md` containing:

```markdown
# Research: {Feature}

## Context
{What triggered this exploration}

## Key Findings

### {Theme 1}
{What we learned}

### {Theme 2}
{What we learned}

## Options Discovered
- **Option A:** {description}
- **Option B:** {description}

## Tradeoffs

| Option | Pros | Cons |
|--------|------|------|
| A | ... | ... |
| B | ... | ... |

## Open Questions
- {Question 1}
- {Question 2}

## Recommended Next Steps
{More research needed, or ready for `/plan-strat`?}
```

## Tips

- Don't rush to solutions - sit with ambiguity
- Capture interesting findings even if unclear how they fit
- Document dead ends too - knowing what doesn't work is valuable
- Reference existing patterns and code you discover
- Ask for direction when you hit forks in the road
- Research files can be messy - that's fine

## Next step

When exploration feels complete, run `/plan-strat` to create the strategy doc. The research will inform it.
