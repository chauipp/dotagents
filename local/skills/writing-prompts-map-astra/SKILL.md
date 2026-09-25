---
name: writing-prompts-map-astra
description: Use when the user explicitly invokes writing-prompts-map-astra to create or improve a prompt for building a game map, level, or environment. Not for general prompts or directly building the map.
---

# Writing Prompts Map — Astra

Only create or improve a prompt for building a map. The deliverable is one complete prompt for an agent to execute later; do not build the map in this turn. Activate only when the user invokes this profile by name; do not activate both profiles. Install project-locally, never globally.

## Required models

The parent must meet the Astra xhigh minimum; the table below specifies each role's model and reasoning. Do not use max/ultra on your own. If the user confirms a parent model above Astra, upgrade only the parent; workers must continue using the models in the table.

| Role | Model ID | Reasoning |
|---|---|---|
| P | `gpt-6-astra` minimum; higher tier only after user confirmation | `xhigh` |
| S1 | `gpt-5.6-terra` | `medium` |
| S2 | `gpt-6-astra` | `high` |
| S3 | `gpt-6-astra` | `high` |
| S4 | `gpt-5.6-sol` | `high` |
| S5 | `gpt-5.6-sol` | `high` |
| S6 | `gpt-5.6-terra` | `high` |
| S7 | `gpt-6-astra` | `xhigh` |
| W | `gpt-5.6-luna` | `medium` |

P=parent; S1=brief; S2=geometry/area; S3=layout/circulation; S4=interior; S5=art/storytelling; S6=implementation feasibility; S7=independent review; W=optional mechanical inventory.

### Parent model gate

- Minimum: `gpt-6-astra` at `xhigh`.
- Compare models by credits for the same input/output token quantities: `gpt-5.6-luna < gpt-5.6-terra < gpt-5.6-sol < gpt-6-astra`. Do not rank by the total tokens produced in a single answer.
- Verify the parent model before starting any pipeline step.
- If the parent is below Astra, or its reasoning is below `xhigh`, stop with `BLOCKED_MODEL`; do not run a partial pipeline.
- If the parent is above Astra, ask whether the user wants to use that model. Proceed only after confirmation, and use the confirmed model for every parent task.
- If the user declines, stop and ask to switch the parent to Astra. Do not change models yourself.
- If the model cannot be verified, block and ask the user to confirm or select the parent model.
- Do not change global configuration. If a role's model/effort is unsupported by the tool, report the limitation and ask the user to choose a compatible configuration within the profile; do not substitute a model outside the allowlist. If no compatible configuration is available and the user has not chosen an alternative, record `BLOCKED_MODEL` with the missing role/model and stop the pipeline; do not ask repeatedly or pretend the role was dispatched.

Invoking this skill authorizes the parent to delegate to subagents according to the table. Read the available tool schema and explicitly pass the model and reasoning; use a fresh context (with collaboration.spawn_agent: fork_turns="none", model=ID, reasoning_effort=effort). Each task must be self-contained. Never launch a subagent without specifying its model and assume it matches the profile. Do not ask workers to create nested agent teams.

## Required references

Before starting, the parent must read the [workflow](references/workflow.md) and [role contracts](references/roles.md). Both profiles use the same process and criteria; do not reduce the work when the model profile changes. When dispatching, send each worker only the relevant role guidance and data, not every reference.

## Main workflow

S1/S6 → S2 → S3 → S4/S5 in parallel → parent integrates and rechecks affected areas → parent writes the prompt → independent S7 review → revise → deliver one prompt. W supports inventory only; it does not replace S6 or S7. Respect tool concurrency limits and the user's budget; do not remove gates to save cost.

Worker outputs should be designs, evidence, and issues—not separate prompts from every worker. The final prompt must include context, scope, area/layout, each furniture cluster, art direction, implementation instructions, and acceptance criteria. Unknown values need a concrete verification step or fallback; unresolved mandatory issues must be marked BLOCKED.

## Invocation example

`$writing-prompts-map-astra Based on the description and prompt/map/map-1 for the assigned area, write a complete prompt to finish the map with all required functions and interiors, preserve the architecture, calculate areas with evidence, and include acceptance criteria.`

If asked to write a prompt unrelated to maps, explain the scope and do not run the map workflow. If asked to build the map directly, confirm that the user wants to change task type; do not execute it under this prompt-writing skill.
