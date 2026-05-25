<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Advanced (4 feat commits this session)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F011 — Project-doctor skill (next up, not started)
- **Status**: between-features (F010 completed, F011 queued)
- **Last action**: feature-done for F010 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F010 Reflect skill
- ✓ Created `~/.claude/skills/reflect/SKILL.md` (134 lines, 4-step flow: Collect → Analyze → Confirm → Apply)
- ✓ Confidence upgrade logic: low→medium (2+ observations), medium→high (3+)
- ✓ Duplicate merge, cross-pollination, stale entry detection (90 days)
- ✓ On-demand trigger + every-5th-feature suggestion (Open Question #1 resolved)
- ✓ Self-applied (dogfood): ran reflect on 2 existing instincts entries, found 1 confidence upgrade candidate
- ✓ User confirmed before any instincts.md modification (core safety check validated)

### Skill line limit removal
- ✓ User identified 200-line per-skill cap had no Karpathy basis (applies to CLAUDE.md only, not on-demand skill files)
- ✓ Updated ADVANCED_SKELETON.md: removed "200-line per-skill cap enforced" from risks, updated success criteria
- ✓ Updated instincts.md: clarified line budget entry scope to CLAUDE.md only
- ✓ Added new instinct: trace constraint origins before enforcing them

### Cumulative components (10 of 16 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement
- ✓ [4] feature-plan skill
- ✓ [5] verify-stack skill
- ✓ [6] feature-done enhancement
- ✓ [10] reflect skill (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 16 컴포넌트 중 6개 미빌드 -->

### Phase 4 (EVOLVE) — 1 remaining
- [ ] **F011 [11] project-doctor** — health check

### Cross-cutting — 2 remaining
- [ ] **F012** confidence tagging
- [ ] **F013** cost awareness

### Phase 3 (SHIP) — 3 remaining (Could priority)
- [ ] **F014 [7] pre-ship-check**
- [ ] **F015 [8] deploy**
- [ ] **F016 [9] monitor**

## Decisions Made
<!-- 이번 세션 결정 사항 -->
- Chose on-demand + every-5th-feature suggestion over fixed-interval reflect. Reason: non-developer user controls when to reflect; gentle nudge avoids overhead.
- Removed 200-line per-skill cap. Reason: Karpathy's 200-line recommendation applies to CLAUDE.md (always loaded) not skill files (on-demand loaded).

## Open Questions
<!-- 이전 핸드오프에서 이월 + 해소 현황 -->
1. ~~**Reflect frequency** (Phase 4)~~ — RESOLVED: on-demand + every 5th feature suggestion
2. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill?
3. **Confidence tagging**: hard convention vs. soft?
4. ~~**Skill max-line policy**~~ — RESOLVED: no hard cap for skills (on-demand load); CLAUDE.md keeps 200-line limit

## Verification Results
<!-- Phase 2 (Advanced tier) -->
- Only uncommitted change: `.claude/settings.local.json` (auto-config, not verify target)
- reflect/SKILL.md — exists, valid frontmatter, 4-step flow present ✓
- Self-apply — pattern analysis produced, user confirmation gate working ✓
- instincts.md — 3 entries (1 updated scope, 1 new), format preserved ✓

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F011 — Project-doctor skill**:
   - Health check: CLAUDE.md size, Architecture.md drift, feature_list.json drift, stale lessons, unused skills
   - Output: health report + suggested fixes (user picks which to apply)
3. **After F011**: Phase 4 (EVOLVE) complete. Move to cross-cutting (F012 confidence tagging, F013 cost awareness)
