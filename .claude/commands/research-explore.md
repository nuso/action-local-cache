---
description: Exploratory research to understand a problem space before committing to a direction
model: opus
---

# Research Explore

Explore and understand a problem space before committing to a strategy. This is lighter than `/research-codebase` - focused on surfacing options, tradeoffs, and unknowns rather than comprehensive documentation.

## OUTPUT DESTINATION
- **NEVER** use Claude Code's built-in plan mode (EnterPlanMode tool)
- **NEVER** write to ~/.claude/plans/ or any Claude-internal directories
- **ALL** exploration output goes to `thoughts/shared/research/` in the current repository (with fallback to `.ai/work/` if thoughts doesn't exist)
- This command creates EXPLORATION DOCUMENTS, not implementation plans

## Mindset

- **Curiosity over conclusions** - I'm gathering, not deciding
- **Questions over answers** - Good exploration surfaces new questions
- **Options over recommendations** - Present what's possible, not what to do
- **Tradeoffs over judgments** - Lay out the considerations, don't hide complexity

## Initial Setup

When this command is invoked, respond with:
```
I'm ready to explore. Tell me:
1. **What are you curious about?** - Problem, opportunity, or question to explore
2. **What triggered this?** - Why now? What prompted the investigation?
3. **Starting points?** - Any files, docs, URLs, or areas to look at first

If continuing exploration, point me to the existing research file.
```

Then wait for the user's input.

## Output Location

Determine output location by checking for thoughts directory:

1. **If `thoughts/shared/` exists**: Write to `thoughts/shared/research/YYYY-MM-DD-explore-{topic}.md`
2. **Fallback**: Write to `.ai/work/{topic}/00-exploration.md`

To check: `test -d thoughts/shared && echo "thoughts" || echo "legacy"`

## Session State Display

After creating the exploration document, **every response** must follow this format:

**At the START of every response:**
```
Exploration: `[EXPLORATION_DOC_PATH]`
```

**At the END of every response:**
```
---
Open Questions:
- [List questions surfaced during exploration; otherwise write "None."]

Would you like to:
1. Keep exploring - [specific thread to pull, e.g., "dig into Option B's tradeoffs"]
2. Add strategy decision: `/research-strat [EXPLORATION_DOC_PATH]`
3. Move to planning: `/plan-create [EXPLORATION_DOC_PATH]` (or `/plan-create-stories` for larger efforts)
```

The "keep exploring" option should be contextual - reference open questions, unexplored threads, or specific follow-up possibilities. This ensures the user always knows what document is active and what their options are.

Rule: The "Open Questions" block must sit immediately above the "Would you like to" options block.

Example:
```
---
Open Questions:
1. Should we consider the self-hosted option given our compliance requirements?
2. What's the team's appetite for maintaining a custom solution?

Would you like to:
1. Keep exploring - research the compliance implications of Option B
2. Add strategy decision: `/research-strat thoughts/shared/research/2026-01-29-explore-auth-providers.md`
3. Move to planning: `/plan-create thoughts/shared/research/2026-01-29-explore-auth-providers.md`
```

## How I'll Work

1. **Start broad** - Search docs, code, and web without assuming what matters
2. **Follow threads** - When something interesting emerges, dig deeper
3. **Surface unknowns** - Identify what we don't know, not just what we do
4. **Check in frequently** - Share findings and ask what direction to explore next
5. **Capture everything** - Document findings even if we're not sure they're relevant yet

## Sub-agents

Use sub-agents for parallel exploration:

**For web research:**
- Spawn web search agents to explore external docs, blog posts, prior art
- Have them return LINKS with findings - include these in the final document

**For light codebase exploration:**
- Use general Task agents to search for relevant patterns or prior implementations
- Keep it exploratory - we're looking for what exists, not comprehensive documentation

**For thoughts directory:**
- Check if similar explorations have been done before
- Look for historical context that might inform this exploration

## Document Template

```markdown
---
date: [ISO timestamp]
researcher: [name]
topic: "[exploration topic]"
tags: [exploration, relevant-tags]
status: in-progress
---

# Exploration: {Topic}

## Context
{What triggered this exploration - the "why now?"}

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

## Dead Ends
{What we explored that didn't pan out - this is valuable too}

## Sources
- [Link to resource 1]
- [Link to resource 2]
- `path/to/relevant/code`

## Next Steps
{More exploration needed? Ready for `/plan-create`?}
```

## Tips

- Don't rush to solutions - sit with ambiguity
- Capture interesting findings even if unclear how they fit
- Document dead ends too - knowing what doesn't work is valuable
- Reference existing patterns and code you discover
- Ask for direction when you hit forks in the road
- Exploration docs can be messy - that's fine
- Web research is encouraged - this is about understanding the landscape

## Follow-up

When continuing exploration:
- Append to the same document
- Update `status` in frontmatter if exploration is complete
- Add new sections for new threads explored

