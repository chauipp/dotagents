# Task 2: Reinstall and verify skill-only discovery for all agents

Modify only the following source/documentation and installed deployment files:
- `README.md`
- `C:\Users\royal\.codex\AGENTS.md`
- `C:\Users\royal\.codex\skills\` and its `.dotagents-manifest`
- `C:\Users\royal\.claude\CLAUDE.md` when present
- `C:\Users\royal\.claude\skills\` and its `.dotagents-manifest` when the installation exists

Requirements:
- Copy the updated source rules so installed rules no longer contain the three command-specific action blocks.
- Install all source shared skills plus the correct agent-specific graphify skill into the dotagents-managed Codex installation.
- Ensure each existing agent installation has the three canonical workflows; for unmanaged installations, add only missing non-colliding directories and preserve unrelated user-authored skills.
- Preserve unrelated system skills and user-authored content.
- Ensure the three canonical workflows are explicit-only skills: `$no-clarify`, `$clear-conversation`, `$compact-conversation`.
- Update README usage text so it does not advertise slash invocation for these workflows; mention `$` as the explicit skill interface and `/skills` only as the selector where appropriate.
- Verify managed manifest entries have no duplicates/missing directories and source/installed hashes match; verify the three canonical workflow hashes in unmanaged installations.
- Do not run destructive cleanup outside dotagents-managed manifest entries. Do not commit.

Report contract: write a concise report to `G:\dotagents\.superpowers\sdd\2026-09-20-skill-only-command-workflow\task-2-report.md` with changed locations, validation commands/results, and concerns.
