---
name: ch-learn-english
description: Use when the user explicitly invokes $ch-learn-english on, off or status, or when a trusted per-chat hook confirms English learning is enabled in the current chat.
agents: codex
---

# Learn English while working

English learning is opt-in per chat. The personal known-item dictionary is shared across projects on this machine. Read [the response contract](references/response-contract.md) completely before responding in enabled mode.

| Invocation | Result |
|---|---|
| `$ch-learn-english on` | Enable only this chat |
| `$ch-learn-english off` | Disable only this chat; keep learned data |
| `$ch-learn-english status` or bare skill | Report current status without changing it |

## State and control

The installed UserPromptSubmit hook handles standalone commands and injects current state each turn. For commands, use its control result; do not toggle twice. If no hook result is available, use `python3 <this-skill>/scripts/english_state.py status` to inspect the current chat and `set on` / `set off` to handle explicit commands. The helper obtains the ID from CODEX_THREAD_ID or CODEX_SESSION_ID. If no stable ID is available, explain the limitation; never substitute a project/branch or invent an ID. Without the trusted hook, report that persistence is stored but automatic application each turn is unverified. A mention quoted in prose does not activate the mode.

When off, use the usual language preference. When on, follow the response contract: corrected request first when needed, English work response with Vietnamese annotations, then grammar explanations. Hook-supplied language mode overrides the kit's default Vietnamese preference.

## Remembering known items

Call the helper after an explicit learned confirmation:

```text
python3 <this-skill>/scripts/english_state.py learn words asset --forms assets
python3 <this-skill>/scripts/english_state.py learn phrases 'carry out'
python3 <this-skill>/scripts/english_state.py learn grammar second-conditional --label 'Câu điều kiện loại 2' --pattern 'If + past simple, would + verb'
```

Resolve `<this-skill>` to this SKILL.md's actual directory and quote paths/terms safely. Use `lookup words asset assets`, `lookup phrases 'carry out'`, or `lookup grammar second-conditional` to check; `list` reads the full dictionary. `forget KIND TERM` removes a mistaken canonical entry so it is explained again. Never say 'saved' after a permission or write failure.

Default storage: `${XDG_STATE_HOME:-~/.local/state}/dotagents/ch-learn-english/knowledge.json` plus `sessions/<chat-id>.json`. `DOTAGENTS_ENGLISH_STATE_DIR` selects a different absolute location. Writes are locked and atomic. Updates and uninstall preserve this data. State is local to this machine; there is no automatic cross-machine sync.

## Common mistakes

- Reading 'known words' as 'known phrases': the groups are independent.
- Guessing that basic words are known: only explicit entries suppress annotations.
- Remembering a stale dictionary: read hook data or current helper lookups every turn.
- Truncating a large dictionary: use lookup batches, not an incomplete list.
- Re-explaining grammar under another ID: match existing labels/patterns; `catalog grammar --offset 0 --limit 50` returns canonical metadata, revision and next_offset. Pass `--revision HASH` on later pages, restarting at offset 0 if another chat changes the catalog.
- Injecting translations into code: preserve runnable text and annotate prose.
