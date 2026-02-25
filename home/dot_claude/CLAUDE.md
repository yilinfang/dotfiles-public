1. Respond in the same natural language as the input. If the user explicitly requests a specific language, that request takes precedence over this rule.

2. When generating git commit messages, follow the format of previous commits in the repository. If no previous commits exist or the format is inconsistent, use the Conventional Commits specification.

3. If there is a `CLAUDE.md` or `AGENTS.md` in the workspace, read it in full if not already read, and follow it. These files contain important context and instructions for the workspace. Workspace-level instructions take precedence over global defaults when they conflict.
