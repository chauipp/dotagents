# Task 1: Remove duplicate command behavior from agent rules

Modify only:
- `codex/AGENTS.md`
- `claude/CLAUDE.md`
- `tests/install.sh`

Remove the action blocks for `/no-clarify`, clear-conversation, and compact-conversation from both rules files. Keep unrelated rules, especially general conversation logging rules. Update installer assertions to verify the command-specific triggers are absent while the dotagents marker remains. Inspect the resulting files. Do not modify shared skills, README, or installed files. Do not commit.

Global constraints:
- Reply in Vietnamese if reporting to the user.
- Preserve unrelated rules exactly.
- Use the existing repository style.

Report contract: write a concise report to `G:\dotagents\.superpowers\sdd\2026-09-20-skill-only-command-workflow\task-1-report.md` containing changed files, tests/checks run with output, and concerns.
