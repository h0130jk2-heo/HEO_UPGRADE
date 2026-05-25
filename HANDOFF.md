<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feat commit this session)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F014 — Pre-ship-check skill (next up, not started)
- **Status**: between-features (F013 completed, F014 queued)
- **Last action**: feature-done for F013 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F013 Cost awareness
- ✓ Created `~/.claude/rules/cost-awareness.md` (global rule: cost estimation convention, small/medium/large sizing, cost-log.jsonl format)
- ✓ Updated `~/.claude/skills/verify-stack/SKILL.md` — Cost Estimate section before Layer 3 + Cost Log section
- ✓ Updated `~/.claude/skills/architecture-sketch/SKILL.md` — Cost Estimate section before Step 1
- ✓ Updated `~/.claude/skills/reflect/SKILL.md` — Cost Estimate section before Preconditions
- ✓ Cross-cutting convention instinct upgraded: low → medium (2nd observation: F012 + F013 same pattern)

### Cumulative components (13 of 16 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement
- ✓ [4] feature-plan skill
- ✓ [5] verify-stack skill
- ✓ [6] feature-done enhancement
- ✓ [10] reflect skill
- ✓ [11] project-doctor skill
- ✓ [12] confidence tagging
- ✓ [13] cost awareness (NEW this session)
- ✓ [14] handoff skill v1.1
- ✓ [15] resume-heo skill

## What's Left
<!-- 남은 일 — 16 컴포넌트 중 3개 미빌드 (전부 Could priority) -->

### Phase 3 (SHIP) — 3 remaining (Could priority)
- [ ] **F014 [7] pre-ship-check**
- [ ] **F015 [8] deploy**
- [ ] **F016 [9] monitor**

## Decisions Made
<!-- 이번 세션 결정 사항 -->
- F013: Chose global rule file + skill template update approach (same pattern as F012). Reason: instincts confirmed this cross-cutting pattern works — global rule defines convention, skill templates enforce it at output point.
- F013: Applied cost estimates only to "cost-notable" skills (verify-stack, architecture-sketch, reflect), not all skills. Reason: avoid user fatigue from excessive cost warnings on lightweight operations.

## Open Questions
<!-- 미해결 질문 -->
1. **PRD.md drift**: F011, F012, F013 checkboxes still unchecked in PRD.md — run `/project-doctor` to fix
2. **Phase 3 (SHIP) scope**: F014-F016 are all Could priority — user may choose to skip entirely if project doesn't deploy

## Verification Results
<!-- Phase 2 (Standard tier) -->
- F013 feat commit already verified via feature-done QA pipeline
- cost-awareness.md exists with cost estimation convention + cost-log.jsonl format ✓
- 3 skill SKILL.md files have Cost Estimate sections ✓
- Lightweight skills correctly excluded from cost warnings ✓

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Decide on Phase 3 (SHIP)**:
   - F014-F016 are Could priority — only needed if this framework project actually deploys
   - If skipping SHIP: consider running `/project-doctor` to fix PRD drift, then `/reflect` for pattern review
3. **If proceeding with SHIP**: Start F014 — Pre-ship-check skill
