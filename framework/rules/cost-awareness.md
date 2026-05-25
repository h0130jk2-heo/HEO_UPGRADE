# Cost Awareness — Cross-Cutting Convention

Before executing a skill that reads many files or spawns subagents, show the user a one-line cost estimate so they can skip expensive steps.

## When to show

Only for skills tagged as **cost-notable** in their SKILL.md. Currently:
- `/verify-stack` Layer 3 (cross-model — spawns external CLI)
- `/architecture-sketch` (reads PRD + generates alternatives)
- `/reflect` (scans history across multiple files)

Do NOT show cost estimates for lightweight skills (feature-plan, feature-done, handoff, resume-heo, project-doctor).

## How to estimate

| Factor | Indicator | Size label |
|---|---|---|
| Context read | < 500 lines total | 소 (small) |
| Context read | 500–2000 lines | 중 (medium) |
| Context read | > 2000 lines | 대 (large) |
| Subagent / external CLI | None | — |
| Subagent / external CLI | 1 external call (e.g., Gemini) | +외부 호출 1회 |
| Subagent / external CLI | Agent tool spawn | +서브에이전트 |

## Display format

One line before the expensive step, not before the whole skill:

```
💰 예상 비용: 컨텍스트 [소/중/대] | [외부 호출 정보]. 건너뛸까요?
```

If the step is skippable, offer the skip option. If not skippable (e.g., security scan), show the estimate without skip.

## Cost log

After each cost-notable skill completes, append one JSON line to `.claude/cost-log.jsonl` in the project root:

```jsonl
{"ts":"2026-05-25T14:30:00Z","skill":"verify-stack","feature":"F008","context_size":"medium","external_calls":1,"skipped_steps":["cross-model"],"duration_approx":"~2min"}
```

Fields:
- `ts` — ISO 8601 timestamp
- `skill` — skill name
- `feature` — feature ID (if applicable, else null)
- `context_size` — "small" / "medium" / "large"
- `external_calls` — count of external CLI/subagent invocations
- `skipped_steps` — array of steps the user chose to skip (empty if none)
- `duration_approx` — rough duration string

Create the file on first write. Do not read/parse existing entries during skill execution — the log is append-only for later review.

## Where NOT to apply

- Exploratory work (user asking questions, browsing code)
- Git operations (commit, status, log)
- File reads/writes during implementation
- Skills not tagged as cost-notable
