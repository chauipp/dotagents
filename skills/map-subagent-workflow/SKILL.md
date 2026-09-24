---
name: map-subagent-workflow
description: Use when building or editing an Unreal Engine room, sector, or level from a detailed spatial specification, especially with UE/Blender assets, shared .umap files, collision, physical mounting, lighting, or visual QA.
---

# UE Map Subagent Workflow

## Core contract

The Sol parent is the design authority, contract owner, and final visual gate. Workers receive bounded deliverables. Exactly one final-map builder writes the target `.umap`; no other agent edits it concurrently.

This skill cannot change the parent model. When the runtime exposes the parent identity, require `gpt-5.6-sol` at `xhigh`; otherwise disclose that the parent model could not be verified. Never claim that this skill upgraded the parent.

## Automatic quality-first routing

`$map-subagent-workflow` has no positional model arguments. On every invocation, assign only the roles actually needed using this table:

| Role | Model | Reasoning | Ownership |
|---|---|---|---|
| Parent / art director / integrator | `gpt-5.6-sol` | `xhigh` | Full brief, room contract, acceptance; not target-map writer while builder runs |
| Geometry explorer | `gpt-5.6-terra` | `high` | Read-only map/geometry survey |
| Asset inventory and license scout | `gpt-5.6-luna` | `medium` | Read-only inventory/report |
| Blender hero-asset worker | `gpt-5.6-sol` | `high` | Isolated source/export/import-ready assets only |
| Layout worker | `gpt-5.6-terra` | `high` | Transform proposal, footprint manifest, or sandbox level only |
| Technical worker | `gpt-5.6-terra` | `high` | Isolated cable, bracket, service, collision, or material modules |
| Final-map builder | `gpt-5.6-sol` | `high` | Sole writer of the named target `.umap` |
| Evidence worker | `gpt-5.6-luna` | `medium` | Screenshots, hashes, counts, logs, and reports only |
| Structural QA | `gpt-5.6-terra` | `high` | Read-only collision, overlap, clearance, support, reload, and PIE audit |
| Final visual QA | Sol parent | current `xhigh` | Opens the images directly and decides PASS/FAIL |

Only the user may explicitly override one role. An override must name the role, exact model, and exact reasoning. Do not infer a global override from prose and do not restore the former “one model for every worker” behavior.

If the runtime rejects any required model/reasoning pair, stop before dispatching that role and report the exact rejection. Do not lower reasoning, inherit another model, or substitute Luna/Terra/Sol automatically.

## Reasoning promotion ladder

`high` is the default for work that must reason about geometry, assets, collision, integration, or QA. `medium` is reserved for bounded, repeatable read-only collection and evidence work. More actor count, more files, or a tighter deadline never alone justifies a higher setting.

Promote one worker from `high` to `xhigh` only when the parent records at least one observable trigger:

- two or more hard constraints conflict (for example geometry, clearance, sightline, mounting, or lighting);
- the change spans two coupled systems (for example geometry plus collision, or material plus final visibility) and a `high` pass did not resolve it;
- its same deliverable failed review after one targeted correction; or
- the available evidence cannot distinguish a visual/design defect from a spatial/integration defect.

Apply that promotion only to the bounded worker and deliverable that needs it. Typical candidates are the hero-asset worker, layout worker, technical worker, final builder, or structural reviewer. Do not promote Luna inventory/evidence work merely because it has many files.

`max` is not a routine final gate and is never assigned to a worker. The Sol parent may use it temporarily for one adjudication only when both conditions hold: (1) two `xhigh` attempts or reviews remain in material conflict or fail to resolve a non-reversible decision; and (2) the decision changes the room contract, protected architecture, or a costly-to-rework integration choice. Record the conflict, the options, and the decision. Otherwise remain at parent `xhigh`.

## Required sequence

1. **Survey without mutation.** Measure the real level, coordinate frame, floor, walls, glass, doors, ceiling, collision, existing assets, dirty files, protected actors, and player capsule. Illustrative coordinates never override measured geometry.
2. **Freeze the room contract.** The parent writes the manifest and acceptance rubric before any target-map mutation.
3. **Prepare assets in isolation.** Inventory, hero assets, layout proposals, and technical modules may run in parallel only when their files and ownership do not overlap.
4. **Approve assets before placement.** The Sol parent inspects actual asset evidence. Rejected assets return to their owner; the map builder does not imitate missing assets with primitives.
5. **Run one builder.** The named Sol builder writes only the target map and explicitly scoped integration files from the approved manifest.
6. **Collect independent evidence.** Luna captures evidence; Terra performs structural QA; neither edits the target map.
7. **Parent visual gate.** The Sol parent opens every required eye-level and top-down image. A failed visual gate returns targeted corrections to the same builder or asset owner.
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
| “Luna is cheaper, so it can build the final map.” | Route the final builder to Sol/high. Cost never silently changes the quality-first matrix. |
| “Sol/high is enough for the parent because the brief is already detailed.” | Keep the parent at Sol/xhigh; detailed briefs still need cross-role adjudication and visual judgment. |
| “A different premium model is equivalent to Sol as parent.” | Preserve the declared role/model pair; report an unavailable pair rather than silently substituting. |
| “The last review is important, so use max by default.” | Parent xhigh is the final gate. Max requires two unresolved xhigh attempts plus a non-reversible contract, architecture, or costly integration decision. |
| “The deadline, actor count, or manager request justifies xhigh/max everywhere.” | Promote only the one bounded deliverable after an observable promotion trigger. Parallelism and scope control solve throughput; reasoning inflation does not. |
| “These labeled cubes count as functional props.” | Reject them at the real-asset gate. Labels and counts are not models. |
| “Static QA passed, so ugly screenshots are acceptable.” | Visual gate remains failed; return corrections. |
| “The camera angle hides the floating piece.” | Inspect support from another eye-level angle and top-down; fix or remove it. |
| “The runtime rejected xhigh, so medium is close enough.” | Stop and report the rejection; do not substitute. |
| “Two map writers will finish faster.” | Keep one target-map writer; parallelize only isolated assets and read-only work. |
| “The user asked to commit, therefore it is complete.” | Commit only as a clearly labeled WIP checkpoint while any gate fails. |
