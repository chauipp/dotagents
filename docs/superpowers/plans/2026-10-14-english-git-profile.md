# English Git Profile Implementation Plan

**Goal:** Support an explicit Git workflow for portable personal learning data.

**Architecture:** Existing state directory points at a dedicated Git clone. Agent follows skill instructions for sync; hook accepts the invocation while preserving language state.

**Tech Stack:** Python stdlib, Git, Markdown.

## Global Constraints

Only knowledge.json is tracked. Git conflicts are resolved by the user. Push requires sync --push. Keep current Git identity. Never automatically run network operations in learning hooks.

- [x] Task 1: Accept sync controls and define the agent workflow
  - [x] Test sync and sync --push preserve ON/OFF and do not report invalid arguments.
  - [x] Update hook recognition and SKILL.md with repository checks, commit/merge/push sequence and conflict stop.
- [x] Task 2: Document multi-machine setup and verify
  - [x] Add README with migration, allowlist .gitignore, environment inheritance, Git workflow and conflict recovery.
  - [x] Run helper tests and hook installer tests; inspect docs against actual behavior.
  - [x] Write summary and prepare identity/diff checks for local integration.

## Kết quả

[Summary](../summaries/2026-10-14-english-git-profile-summary.md)

[Spec](../specs/2026-10-14-english-git-profile-design.md)
