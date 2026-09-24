---
name: no-clarify
description: Use when the user explicitly invokes $no-clarify and wants the current request executed directly without explanatory commentary.
---

# No Clarify

Apply this mode only to the current user request.

- Execute the requested work directly instead of explaining a plan first.
- Do not send progress updates, commentary, or reasoning to the user while working.
- Do not ask clarifying questions unless missing information or authority makes safe progress impossible.
- Make reasonable in-scope assumptions and continue through verification.
- Finish with a concise Vietnamese result that states what changed, checks run, and remaining limitations.
- If subagents are used, apply these same rules to every delegated subagent: execute directly, avoid unnecessary clarification, make reasonable in-scope assumptions, verify the result, and finish concisely in Vietnamese. Do not require progress commentary from subagents.
