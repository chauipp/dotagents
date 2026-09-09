---
name: compacting-conversations
description: Use when the user explicitly asks to compact, condense, summarize-and-replace, or archive old conversation history in the current worktree.
---

# Compacting Conversations

## Overview

Compact preserves useful project memory while replacing an obsolete **continuous** run of raw chat files with one concise summary. A direct user instruction to compact authorizes this exception to verbatim conversation storage.

## Required procedure

1. Work only in `conversation/` of the current worktree. Do not create a nested conversation folder.
2. Select one or more **separate continuous ranges**. Never combine scattered files merely because they share a topic.
3. Read every file in each candidate range. Keep a range intact if any active requirement, decision, blocker, workflow fact, or uncertainty is not recorded in the GDD or a conversation outside the range.
4. Create one replacement file for each eligible range: `<first-timestamp>-compact.md`.
5. State the first and last replaced filenames; summarize the original objective, durable decisions, superseded directions, and the current source of truth. Do not invent missing context.
6. Only after the compact file exists, delete exactly the source files in that range. Preserve files immediately before and after it.
7. Verify the compact files exist, every selected source is absent, unselected files remain, the count is correct, and Markdown has no whitespace errors.

## Authorization and logging

- Compact only after an explicit action request such as “compact conversation”, “tóm tắt và thay thế chat cũ”, or an unambiguous follow-up instruction. “Có compact được không?” is a question, not authorization.
- Do not create normal conversation logs for the compact trigger, interim updates, or cleanup result.
- A compact file is the authorized exception to the rule that a conversation file contains one verbatim user/agent pair.

## Non-negotiable boundaries

- Do not compact by topic across non-contiguous time ranges.
- Do not delete first and plan to summarize later.
- Do not use GDD as an excuse to skip reading the source range.
- If uncertain whether a file matters, retain it.
- Do not modify the GDD while compacting unless the user separately asks.

## Common rationalizations

| Rationalization | Required response |
|---|---|
| “Raw conversation must stay verbatim.” | An explicit compact request authorizes the replacement compact file. |
| “Grouping all old time-related files is faster.” | Only continuous ranges preserve a readable timeline. |
| “The GDD has it, so source review is unnecessary.” | Review every source; GDD may omit workflow facts or rationale. |
| “The user asked whether it is possible.” | Explain the method and wait for an action request. |

## Final report

Report the number of source files replaced, replacement files created, retained file count, and verification result. Do not recreate a conversation log for this report.
