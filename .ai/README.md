# .ai/ Directory

This directory contains AI-related artifacts for working with AI coding assistants like Claude Code.

## Directory Structure

```
.ai/
├── standards/     # Coding standards and conventions (prescriptive rules)
├── work/          # Planning artifacts and work-in-progress (ephemeral)
└── repo-docs/     # AI-generated documentation (regenerable)
```

## Subdirectories

### standards/

Contains normative coding standards that AI agents MUST follow when writing code. These are prescriptive rules using MUST/DO NOT language.

- `general.md` - Cross-language conventions
- Language-specific files (e.g., `go.md`, `typescript.md`, `python.md`)

Referenced from CLAUDE.md via directives like "Before writing Go code, read `.ai/standards/go.md`".

See [standards/README.md](./standards/README.md) for details on adding new standards.

### work/

Ephemeral workspace for planning artifacts created by `/plan-*` commands:

- Feature strategies and implementation plans
- Story breakdowns and specifications
- Research notes

Contents are work-in-progress and may be deleted after implementation.

### repo-docs/

AI-generated documentation about the repository. Created by automation and regenerable - do not hand-edit.

- `SUMMARY.md` - High-level repository overview
- `metadata.json` - Structured repository metadata

## Design Rationale

**Context Efficiency**: Standards are loaded on-demand via CLAUDE.md directives, keeping the root prompt slim.

**Separation of Concerns**:
- Normative (standards/) vs descriptive (repo-docs/) vs ephemeral (work/)
- Each has different lifecycles and ownership

**Maintainability**: Clear boundaries make it obvious where content belongs.

**Portability**: Consistent `.ai/` structure across repositories enables shared tooling.
