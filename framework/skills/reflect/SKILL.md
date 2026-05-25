---
name: reflect
description: Periodic instinct extraction from failures AND successes. Use when the user calls /reflect, says "패턴 정리", "인사이트 뽑아줘", "reflect", "instinct 정리", "교훈 정리", or after every 5th feature-done (suggest, don't auto-run). Scans instincts.md + lessons-learned.md + recent history, upgrades confidence grades, merges duplicates, and presents findings for user confirmation before committing.
---

# reflect

<!-- 성공/실패 패턴을 주기적으로 추출하고, 신뢰도를 업그레이드하는 스킬. -->
<!-- feature-done이 개별 항목을 기록하고, reflect가 패턴을 발견·승격·병합한다. -->

## Overview

Extracts patterns from accumulated successes (instincts.md) and failures (lessons-learned.md). Upgrades confidence grades based on observation count, merges duplicate entries, and presents findings for user confirmation before writing.

**Trigger:** On-demand (`/reflect`) or suggested by feature-done every 5th completed feature.
**Never auto-writes.** All changes require user approval.

## Cost Estimate

<!-- 비용 추정: 여러 파일 스캔 + 히스토리 분석 -->

Before starting, show:

```
💰 예상 비용: 컨텍스트 [소/중/대] (instincts + lessons-learned + git log + progress 스캔). 진행할까요?
```

Context size = total lines across all sources. After skill completes, append to `.claude/cost-log.jsonl` per `~/.claude/rules/cost-awareness.md`.

## Preconditions

At least one of these must have content:
- `~/.claude/rules/instincts.md`
- `~/.claude/rules/lessons-learned.md`
- `progress.md` in current project

If all are empty → "분석할 데이터가 아직 없어요. 기능을 몇 개 완료한 후 다시 시도해주세요."

## Step 1: Collect Data (silent)

Read all available sources. Missing files are fine — work with what exists.

| Source | What to extract |
|---|---|
| `~/.claude/rules/instincts.md` | All entries — note confidence level and observation count |
| `~/.claude/rules/lessons-learned.md` | All entries — failure patterns |
| `progress.md` | Completed features timeline |
| `git log --oneline -20` | Recent commit patterns |
| `feature_list.json` | Feature count (passes: true vs false) |

## Step 2: Analyze Patterns (silent)

### 2a. Confidence Upgrade

Scan instincts.md entries. For each entry:
- Count how many times the **same pattern** appears across all sources (instincts entries, lessons-learned entries, commit patterns, progress entries referencing similar approaches)
- **Same pattern** = same underlying principle, even if the specific project/feature differs

Upgrade rules:
| Current | Observations | New |
|---|---|---|
| low (1회) | 2nd observation found | **medium** |
| medium (2회) | 3rd+ observation found | **high** |
| high | Already max | no change |

### 2b. Duplicate Merge

Find entries in instincts.md describing the same underlying pattern (different wording, same lesson). Propose merging into one entry that captures both observations.

### 2c. Cross-pollination

Check if any lessons-learned entry (failure) has a corresponding instincts entry (success) on the same topic. If a failure was later resolved by a pattern that became an instinct, note this — the instinct is validated by both failure and success evidence.

### 2d. Stale Entry Detection

Flag entries older than 90 days that haven't been re-observed. Don't auto-remove — just flag for user review.

## Step 3: Present Findings

<!-- 반드시 한국어로, 항목별로 유저 확인 받기 -->

Present findings grouped by action type:

```
🔍 Reflect 분석 결과

━━ 신뢰도 업그레이드 ━━
[있을 때만]
  1. "[패턴 요약]"
     현재: confidence: [current] → 제안: confidence: [new]
     근거: [어디서 재관찰됐는지]

━━ 중복 병합 제안 ━━
[있을 때만]
  1. 기존 항목 2개:
     - "[항목 A 요약]"
     - "[항목 B 요약]"
     → 병합 제안: "[통합된 한 줄]"

━━ 새 패턴 발견 ━━
[있을 때만]
  1. "[새로 발견된 패턴]"
     근거: [어디서 발견됐는지]
     제안 confidence: low

━━ 오래된 항목 ━━
[있을 때만]
  1. "[90일 이상 재관찰 없는 항목]"
     → 유지 / 삭제?

변경 없음이면:
  "현재 패턴들이 잘 유지되고 있어요. 특별한 변경 사항 없습니다."
```

**Wait for user response.** Options:
- 전체 승인 ("다 좋아", "적용해")
- 항목별 선택 ("1번만", "2번 빼고")
- 수정 요청 ("1번은 이렇게 바꿔줘")
- 취소 ("됐어", "패스")

## Step 4: Apply Changes

Only after user confirmation:

### 4a. Update instincts.md
- Upgrade confidence levels as approved
- Merge duplicates as approved
- Add new patterns as approved
- Remove stale entries as approved
- Preserve the file header and format convention

### 4b. Update lessons-learned.md
- If a lesson was cross-pollinated into an instinct (validated by success), note it
- Don't remove lessons — they serve a different purpose

### 4c. Summary
```
✅ Reflect 완료
  - 신뢰도 업그레이드: [N]건
  - 중복 병합: [N]건
  - 새 패턴 추가: [N]건
  - 오래된 항목 정리: [N]건
```

## Integration: feature-done Auto-suggest

feature-done does NOT invoke reflect directly. Instead, after every 5th feature completion (count features with `passes: true` in feature_list.json), feature-done adds a suggestion line:

> "💡 기능 5개 완료! `/reflect`로 패턴을 정리해볼까요?"

The user decides whether to run it. This keeps reflect on-demand with gentle nudges.

## Hard Rules

- **NEVER modify instincts.md or lessons-learned.md without user confirmation.**
- **NEVER auto-run.** Always user-triggered or user-approved after suggestion.
- **NEVER fabricate observations.** Only count what's actually in the data sources.
- **NEVER remove lessons-learned entries** — they record failures and serve a different purpose than instincts.
- **ALWAYS present findings in Korean.**
- **ALWAYS preserve file format conventions** (header comments, date prefix, confidence suffix).
