---
name: ch-research
description: Use when a user asks to investigate, compare, verify, or evaluate a question and needs evidence from multiple sources, cross-checking, or a confidence-calibrated synthesis.
---

# Research orchestration

Use this skill when the user wants to understand, compare, investigate, verify, or evaluate a topic. The topic may be from any domain. Do not assume a field, source type, answer, or preferred conclusion in advance.

Do not include domain-specific examples in this skill or in its default workflow. Keep the workflow general enough to prevent overfitting to any one research topic.

## Objective

Produce a useful, auditable research answer that separates sourced facts, synthesis, inference, disagreement, and remaining uncertainty. Lead with the answer when the evidence supports one; otherwise state the strongest qualified conclusion.

## Model and delegation policy

- Use only GPT-6 Luna for research subagents and the final synthesis agent.
- Run six research subagents in parallel by default.
- Use exactly four research subagents for a narrow, low-risk question. Keep question mapping, primary-source research, independent evidence, and adversarial review represented; combine source auditing with the source researchers rather than adding a fifth subagent.
- Start with six research subagents for a broad or contested question. Expand to seven or eight when the question spans distinct fields, evidence is materially contested, or separate independent verification is needed. High-stakes topics require a second verification pass by a different subagent who independently checks the key evidence and conclusion; add that verifier as a seventh subagent, and use an eighth when another distinct field or verification role is needed.
- Use `medium` reasoning for discovery and source collection.
- Use `high` reasoning for source validation, adversarial review, and final synthesis.
- Raise the final synthesis to `xhigh` only when the evidence is highly conflicting, the reasoning chain is long, or the consequences of error are significant.
- Do not use `max` by default. Higher reasoning should address a concrete complexity or verification need, not merely produce longer prose.
- Give each subagent a distinct assignment and the same central question. Do not ask every subagent to perform an undifferentiated search.

Use the available browsing, search, connector, and document-reading tools. When a needed source is inaccessible, record that limitation instead of inventing or silently substituting evidence.

## Research roles

Assign roles as appropriate to the question:

1. **Question mapper** — decompose the request into claims, definitions, scope, time boundaries, and evaluation criteria that must be resolved.
2. **Primary-source researcher** — locate original studies, datasets, technical documentation, filings, measurements, or direct records.
3. **Independent-evidence researcher** — locate third-party evaluations, replications, benchmarks, experiments, audits, or field measurements.
4. **Practice researcher** — inspect public reports of real-world use, implementation outcomes, and recurring user experiences.
5. **Adversarial researcher** — seek disconfirming evidence, methodological flaws, selection bias, conflicts of interest, stale data, duplicated sources, and incomparable setups.
6. **Source auditor** — check authorship, date, provenance, methods, sample size, independence, access path, and whether each source actually supports the associated claim.

For the four-subagent narrow workflow, combine roles without changing the headcount. For larger workflows, roles may be combined or split based on complexity, but preserve an explicit adversarial pass and source-audit coverage. A second verification pass must be performed independently by a different subagent after the first-pass evidence ledger is assembled, not by asking the original researcher or synthesis agent to recheck its own work.

## Source discipline

- Prefer sources with primary data, transparent methods, clear dates, and enough detail to audit.
- Label each source as primary, independent, secondary, community/anecdotal, or provider-reported when that distinction matters.
- Do not count multiple articles repeating the same announcement, dataset, or study as independent evidence.
- Treat forums and social networks as signals of experience or hypotheses. A single post is not evidence of a general pattern.
- For benchmarks or comparisons, check the task set, harness, version, prompt or protocol, reasoning setting, tool access, sample size, metric, and cost before comparing scores.
- Preserve conflicting results when they use meaningfully different methods. Explain plausible causes instead of averaging incompatible numbers.
- Give provider-reported claims lower evidentiary weight when independent measurements are available, and say when independent evidence is missing.
- Never fabricate a source, quote, number, link, method, search result, or confidence level.
- Prefer recent sources for changing facts while retaining older foundational sources when they remain relevant.

## Workflow

1. Restate the research question internally as a precise central question. Identify scope, time horizon, comparison criteria, and any material ambiguity. Ask the user only when an ambiguity would change the research outcome; otherwise make and disclose a reasonable assumption.
2. Launch the assigned first-pass GPT-6 Luna research subagents in parallel. For a high-stakes question, after assembling the first-pass evidence ledger, launch the separate verifier as a second pass.
3. Require every subagent report to use this compact schema:
   - claims investigated;
   - evidence found;
   - direct source links;
   - source type and independence;
   - method or context;
   - limitations and possible bias;
   - confidence for each claim;
   - unresolved questions.
4. Deduplicate sources and trace repeated reporting back to the earliest or most direct source.
5. Separate results that are not directly comparable. Do not merge scores, samples, time periods, or populations merely because they share a label.
6. Build an evidence ledger mapping each important claim to supporting, opposing, and missing evidence.
7. Send the normalized evidence ledger and the subagent reports to the GPT-6 Luna synthesis agent at `high` or `xhigh` as selected above.
8. Require the synthesis agent to conclude only from collected evidence. For each main conclusion, trace the supporting evidence to direct sources; mark any inference, extrapolation, or judgment explicitly. If the evidence is only anecdotal or secondary, state that limitation and narrow the claim accordingly. If credible evidence is insufficient to answer, say so directly and identify what evidence would be needed; do not force a conclusion.
9. If credible sources disagree, present the competing claims with their supporting sources and methods, and state what remains unresolved instead of smoothing the disagreement into one confident conclusion.
10. Before responding, run the quality checklist below and remove unsupported certainty.

## Output requirements

Respond in the user's language. Put the concise conclusion and confidence level first. Then include only the structure needed for the question, normally:

- key findings with nearby citations;
- a comparison table when several entities or criteria must be mapped;
- areas of independent agreement;
- disagreements and likely reasons;
- limitations, missing evidence, and what could change the conclusion;
- the research date when freshness matters;
- links that the user can open and inspect.

Distinguish explicitly between:

- facts directly supported by a source;
- a synthesis supported by several sources;
- an inference made from the evidence;
- an anecdotal or weak signal.

Use calibrated language. Do not use absolute wording when the evidence is mixed, sparse, stale, provider-controlled, or methodologically incomparable. Do not expose private chain-of-thought; provide concise methodology, evidence, and verifiable reasoning instead.

## Quality gate

Before delivering the answer, verify that:

- every material factual claim has a source or is marked as inference;
- source duplication is not being counted as independent corroboration;
- comparisons do not silently mix incompatible configurations or protocols;
- at least one research pass actively looked for disconfirming evidence;
- weak, biased, or anecdotal sources are labeled;
- important disagreements are visible rather than hidden by a single aggregate;
- the conclusion is consistent with the full evidence ledger, not only the most prominent source;
- the answer does not claim freshness beyond the actual research date;
- the final answer is concise enough for the user to act on while preserving material caveats.

## Boundaries

This skill researches and synthesizes information. If the request also asks for an external action, complete the research portion and keep the action separate; do not perform the action as part of research. Do not claim professional authority or present a definitive recommendation when the evidence is insufficient. For medical, legal, financial, safety, or other high-stakes topics, make limitations and the need for qualified professional judgment especially clear.
