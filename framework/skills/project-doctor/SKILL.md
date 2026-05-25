---
name: project-doctor
description: Health check across project framework artifacts. Use when the user calls /project-doctor, says "프로젝트 점검", "건강 검진", "health check", "점검해줘", "상태 체크", "drift 체크", "project doctor", or when handoff (Advanced tier) auto-suggests it. Checks CLAUDE.md size, Architecture.md drift, feature_list.json drift, stale lessons, unused skills. Outputs a health report with suggested fixes — user picks which to apply.
---

# project-doctor

<!-- 프로젝트 프레임워크 아티팩트의 건강 상태를 전수 검진. -->
<!-- 읽기 전용 진단이 기본. 수정은 유저 확인 후에만 실행. -->

## Overview

Run 5 health checks across the project's framework artifacts. Output a structured report with actionable fix suggestions. The user picks which fixes to apply — project-doctor never auto-modifies.

**Trigger:** On-demand (`/project-doctor`) or suggested by handoff at Advanced tier.

## Preconditions

At least one of these must exist in the project root:
- `CLAUDE.md`
- `feature_list.json`
- `Architecture.md` (or `docs/Architecture.md`)

If none exist → "프레임워크 아티팩트가 없어요. `/init-project`부터 시작할까요?"

## Step 1: Run All Checks (silent)

Run all 5 checks. Missing files are gracefully skipped (marked as N/A, not failures).

### Check 1: CLAUDE.md Size

<!-- Karpathy 200줄 기준 — 매 대화 로드되므로 간결해야 함 -->

- Read `CLAUDE.md` and count lines
- **Pass (✅):** ≤ 200 lines
- **Warn (⚠️):** 201-250 lines — "근접. 압축 권장"
- **Fail (❌):** > 250 lines — "초과. `/optimize-claude-md` 권장"
- **N/A:** CLAUDE.md doesn't exist

### Check 2: Architecture.md Drift

- Read `Architecture.md` (or `docs/Architecture.md`)
- Find items marked `(planned)`, `(TODO)`, or `(upcoming)`
- Cross-reference with `feature_list.json` — if the corresponding feature has `passes: true`, the item is stale
- Also check: are there completed features whose artifacts aren't mentioned in Architecture.md at all?
- **Pass (✅):** No stale planned items, no missing built items
- **Warn (⚠️):** 1-2 stale items
- **Fail (❌):** 3+ stale items or major built features missing
- **N/A:** Architecture.md doesn't exist

### Check 3: feature_list.json Drift

- Compare features in `feature_list.json` with `PRD.md` (if exists)
- Check for: features in JSON not in PRD, features in PRD not in JSON
- Check internal consistency: `depends_on` references valid feature IDs, no orphan IDs
- Check plan staleness: features with `plan.generated_at` older than 30 days that are still `passes: false`
- **Pass (✅):** Consistent
- **Warn (⚠️):** Minor drift (1-2 items)
- **Fail (❌):** Significant drift (3+)
- **N/A:** feature_list.json doesn't exist

### Check 4: Stale Lessons

- Read `~/.claude/rules/lessons-learned.md` (global)
- Find entries with dates older than 180 days (6 months) that haven't been referenced in recent instincts or progress
- **Pass (✅):** No stale entries, or file is empty
- **Warn (⚠️):** 1-2 entries older than 180 days
- **Fail (❌):** 3+ stale entries
- **N/A:** File doesn't exist or is empty

### Check 5: Unused Skills

- List all skill directories under `~/.claude/skills/`
- For each skill, check if it appears in recent history:
  - `git log --oneline -50` (mentioned in commit messages)
  - `progress.md` (referenced)
  - `feature_list.json` descriptions or plan fields
- **Pass (✅):** All installed skills have been referenced
- **Warn (⚠️):** 1-2 skills with no references found
- **Fail (❌):** 3+ unreferenced skills
- Note: some skills (brainstorm, deploy, monitor) are legitimately infrequent — flag but don't alarm

## Step 2: Present Health Report

<!-- 반드시 한국어로 출력 -->

```
🏥 Project Doctor — 건강 보고서

프로젝트: [project name from feature_list.json or directory name]
검진 일시: [YYYY-MM-DD]

━━ 검진 결과 ━━

  [✅/⚠️/❌/N/A] CLAUDE.md 크기: [N]줄 [상태 메시지] [confidence tag]
  [✅/⚠️/❌/N/A] Architecture.md 동기화: [상태 메시지] [confidence tag]
  [✅/⚠️/❌/N/A] feature_list.json 일관성: [상태 메시지] [confidence tag]
  [✅/⚠️/❌/N/A] 오래된 교훈: [상태 메시지] [confidence tag]
  [✅/⚠️/❌/N/A] 미사용 스킬: [상태 메시지] [confidence tag]

  종합: [✅/⚠️/❌] [한 줄 요약]

━━ 제안 액션 ━━
[⚠️ 또는 ❌인 항목만 표시]

  1. [구체적 수정 제안 — 무엇을 어떻게] [confidence tag]
  2. [구체적 수정 제안] [confidence tag]
  ...

▶ 적용할 항목 번호를 알려주세요. (예: "1, 3" / "전부" / "패스")
```

**Wait for user response.**

## Step 3: Apply Selected Fixes

Only after user selects specific items:

### Possible fix actions (by check type):

**CLAUDE.md too large:**
- Invoke `/optimize-claude-md` (delegate, don't duplicate)

**Architecture.md drift:**
- Update `(planned)` → `(built)` for completed features
- Add missing built features to the architecture doc
- Present each change for confirmation before writing

**feature_list.json drift:**
- Add missing features from PRD
- Flag orphan depends_on references
- Remove stale plan fields (user confirms each)

**Stale lessons:**
- Present each stale entry: "유지할까요, 삭제할까요?"
- Remove only user-approved entries

**Unused skills:**
- List each unused skill with its purpose
- Suggest: keep (infrequent but valid) or remove (no longer needed)
- Only remove skill directories the user explicitly approves

### After applying:

```
✅ Project Doctor 완료
  - 수정 적용: [N]건
  - 건너뜀: [N]건
  - 상태: [한 줄 요약]
```

## Hard Rules

- **NEVER modify any file without user confirmation.** This is a diagnostic tool first.
- **NEVER delete skill directories without explicit user approval.**
- **NEVER auto-run.** Always user-triggered or user-approved after handoff suggestion.
- **ALWAYS present the report in Korean.**
- **ALWAYS gracefully skip missing files** — mark as N/A, don't error.
- **ALWAYS show the full report before asking for fix selections** — user needs the complete picture.
- **Delegate to existing skills when possible:** CLAUDE.md issues → `/optimize-claude-md`, not manual editing.
