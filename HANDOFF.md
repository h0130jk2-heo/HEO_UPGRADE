<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feat commit this session)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F012 — Confidence tagging (next up, not started)
- **Status**: between-features (F011 completed, F012 queued)
- **Last action**: feature-done for F011 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F011 Project-doctor skill
- ✓ Created `~/.claude/skills/project-doctor/SKILL.md` (5-check health report + user-selectable fix flow)
- ✓ Checks: CLAUDE.md size, Architecture.md drift, feature_list.json↔PRD drift, stale lessons, unused skills
- ✓ Graceful N/A handling for missing files (Architecture.md, CLAUDE.md)
- ✓ Self-applied (dogfood): found PRD.md ↔ feature_list.json drift — 6 features completed but PRD unchecked
- ✓ User approved fix: updated PRD.md F005-F010 checkboxes

### PRD.md sync fix
- ✓ F005-F010 checkboxes updated from `[ ]` to `[x]` (drift discovered by project-doctor dogfood)

### Cumulative components (11 of 16 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement
- ✓ [4] feature-plan skill
- ✓ [5] verify-stack skill
- ✓ [6] feature-done enhancement
- ✓ [10] reflect skill
- ✓ [11] project-doctor skill (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 16 컴포넌트 중 5개 미빌드 -->

### Cross-cutting — 2 remaining
- [ ] **F012** confidence tagging
- [ ] **F013** cost awareness

### Phase 3 (SHIP) — 3 remaining (Could priority)
- [ ] **F014 [7] pre-ship-check**
- [ ] **F015 [8] deploy**
- [ ] **F016 [9] monitor**

## Decisions Made
<!-- 이번 세션 결정 사항 -->
- No significant design decisions this session. F011 followed the ADVANCED_SKELETON.md spec closely.

## Open Questions
<!-- 이전 핸드오프에서 이월 -->
1. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill?
2. **Confidence tagging**: hard convention vs. soft?

## Verification Results
<!-- Phase 2 (Standard tier) -->
- F011 feat commit already verified via feature-done QA pipeline
- SKILL.md exists with valid frontmatter ✓
- Self-apply produced actual health report with real finding ✓
- Missing files handled as N/A (not errors) ✓

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F012 — Confidence tagging**:
   - Cross-cutting convention: `[verified]/[high]/[medium]/[guess]` tags on framework outputs
   - Decide: hard enforcement (skill code checks) vs. soft convention (docs only)
3. **After F012**: F013 Cost awareness, then Phase 3 (SHIP) if desired
