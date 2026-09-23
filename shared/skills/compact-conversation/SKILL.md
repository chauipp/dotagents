---
name: compact-conversation
description: Use when the user explicitly invokes $compact-conversation to condense a contiguous range of conversation logs in the current worktree.
---

# Compact Conversation

Replace obsolete contiguous conversation-log ranges with compact summaries while preserving durable project memory.

- Work only in the current worktree's `conversation/` directory.
- Select only contiguous ranges; never merge scattered files by topic.
- Read every source file in each selected range before summarizing.
- Preserve active requirements, decisions, blockers, workflow facts, and the current source of truth.
- Create each replacement compact file before deleting its source files.
- State the first and last replaced filenames and summarize the objective, durable decisions, superseded directions, and current source of truth.
- Delete exactly the selected source files; keep adjacent or unselected files.
- Verify each replacement exists, selected sources are absent, and unselected files remain.
- Do not create a normal conversation log for the trigger, progress, or compact result.
