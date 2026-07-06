---
name: verify-stack
description: "Verify that a code change actually does what it's supposed to by running the app and observing behavior. Use when asked to verify a PR, confirm a fix works, test a change manually, check that a feature works, or validate local changes before pushing."
---

# verify-stack

<!-- feature-done 전 3-layer 코드 리뷰. Security → Self-review → Cross-model. -->
<!-- 출력: .claude/verify-report-<feature-id>.md (feature-done이 소비 후 삭제) -->

Multi-layer code review BEFORE feature-done. Three layers with tiered failure modes.

## Preconditions

1. **`feature_list.json` must exist.** If not → stop: "feature_list.json이 없어요."
2. **Identify target feature:** argument (`/verify-stack F008`) or first `passes: false` feature.
3. **Collect the diff:** `git diff HEAD` (unstaged + staged). If empty, try `git diff HEAD~1` (last commit). If still empty → stop: "리뷰할 변경사항이 없어요."

## Layer 1: Security Scan (Hard Block)

<!-- 보안 문제 → 무조건 차단. 사용자가 override 불가. -->

**Trigger:** Always.
**Failure mode:** Hard block — cannot proceed with security findings.

### Static Rule Patterns

Scan ALL changed files for these 6 universal patterns:

| # | Pattern | What to grep | Examples |
|---|---|---|---|
| 1 | Secrets leak | API keys, tokens, passwords in code (not .env) | `sk-`, `AKIA`, `password = "..."`, `token = "..."` |
| 2 | SQL injection | String concatenation in SQL queries | `f"SELECT ... {user_input}"`, `query + variable` |
| 3 | XSS | Unescaped user input in HTML output | `innerHTML = userInput`, `dangerouslySetInnerHTML` |
| 4 | Command injection | User input in shell commands | `exec(userInput)`, `os.system(f"... {x}")`, `Invoke-Expression $var` |
| 5 | Hardcoded credentials | Passwords, connection strings in source | `mongodb://user:pass@`, `postgres://...` |
| 6 | Path traversal | User input in file paths without sanitization | `open(user_path)`, `fs.readFile(req.params.file)` |

### Depth: core vs strict

- **Default:** scan the 6 core patterns above.
- **Strict:** when the user passes `--strict`, OR the PRD/ARCHITECTURE_PROPOSAL marks the project
  production-grade, load `references/security-checklist.md` and evaluate all 15 items. Extended
  items follow the same Hard-Block rule as core patterns on Must-have surfaces.
- These are app-level checks only. Cloud-infra/deployment security is out of scope (HEO deploy/monitor own that).

### LLM False-Positive Suppression

After static scan finds hits, review each hit in context:
- Is it a test fixture / example / documentation? → **Not a real finding**
- Is the variable from a safe source (env var, config loader)? → **Not a real finding**
- Is the pattern in a comment or string literal not used as code? → **Not a real finding**

Only genuine findings survive. If any remain:

```
🔴 Security — HARD BLOCK
  - [file:line] [pattern name]: [specific finding]

이 보안 문제를 해결해야 진행할 수 있어요.
```

Fix the issue, then re-run Layer 1. Do NOT proceed to Layer 2 until clean.

**If clean:** `🟢 Security — passed`

## Layer 2: Self-Review (Confirm)

<!-- Claude가 자기 작업을 리뷰. 사용자가 이유와 함께 override 가능. -->

**Trigger:** Always (after Layer 1 passes).
**Failure mode:** Confirm — user can override with stated reason.

### Review Checklist

Read the diff and check against:

1. **Plan alignment** — Does the diff match the feature's `plan.steps` in feature_list.json?
2. **Scope creep** — Are there changes unrelated to this feature?
3. **Missing pieces** — Are all `plan.files_to_touch` actually touched?
4. **Convention adherence** — Does new code follow established project patterns?
5. **Edge cases** — Are obvious edge cases handled? (empty input, missing file, network error)

### Confidence Score

Rate self-review confidence 0-100% (maps to confidence tags):
- **90-100%:** All checklist items pass, small diff, well-understood domain → `[verified]`
- **70-89%:** Minor concerns, no blockers → `[high]`
- **50-69%:** Notable gaps or uncertainty — flags cross-model review → `[medium]`
- **Below 50%:** Significant concerns — recommend user review → `[guess]`

Output:

```
🟡 Self-review — [confidence]% confidence
  ✅ Plan alignment: [detail]
  ✅ Scope: [detail]
  ⚠️ Edge case: [concern, if any]

[confidence < 70% 일 때]
  → Cross-model 리뷰를 권장합니다.
```

If confidence < 70%, present concerns and ask:
> "이 부분이 확실하지 않아요. 그래도 진행할까요, 아니면 수정할까요?"

User can override with reason → record override reason in report.

## Layer 3: Cross-Model Review (Warn)

<!-- Gemini CLI로 교차 검증. 없으면 skip. 결과는 경고만, 차단 안 함. -->

**Trigger:** Conditional — fires when ANY of:
- Diff exceeds 100 changed lines
- Self-review confidence < 70%
- User passed `--strict` flag
- User explicitly requests it

**Failure mode:** Warn only — logged in report, does not block.

### Cost Estimate (before execution)

<!-- 비용 추정: cross-model은 외부 CLI 호출이므로 사용자에게 알림 -->

When Layer 3 triggers, show before executing:

```
💰 예상 비용: 컨텍스트 [소/중/대] | 외부 호출 1회 (Gemini CLI). 건너뛸까요?
```

Context size = total diff lines (< 500: 소, 500-2000: 중, > 2000: 대). If user skips, log `"skipped_steps": ["cross-model"]` and proceed to report generation.

### Gemini CLI Detection

```bash
which gemini 2>/dev/null || where gemini 2>$null
```

**If not installed:**
```
ℹ️ Cross-model — skipped (Gemini CLI not installed)
  Install: npm i -g @anthropic-ai/gemini-cli (optional)
```

Log skip in report and continue. Never block on missing Gemini.

**If installed:**

Invoke Gemini with the diff for an independent review:
```bash
git diff HEAD | gemini -p "Review this code diff for bugs, security issues, and design problems. Be concise. List only genuine concerns, not style preferences."
```

Parse Gemini's response. For each finding:
- If it overlaps with Layer 1/2 findings → already covered, skip
- If it's a new genuine concern → add as warning

```
🟠 Cross-model — [N] warnings
  ⚠️ [finding 1]
  ⚠️ [finding 2]

참고용이에요. 차단하지 않습니다.
```

If no findings: `🟢 Cross-model — no concerns`

## Output: Verify Report

After all layers complete, generate `.claude/verify-report-<feature-id>.md`:

```markdown
<!-- verify-stack output. feature-done이 소비 후 삭제. -->
# Verify Report — F[XXX]

- Generated: YYYY-MM-DD HH:MM
- Diff scope: [N files changed, +X/-Y lines]

## Security (Layer 1)
- Result: PASS | BLOCK
- Findings: [none | list]

## Self-Review (Layer 2)
- Result: PASS | OVERRIDE (reason: "...")
- Confidence: [N]%
- Findings: [checklist results]

## Cross-Model (Layer 3)
- Result: PASS | WARN | SKIPPED (reason)
- Findings: [none | list]

## Summary
- Layers passed: [N]/3
- Blocking issues: [none | list]
- Warnings: [none | list]
- Recommendation: PROCEED | FIX_REQUIRED | USER_REVIEW [confidence tag]
```

## Integration with feature-done

feature-done reads `.claude/verify-report-<feature-id>.md`:
- If `FIX_REQUIRED` → feature-done refuses to set `passes: true`
- If `PROCEED` with warnings → feature-done notes warnings in progress.md
- If no report exists → feature-done can still run (verify-stack is recommended, not mandatory yet)

After feature-done consumes the report, it deletes the file.

## Cost Log

<!-- 비용 로그: 스킬 완료 후 .claude/cost-log.jsonl에 기록 -->

After verify-stack completes (all layers done), append one line to `.claude/cost-log.jsonl` per `~/.claude/rules/cost-awareness.md` format. Include `skipped_steps` if the user skipped Layer 3.

## Hard Rules

- **NEVER skip Layer 1 (Security).** It always runs, even with `--quick` flag.
- **NEVER auto-override Layer 2.** User must explicitly confirm with reason.
- **NEVER hard-block on Layer 3.** Cross-model findings are warnings only.
- **NEVER fail if Gemini is not installed.** Graceful skip + log.
- **NEVER fabricate findings.** Only report what the scan actually detects.
- **ALWAYS generate verify-report.** Even if all layers pass (report says PASS).
- **ALWAYS present findings in Korean** for user communication.
- **Report format is stable.** feature-done depends on the `Summary` section structure.
