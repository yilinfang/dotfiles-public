---
name: handoff
description: Create a detailed, self-contained implementation plan for another AI model to follow. The plan assumes zero prior context and spells out every change explicitly.
---

# Handoff: Implementation Plan for Another Model

You are creating a **detailed, self-contained implementation plan** that another AI model will follow to complete a task. That model has **zero context** about the current codebase, conversation history, or any prior decisions. It may be less capable than you, so you must be extremely explicit.

## Instructions

1. **Thoroughly explore the codebase first.** Read all relevant files, understand the architecture, conventions, and patterns before writing anything. Use Glob, Grep, and Read tools extensively.

2. **Write the plan to a file** at the project root called `PLAN.md`. If a `PLAN.md` already exists, read it first and ask whether to overwrite or append.

3. **The plan must include ALL of the following sections:**

### Section: Context
- What the project is (language, framework, purpose)
- Relevant architecture and conventions observed in the codebase
- Key dependencies and their versions if relevant

### Section: Task Description
- Exactly what needs to be accomplished, in plain language
- Why this change is needed (if known)
- Expected end-user behavior after the change

### Section: Files Involved
- Every file that needs to be created, modified, or deleted
- For each file: its full path, its current purpose, and what changes are needed
- List files in the order they should be modified

### Section: Step-by-Step Implementation
- Numbered steps, each one a single atomic action
- For modifications: include the **exact code to find** (old) and the **exact code to replace it with** (new), with enough surrounding context to be unambiguous
- For new files: include the **complete file contents**
- For deletions: state the file path and confirm it is safe to delete
- Include exact terminal commands where needed (install dependencies, run migrations, etc.)
- Never say "similar to X" or "follow the pattern" — always spell it out completely

### Section: Verification
- Exact commands to run to verify the implementation works (tests, build, lint, etc.)
- Expected output or behavior for each verification step
- Manual testing steps if applicable

### Section: Pitfalls & Notes
- Common mistakes the implementer might make
- Edge cases to watch out for
- Things that look like they should change but must NOT be changed

## Rules

- **No ambiguity.** If something could be interpreted two ways, pick one and state it explicitly.
- **No assumptions.** Do not assume the implementer knows anything about this project.
- **No shortcuts.** Write out every code change in full. Never use "..." or "etc." in code blocks.
- **Preserve existing style.** Match the codebase's indentation, naming conventions, and patterns exactly.
- **Be surgical.** Only include changes that are necessary for the task. Do not refactor, clean up, or "improve" unrelated code.
- **Use the user's language.** Write the plan in the same natural language the user used to describe the task.
