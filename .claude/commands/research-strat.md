---
description: Add strategy decision to exploration document
model: opus
---

# Research Strategy

Take an exploration document and add a strategic decision section. This command **appends** to the exploration document rather than creating a new file - the document evolves from exploration to strategy.

## OUTPUT DESTINATION
- **NEVER** use Claude Code's built-in plan mode (EnterPlanMode tool)
- **NEVER** write to ~/.claude/plans/ or any Claude-internal directories
- **APPENDS** to an existing exploration document in `thoughts/shared/research/`
- This command adds a STRATEGY DECISION section, not an implementation plan

## When to Use This

After `/research-explore` when:
- Options have been identified with clear tradeoffs
- You're ready to **decide** on an approach (not just explore)
- You want to document the "why" before diving into implementation details

If you still have technical unknowns ("how does X work?"), run `/research-codebase` first.

## Initial Setup

When this command is invoked:

1. **Check if a document path was provided**:
   - If yes, read that exploration document FULLY
   - If no, check for recent exploration docs in `thoughts/shared/research/`

2. **If no parameters provided**, respond with:
```
I'll help you add a strategy decision to your exploration.

Please provide:
1. The exploration document path (e.g., `thoughts/shared/research/2026-01-29-explore-auth.md`)
2. Or tell me which exploration to continue

I'll review the options and tradeoffs, then help you document the strategic decision.
```

Then wait for the user's input.

## Session State Display

After identifying the exploration document, **every response** must follow this format:

**At the START of every response:**
```
Research Document: `[EXPLORATION_DOC_PATH]`
```

**At the END of every response:**
```
---
Open Questions:
- [List questions that need answering before finalizing strategy; otherwise write "None."]

Would you like to:
1. Keep refining - [specific aspect to clarify]
2. Move to planning: `/plan-create [EXPLORATION_DOC_PATH]` (code-level) or `/plan-create-stories [EXPLORATION_DOC_PATH]` (story breakdown)
```

## Process Steps

### Step 1: Read and Analyze Exploration

1. **Read the exploration document FULLY**
2. **Identify key sections**:
   - Options Discovered
   - Tradeoffs
   - Open Questions
3. **Summarize the decision space**:
   ```
   Based on your exploration, I see these options:

   **Option A: {name}**
   - Pros: {from tradeoffs}
   - Cons: {from tradeoffs}

   **Option B: {name}**
   - Pros: {from tradeoffs}
   - Cons: {from tradeoffs}

   Open questions that might affect the decision:
   - {question 1}
   - {question 2}

   What's your inclination? Or should we discuss any of these tradeoffs further?
   ```

### Step 2: Clarify and Decide

1. **Ask targeted questions** about:
   - Constraints that favor one option
   - Risk tolerance
   - Timeline considerations
   - Team preferences

2. **Don't rush the decision** - this is the "why" that will guide implementation

3. **Confirm the decision**:
   ```
   So we're going with **Option {X}** because:
   - {reason 1}
   - {reason 2}

   And we're explicitly NOT doing {alternatives} because {rationale}.

   Does that capture it correctly?
   ```

### Step 3: Append Strategy Section

Once the decision is confirmed, **append** to the exploration document:

```markdown

---

## Strategy Decision

**Date**: {current date}
**Decision**: {chosen approach in one sentence}

### What We're Doing

{2-3 sentence description of the chosen approach}

### Why This Approach

- {Reason 1 - tied to tradeoffs above}
- {Reason 2}
- {Reason 3}

### What We're NOT Doing

- **{Alternative A}**: {why not - brief}
- **{Alternative B}**: {why not - brief}

### Key Constraints

- {Constraint 1}
- {Constraint 2}

### Success Looks Like

{High-level description of what success means - business/product level, not implementation details}

### Dependencies and Risks

- **Dependency**: {what we need before/during implementation}
- **Risk**: {what could go wrong and mitigation}

---

## Next Steps

Ready for implementation planning:
- `/plan-create {this_doc_path}` - Code-level implementation plan
- `/plan-create-stories {this_doc_path}` - Story breakdown for larger efforts
```

### Step 4: Update Frontmatter

Update the document's frontmatter:

```yaml
---
date: [original date]
researcher: [original]
topic: "[original topic]"
tags: [exploration, strategy, relevant-tags]  # add 'strategy' tag
status: strategy-complete  # update from 'in-progress'
strategy_date: [current date]
strategy_by: [who made the decision]
---
```

### Step 5: Sync

Run `humanlayer thoughts sync` to sync the updated document.

## Important Guidelines

1. **Don't Skip to Implementation**
   - This is about the strategic "why", not the tactical "how"
   - If you find yourself writing code snippets, stop - that's for `/plan-create`

2. **Document Alternatives**
   - The "What We're NOT Doing" section is crucial
   - Future readers need to know why alternatives were rejected

3. **Be Concise**
   - Strategy section should be scannable
   - Details belong in the exploration sections above

4. **Validate Before Appending**
   - Confirm the decision with the user before writing
   - Once appended, the document represents a committed direction

## Example Flow

```
User: /research-strat thoughts/shared/research/2026-01-29-explore-auth.md

Assistant: [Reads exploration doc, summarizes options]

Based on your exploration, I see two main options:
1. **Auth0** - managed, more expensive, faster to implement
2. **Keycloak** - self-hosted, more control, more maintenance

Which direction are you leaning?

User: Auth0 - we dont have time to manage infrastructure

Assistant: [Confirms decision, appends Strategy Decision section to the exploration doc]
```
