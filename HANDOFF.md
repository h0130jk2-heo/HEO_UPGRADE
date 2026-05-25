<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feature completed, 1 commit)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F010 — Reflect skill (next up, not started)
- **Status**: between-features (F009 completed, F010 queued)
- **Last action**: feature-done for F009 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F009 Feature-done enhancement
- ✓ Added Step 1-B: verify-report consumption (FIX_REQUIRED → block, PROCEED → continue, missing → skip)
- ✓ Enhanced Step 2 QA: UI/visual check for features mentioning UI/HTML/web (browser compare + graceful skip)
- ✓ Added Step 5: success recording to `~/.claude/rules/instincts.md` (confidence: low, upgradeable by /reflect)
- ✓ Line budget managed: 206→196 lines (compressed existing bullet lists into single paragraphs)
- ✓ Self-applied (dogfood): ran feature-done on F009 itself, all new steps exercised
- ✓ QA passed (6/6 checks), committed as `feat: F009`

### Cumulative components (9 of 16 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement
- ✓ [4] feature-plan skill
- ✓ [5] verify-stack skill
- ✓ [6] feature-done enhancement (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 16 컴포넌트 중 7개 미빌드 -->

### Phase 4 (EVOLVE) — 2 remaining
- [ ] **F010 [10] reflect** — periodic instinct extraction from failures AND successes
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
- Chose single-paragraph compression over multi-bullet format for Step 1-B. Reason: line budget (200 max) required concise expression; single paragraph saved 5 lines without losing information.

## Open Questions
<!-- 이전 핸드오프에서 이월 + 신규 -->
1. **Reflect frequency** (Phase 4): every 5 features, every 10, or on demand only?
2. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill?
3. **Confidence tagging**: hard convention vs. soft?
4. **Skill max-line policy**: verify-stack 197, feature-done 196. init-project 370 (orchestrator exception?). handoff 353.

## Verification Results
<!-- Phase 2 (Standard tier) -->
- `feature-done/SKILL.md` — 196 lines, 3 new sections present ✓
- `feature_list.json` — valid JSON, F009 has plan field + passes: true ✓
- instincts.md — success entry added (line budget pattern, confidence: low) ✓
- Self-apply — feature-done ran on F009 itself: Step 1-B exercised (no report → skip), Step 5 exercised (instincts entry written) ✓

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F010 — Reflect skill**:
   - Periodic instinct extraction from failures AND successes
   - Confidence-graded entries (low → medium → high based on observation count)
   - User confirms before committing instincts
   - Resolve Open Question #1 (reflect frequency) as part of F010 design
3. **Optional**: after F010, F011 (project-doctor) completes Phase 4 (EVOLVE)
