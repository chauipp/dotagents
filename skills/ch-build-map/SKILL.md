---
name: ch-build-map
description: Use when building or editing an Unreal Engine room, sector, or level from a detailed spatial specification, especially with UE/Blender assets, shared .umap files, collision, physical mounting, lighting, or visual QA.
---

# UE Map Subagent Workflow

## Core contract

The confirmed parent is the design authority, contract owner, and final visual gate. Use `gpt-5.6-luna` for light or moderate bounded work and `gpt-6.1-sol` for complex design, integration, map writing, or adjudication. Workers receive bounded deliverables. Exactly one final-map builder writes the target `.umap`; no other agent edits it concurrently.

## Profile selection and syntax

Invoke `$ch-build-map [low|med|high] <request>`. `medium` aliases `med`; omitting the level selects `med`. A level is recognized only as the first token after the skill name. Model IDs are not positional arguments.

- `low`: light, bounded changes with straightforward geometry, layout, and checklist-based QA.
- `med`: moderate work with complex asset preparation, layout, integration, or structural review; simple surveys and bounded technical modules use Luna.
- `high`: complex work with coupled geometry, layout, technical systems, and structural decisions; decision-making workers use Sol 6.1.

Use exactly one selected profile's table. Assign only roles actually needed. If a deliverable exceeds the selected profile's scope, report the mismatch and request a profile change before dispatching it; do not silently mix tables. Every profile retains all applicable acceptance gates.

### Parent model gate

- `low` requires `gpt-5.6-luna / medium`.
- `med` and `high` require `gpt-6.1-sol / xhigh`.
- Verify the exact runtime parent model and reasoning before planning, reading project assets, or dispatching workers. If the required pair cannot be verified or is unavailable, return `BLOCKED_MODEL` without starting the workflow.
- Do not switch the runtime model yourself. Ask the user to switch to the required pair when it does not match.

## Role table — profile `low`

| Role | Model | Reasoning |
|---|---|---|
| Parent / art director / integrator | `gpt-5.6-luna` | `medium` |
| Geometry explorer | `gpt-5.6-luna` | `medium` |
| Asset inventory and license scout | `gpt-5.6-luna` | `medium` |
| Blender hero-asset worker | `gpt-6.1-sol` | `high` |
| Layout worker | `gpt-5.6-luna` | `medium` |
| Technical worker | `gpt-5.6-luna` | `medium` |
| Final-map builder | `gpt-6.1-sol` | `high` |
| Evidence worker | `gpt-5.6-luna` | `medium` |
| Structural QA | `gpt-5.6-luna` | `medium` |
| Final visual QA | `gpt-5.6-luna` | `medium` |

## Role table — profile `med`

| Role | Model | Reasoning |
|---|---|---|
| Parent / art director / integrator | `gpt-6.1-sol` | `xhigh` |
| Geometry explorer | `gpt-5.6-luna` | `medium` |
| Asset inventory and license scout | `gpt-5.6-luna` | `medium` |
| Blender hero-asset worker | `gpt-6.1-sol` | `high` |
| Layout worker | `gpt-6.1-sol` | `high` |
| Technical worker | `gpt-5.6-luna` | `medium` |
| Final-map builder | `gpt-6.1-sol` | `high` |
| Evidence worker | `gpt-5.6-luna` | `medium` |
| Structural QA | `gpt-6.1-sol` | `high` |
| Final visual QA | `gpt-6.1-sol` | `xhigh` |

## Role table — profile `high`

| Role | Model | Reasoning |
|---|---|---|
| Parent / art director / integrator | `gpt-6.1-sol` | `xhigh` |
| Geometry explorer | `gpt-6.1-sol` | `high` |
| Asset inventory and license scout | `gpt-5.6-luna` | `medium` |
| Blender hero-asset worker | `gpt-6.1-sol` | `high` |
| Layout worker | `gpt-6.1-sol` | `high` |
| Technical worker | `gpt-6.1-sol` | `high` |
| Final-map builder | `gpt-6.1-sol` | `high` |
| Evidence worker | `gpt-5.6-luna` | `medium` |
| Structural QA | `gpt-6.1-sol` | `high` |
| Final visual QA | `gpt-6.1-sol` | `xhigh` |

## Shared role ownership

- Parent owns the brief, room contract, integration decisions, and acceptance; it remains read-only against the target map while the builder runs.
- Geometry explorer surveys the map read-only; inventory/license scout produces a read-only inventory and report.
- Hero-asset worker creates isolated source/export/import-ready assets. This complex authoring role uses Sol 6.1 even in `low`.
- Layout worker produces a transform proposal, footprint manifest, or sandbox level. Technical worker produces isolated cable, bracket, service, collision, or material modules.
- Final-map builder is the sole writer of the named target `.umap`; this integration role uses Sol 6.1 in every profile.
- Evidence worker captures screenshots, hashes, counts, logs, and reports only. Structural QA audits collision, overlap, clearance, support, reload, and PIE read-only.
- Final visual QA opens the images directly and decides PASS/FAIL.

Only the user may explicitly override one role. An override must name the role, exact model, and exact reasoning. Do not infer a global override from prose and do not restore the former “one model for every worker” behavior.

If the runtime rejects any required model/reasoning pair, stop before dispatching that role and report the exact rejection. Do not lower reasoning or substitute another model automatically. This skill uses only `gpt-5.6-luna` and `gpt-6.1-sol`.

## Reasoning promotion ladder

Use `medium` for light, repeatable, bounded work assigned to `gpt-5.6-luna`. Use `high` or `xhigh` for complex geometry, assets, collision, integration, or QA assigned to `gpt-6.1-sol`. More actor count, more files, or a tighter deadline never alone justifies higher reasoning.

Promote one worker from `high` to `xhigh` only when the parent records at least one observable trigger:

- two or more hard constraints conflict (for example geometry, clearance, sightline, mounting, or lighting);
- the change spans two coupled systems (for example geometry plus collision, or material plus final visibility) and a `high` pass did not resolve it;
- its same deliverable failed review after one targeted correction; or
- the available evidence cannot distinguish a visual/design defect from a spatial/integration defect.

Apply that promotion only to the bounded `gpt-6.1-sol` worker and deliverable that needs it. Do not escalate Luna inventory/evidence work merely because it has many files.

`max` is not a routine final gate and is never assigned to a worker. The confirmed `gpt-6.1-sol` parent may use it temporarily for one adjudication only when both conditions hold: (1) two `xhigh` attempts or reviews remain in material conflict or fail to resolve a non-reversible decision; and (2) the decision changes the room contract, protected architecture, or a costly-to-rework integration choice. Record the conflict, the options, and the decision. Otherwise remain at parent `xhigh`.

## Required sequence

1. **Survey without mutation.** Measure the real level, coordinate frame, floor, walls, glass, doors, ceiling, collision, existing assets, dirty files, protected actors, and player capsule. Illustrative coordinates never override measured geometry.
2. **Freeze the room contract.** The parent writes the manifest and acceptance rubric before any target-map mutation.
3. **Prepare assets in isolation.** Inventory, hero assets, layout proposals, and technical modules may run in parallel only when their files and ownership do not overlap.
4. **Approve assets before placement.** The confirmed parent inspects actual asset evidence. Rejected assets return to their owner; the map builder does not imitate missing assets with primitives.
5. **Run one builder.** The named `gpt-6.1-sol` builder writes only the target map and explicitly scoped integration files from the approved manifest.
6. **Collect independent evidence.** The evidence worker and structural reviewer use the selected profile's exact assignments. Neither edits the target map during QA.
7. **Parent visual gate.** The confirmed parent opens every required eye-level and top-down image. A failed visual gate returns targeted corrections to the same builder or asset owner.
8. **Reload and report.** Reopen the saved level, rerun affected checks, and distinguish completed work from unresolved or unverified work.

## Manifest required before placement

Each managed actor or functional cluster includes:

- stable ID and owning role;
- asset path, source, license, and redistribution status;
- location, named-axis rotation, scale, footprint, and bottom/top bounds;
- supporting surface or mounting actor;
- access side and required clearances;
- power, data, sample, or fluid endpoints;
- collision policy;
- evidence and acceptance check.

Reruns manage only the declared ownership prefix. Never delete by a broad shared prefix or mutate protected actors to make a count pass.

## Real-asset gate

Visible final props are approved existing assets or actual authored assets. Engine `Cube`, `Cylinder`, `Sphere`, BSP, or equivalent primitives are allowed only as temporary blockout, hidden collision, or invisible support geometry.

A custom visible prop is not ready for placement until the parent verifies:

- source asset (`.blend` or equivalent) and intended UE import asset;
- real-world UE scale and deliberate pivot;
- clean silhouette, normals, UVs, material slots, and reusable materials;
- collision and, where relevant, LOD/Nanite policy;
- support/mount geometry and service connection points;
- turntable or orthographic evidence plus an eye-height in-level test;
- no missing dependency or unresolved import warning.

Actor count, labels, manifest completeness, or static QA cannot convert primitive placeholders into finished models.

## Physical plausibility gate

For every object, answer: what is it for, what supports it, where is it accessed, and where do required connections terminate? Reject floating, sunken, intersecting, unsupported, inaccessible, or unconnected objects.

Use actual transformed bounds and support surfaces. Do not share one Z value across unrelated meshes. Check doors/drawers, player paths, maintenance zones, wall normals, glass mullions, cable endpoints, trolley wheels, brackets, feet, anchors, and pedestal plates.

## Writer and correction rules

- Choose parent-integration mode or subagent-builder mode before mutation; never mix them.
- In builder mode, the parent and all other workers remain read-only against the target `.umap`.
- Two agents never write the same `.umap`, `.uasset`, manifest, material, or placement region concurrently.
- Asset defects return to the asset owner. Layout/integration defects return to the same final-map builder.
- A builder may not delegate another target-map writer.
- Preserve a recoverable source/checkpoint and never overwrite unrelated dirty work.

## Acceptance gates

All applicable gates must pass independently:

1. **Asset:** approved meshes/materials/scale/pivots/collision/support evidence.
2. **Contract:** manifest matches all-and-only managed actors and protected scope remains intact.
3. **Structural:** no unintended gaps, overlaps, floating objects, blocked access, broken references, or dangling services.
4. **Traversal:** PIE/standalone capsule route reaches every required zone and existing door.
5. **Visual:** entrance, reverse, hero, work zones, technical connections, support zone, exterior scene, and top-down views are readable at final exposure.
6. **Persistence:** saved target reloads with the same actors and references.

Static, manifest, actor-count, reload, or PIE success never overrules failed visual evidence. The parent must inspect the image pixels, not accept a worker’s “looks good” summary.

## Commit and completion semantics

When all gates pass, the work may be reported as complete and committed with its evidence.

If the user asks to stop or commit while a gate fails, a checkpoint commit is allowed only when clearly labeled WIP/incomplete and accompanied by the failed-gate report. Never describe that checkpoint as finished, accepted, production-ready, or proof that the visual result passed.

## Dispatch template

```text
Role: [exact role]
Profile: [low / med / high]
Model/reasoning: [exact pair from routing table]
Single deliverable: [one bounded result]
Context: [only the relevant excerpt and approved contract]
Allowed reads/writes: [explicit paths, assets, and map]
Forbidden scope: [source map, unrelated rooms/assets, concurrent writers]
Acceptance checks: [measurable gates]
Return: [files, IDs, transforms, evidence, deviations, blockers]
```

## Red flags — stop and correct course

| Rationalization | Required response |
|---|---|
| “Luna can build the final map because the task seems routine.” | Route the sole target-map writer to `gpt-6.1-sol/high`; Luna is for light/moderate bounded work. |
| “A detailed brief makes the parent tier irrelevant.” | Use the selected profile's parent: Luna/medium for `low`, Sol 6.1/xhigh for `med` and `high`. |
| “Switch the runtime to the model the task needs.” | Ask the user to switch; never change the runtime model yourself. |
| “The last review is important, so use max by default.” | Use the selected profile's final visual QA effort. Max requires two unresolved xhigh attempts plus a non-reversible contract, architecture, or costly integration decision. |
| “The deadline, actor count, or manager request justifies xhigh/max everywhere.” | Promote only the one bounded `gpt-6.1-sol` deliverable after an observable promotion trigger. Parallelism and scope control solve throughput; reasoning inflation does not. |
| “These labeled cubes count as functional props.” | Reject them at the real-asset gate. Labels and counts are not models. |
| “Static QA passed, so ugly screenshots are acceptable.” | Visual gate remains failed; return corrections. |
| “The camera angle hides the floating piece.” | Inspect support from another eye-level angle and top-down; fix or remove it. |
| “The runtime rejected xhigh, so medium is close enough.” | Stop and report the rejection; do not substitute. |
| “Two map writers will finish faster.” | Keep one target-map writer; parallelize only isolated assets and read-only work. |
| “The user asked to commit, therefore it is complete.” | Commit only as a clearly labeled WIP checkpoint while any gate fails. |
