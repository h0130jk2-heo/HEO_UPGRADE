# Confidence Tags — Cross-Cutting Convention
<!-- 프레임워크 출력물의 확신도 표시 규칙. 비개발자가 Claude의 판단 근거를 파악할 수 있게. -->

When producing framework skill outputs (recommendations, diagnoses, risk assessments, architecture decisions), tag claims with confidence level:

| Tag | Meaning | When to use |
|---|---|---|
| `[verified]` | Directly observed | File exists, test passed, command output confirmed |
| `[high]` | Strong inference | 3+ corroborating signals or well-established pattern |
| `[medium]` | Moderate inference | Single signal, plausible reasoning, common convention |
| `[guess]` | No strong basis | Assumption, heuristic, or insufficient data |

## Where to apply

Tag the **claim or recommendation itself**, not every sentence. Focus on:
- Architecture/tech stack recommendations
- Risk assessments and complexity estimates
- Diagnostic findings and fix suggestions
- Security findings and review conclusions
- Any statement the user might act on

## Where NOT to apply

- Exploratory outputs (brainstorm ideas — inherently uncertain)
- Archival records (handoff summaries, progress logs)
- Direct file reads or git output (already factual)
- instincts.md entries — these use their own `(confidence: low/medium/high — N회 관찰)` format

## Format

Inline at end of the claim: `이 프로젝트는 Python이 적합합니다 [high]`
In bullet lists: `- Risk: API rate limit 초과 가능성 [medium]`
