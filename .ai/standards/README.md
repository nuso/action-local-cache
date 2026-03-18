# AI Standards

This directory contains prescriptive rules that AI agents MUST follow when working in this codebase.

## Purpose

Standards files enable **on-demand context loading**. Rather than bloating `CLAUDE.md` with language-specific rules that load on every conversation, agents read the relevant standards file only when working with that language or domain.

## Current Standards

| File | Scope | Loaded When |
|------|-------|-------------|
<!-- Example: | `general.md` | Cross-language conventions | Writing any code | -->
<!-- Example: | `typescript.md` | TypeScript/JavaScript code | Modifying .ts/.tsx files | -->
<!-- Add rows as you create standards files -->

## What Belongs Here

Standards files contain **prescriptive rules**:
- MUST/MUST NOT statements
- DO/DO NOT directives
- Required patterns and conventions
- Naming rules
- Error handling requirements
- Testing expectations

Example:
```markdown
## Naming

- DO use `camelCase` for function names
- DO NOT use abbreviations in public APIs
- MUST prefix interfaces with `I` only when disambiguation is needed
```

## What Does NOT Belong Here

Keep these in `docs/` instead:
- Detailed explanations of *why* a pattern exists
- Tutorials and walkthroughs
- Architecture rationale
- Historical context
- Extended code examples

Standards reference `docs/` for deep dives:
```markdown
For detailed explanation, see `docs/development/dependency-management.md`.
```

## Adding a New Standards File

When adding a new standards file:

1. **Create the file** in `.ai/standards/` with prescriptive rules
2. **Update CLAUDE.md** - Add a reference in the "Language Standards" section:
   ```markdown
   ## Language Standards

   **IMPORTANT**: Before writing or modifying code, you MUST read the relevant standards:

   - **Go code**: `.ai/standards/go.md`
   - **TypeScript code**: `.ai/standards/typescript.md`
   - **Your new standard**: `.ai/standards/newfile.md`  <!-- ADD THIS -->
   ```
3. **Update this README** - Add entry to the "Current Standards" table above

The CLAUDE.md reference is critical - it triggers on-demand loading.

## Writing Effective Standards

1. **Be prescriptive, not descriptive** - "DO use X" not "X is commonly used"
2. **Be specific** - Concrete patterns, not abstract principles
3. **Be actionable** - Rules an agent can follow mechanically
4. **Keep it focused** - One domain per file
5. **Reference docs for context** - Link to `docs/` for explanations
