---
name: clear-conversation
description: Use when the user explicitly invokes $clear-conversation to remove obsolete conversation log entries from the current worktree.
---

# Clear Conversation

Clean up the current worktree's `conversation/` directory.

- Review every conversation file before deciding what to remove.
- Preserve files containing active requirements, acceptance criteria, decisions, context, status, errors, blockers, or workflow instructions.
- Remove only files that no longer serve the current task or workflow, such as greetings, redundant acknowledgements, or unrelated material.
- If unsure whether a file matters, keep it.
- Do not create a normal conversation log for the trigger, cleanup progress, or cleanup result.
- Verify retained files remain and report a concise count or summary when finished.
