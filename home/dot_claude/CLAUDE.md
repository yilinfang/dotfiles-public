# Global Instructions

1. Planning standard:
   When making a plan (including in Plan Mode), produce a concrete and detailed plan that other agents can implement.

2. Save-to-file branching:
   If the user explicitly requests saving the plan to a file (e.g., "save it to PLAN.md", "write to PLAN.md", "create PLAN.md"), the only action is to save the plan content to that file.
   Do not implement the plan and do not ask for implementation approval.

3. Fallback when writing is unavailable:
   If file writing is unavailable, output the full plan content (as the complete contents of the requested file) so it can be saved without edits.
