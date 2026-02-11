---
name: handoff
description: Create a token-efficient, self-contained implementation plan for another AI model (smaller-capability) to execute in a separate session. The plan is the only communication channel.
---

# Handoff: Implementation Plan for Another Model

You are creating an **implementation plan** for a smaller-capability model in a **separate session**. The implementer:
- Has **zero conversation context** (can't see your exploration or this chat)
- Works in the **same codebase** (same filesystem)
- Has the **same tools** (Read, Glob, Grep, Edit, Write, Bash)
- Only sees `PLAN.md` — this is your **only communication channel**

Example mapping: a high-capability planner model writes the plan; a smaller-capability implementer model executes it (e.g., Opus -> Haiku).

## Instructions

1. **Targeted exploration**: Focus on critical files only. Use Grep/Glob efficiently. Read what's necessary to understand scope and patterns.

2. **Write the plan** at the project root as `PLAN.md`. If it exists, read it first and ask whether to overwrite or append.

3. **Plan structure** (use exactly these sections):

### 1. Overview
One concise paragraph covering:
- What needs to be done and why
- Tech stack/framework (if relevant)
- High-level approach in 1-2 sentences

### 2. Context Loading (Read These First)
Guide the implementer to load necessary context before starting:
```
Read: path/to/important_file.py
Why: Understand the existing authentication pattern used throughout the project

Read: path/to/config.ts:15-40
Why: See how database connections are configured (you'll follow this pattern)

Grep: "class.*Repository" in src/**/*.py
Why: Find all repository classes to understand the naming convention
```

This section saves tokens by not pasting code — the implementer loads it directly.

### 3. Files to Modify
List in order of modification:
```
CREATE: path/to/new_file.py - Purpose/role
MODIFY: path/to/existing.ts - What aspect changes
DELETE: path/to/old_file.js - Why safe to delete
```

### 4. Implementation Steps
Numbered, atomic steps in execution order. Use **Edit tool format** for efficiency:

**For modifications:**
```
Step N: Edit path/to/file.py
old_string: |
  [exact code to find - minimum unique snippet]
new_string: |
  [exact replacement code - preserve indentation/style]
```

**For new files:**
```
Step N: Write path/to/file.py
[complete file contents - cannot reference what doesn't exist]
```

**For bash commands:**
```
Step N: Bash
$ npm install package-name
(Include expected output only if it affects subsequent steps)
```

**For deletions:**
```
Step N: Delete path/to/file.py
Reason: [why this is safe - e.g., "replaced by new auth system"]
```

### 5. Verification
Exact commands and expected outcomes:
```
$ pytest tests/test_feature.py
Expected: All tests pass, 5 passed in 0.5s

$ npm run build
Expected: Build succeeds with no errors
```

### 6. Critical Notes
- **Don't touch**: Files/patterns that should NOT be modified
- **Edge cases**: Specific scenarios to handle carefully
- **Style**: Project conventions (indentation, naming, imports order)

## Rules

- **Reference, don't paste**: Point to existing code via file paths — the implementer can read it. Only include full contents for new files that don't exist yet.
- **Minimal matchers**: old_string should be the smallest unique snippet, not entire functions.
- **Include what can't be inferred**: Design decisions, the "why" behind the change, and context the implementer wouldn't know from reading code alone.
- **Same language**: Write the plan in the same language as the user's request.
