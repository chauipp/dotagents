---
name: ch-learn-english
description: Use when the user explicitly invokes $ch-learn-english on, off, status or sync, or when a trusted per-chat hook confirms English learning is enabled in the current chat.
agents: codex
---

# Learn English while working

English learning is opt-in per chat. The personal known-item dictionary is shared across projects on this machine. Read [the response contract](references/response-contract.md) completely before responding in enabled mode.

| Invocation | Result |
|---|---|
| `$ch-learn-english on` | Enable only this chat |
| `$ch-learn-english off` | Disable only this chat; keep learned data |
| `$ch-learn-english status` or bare skill | Report current status without changing it |
| `$ch-learn-english sync` | Agent commits and merges the Git learning profile locally |
| `$ch-learn-english sync --push` | Same workflow, then push the learning profile |

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

## Git learning profile

Read [README.md](README.md) for setup and migration. Sync is an agent-operated workflow, not an english_state.py subcommand. The hook recognizes sync without changing ON/OFF and never runs Git or accesses the network itself. Normal learning only writes local data. Both public and private repositories are supported; honor the user's chosen visibility. The state directory may be a dedicated Git clone or an explicitly configured subdirectory in an existing repository, such as learning/ch-learn-english. Within that profile, only knowledge.json and optional README.md/.gitignore are versioned. Sessions, turn receipts and locks remain untracked on each machine.

On an explicit sync request:

1. Resolve the effective state directory using DOTAGENTS_ENGLISH_STATE_DIR or the default. Find its containing Git repository using git -C <state-directory> rev-parse --show-toplevel; verify a named branch and explicitly configured upstream. Compute the repository-relative profile path. If no profile/remote exists, explain setup; never operate on the current project as a substitute without the user's explicit profile selection. Pause other learning chats on this machine during sync; the helper's write lock does not protect external Git operations.
2. Inspect git status, tracked files, index and merge/rebase state. Within the profile, only .gitignore, README.md and knowledge.json may be tracked. Other repository files are allowed for a shared repository. The index must be empty; reject unrelated modifications, ongoing operations or tracked runtime files before staging. Validate current knowledge using `python3 <this-skill>/scripts/english_state.py list` in the same environment. Check the remote destination and upstream branch.
3. Fetch the configured upstream remote. If fetch fails, leave local knowledge unchanged and report unsynced data. If knowledge.json changed, stage only that file. Before each commit, run git config user.name, git config user.email, git diff --cached --check and read the complete git diff --cached. Stop if identity is absent; never set identity or add tool attribution. Commit with a descriptive message such as `Update learned English items`.
4. Merge the fetched upstream using `git merge --no-edit <upstream>`. Before a potential merge commit, check identity again, require a clean index and inspect both the full remote diff and its commit metadata. Git handles ordinary text merging. On conflict, stop and report the file and local commit; do not choose ours/theirs, reset or force anything. The user resolves the conflict and finishes the merge before retrying sync. Validate the merged knowledge with the helper; invalid JSON/schema stops completion and push, preserving the file for repair.
5. With sync alone, report the local result and commits still awaiting push. Only sync --push authorizes pushing this profile. Before push, repeat identity, index checks and complete staged diff inspection; inspect the exact outgoing commits and full outgoing diff, confirming they contain only profile data and no tool attribution. If a shared repository has unrelated outgoing commits, stop and report them unless the user has also authorized pushing those commits. Push to the verified upstream without force. A rejected push means the remote changed: report that another sync is needed, preserving local commits. Report success only on successful push.

Sync does not enable English mode. A successful local save is distinct from a successful remote sync. Fetch/merge/push conflicts and network failures must be reported accurately. Git locks are local to each clone; independent additions can still produce textual conflicts in knowledge.json. A shared repository merges the whole upstream branch, including changes outside the profile; inspect and report these changes before merging. The workflow does not perform semantic merging or promise automatic 5+10 aggregation.

## Common mistakes

- Reading 'known words' as 'known phrases': the groups are independent.
- Guessing that basic words are known: only explicit entries suppress annotations.
- Remembering a stale dictionary: read hook data or current helper lookups every turn.
- Truncating a large dictionary: use lookup batches, not an incomplete list.
- Re-explaining grammar under another ID: match existing labels/patterns; `catalog grammar --offset 0 --limit 50` returns canonical metadata, revision and next_offset. Pass `--revision HASH` on later pages, restarting at offset 0 if another chat changes the catalog.
- Injecting translations into code: preserve runnable text and annotate prose.
