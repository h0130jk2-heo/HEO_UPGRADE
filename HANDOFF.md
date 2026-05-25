<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feature completed, 1 commit)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F008 — Verify-stack skill (next up, not started)
- **Status**: between-features (F007 completed, F008 queued)
- **Last action**: feature-done for F007 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F007 Feature-plan skill
- ✓ Created `~/.claude/skills/feature-plan/SKILL.md` (144 lines)
  - 6-step flow: Read context → Analyze → Present plan → Confirm → Save → Implement
  - Reads: feature_list.json, Architecture.md, lessons-learned.md, instincts.md, HANDOFF.md, recent git log
  - Outputs: `plan` field in feature_list.json (files_to_touch, steps, risks, verification, complexity)
  - Presented plan in Korean, waits for user confirmation before implementation
- ✓ Updated resume-heo for auto-invoke:
  - State A (mid-feature): auto-invokes feature-plan after user confirms continuation
  - State B (between-features): auto-invokes feature-plan after user confirms next feature
  - Hard Rule updated: feature-plan auto-invoke allowed after user confirmation
- ✓ Self-applied (dogfood): F007's own plan saved to feature_list.json as validation
- ✓ QA passed (4/4 checks), committed as `feat: F007`

### Cumulative components (7 of 16 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement
- ✓ [4] feature-plan skill (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 16 컴포넌트 중 9개 미빌드 -->

### Phase 2 (BUILD) — 2 remaining
- [ ] **F008 [5] verify-stack** — self-review + security (static+LLM) + cross-model (Gemini); tiered failure modes
- [ ] **F009 [6] feature-done enhancement** — verify-report consumption + visual check + record successes

### Phase 4 (EVOLVE) — 2 remaining
- [ ] **F010 [10] reflect** — periodic instinct extraction
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
- Chose **auto-invoke** over manual for feature-plan from resume-heo. Reason: reduces friction — user already confirmed the feature, no need for a second "plan it?" prompt.

## Open Questions
<!-- 이전 핸드오프에서 이월 -->
1. **Reflect frequency** (Phase 4): every 5 features, every 10, or on demand only?
2. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill?
3. **Confidence tagging**: hard convention vs. soft?
4. **handoff merge vs overwrite in meta mode**: less relevant now (heo-active), but spec question remains
5. **Skill max-line policy**: feature-plan 144 lines (under 200). init-project 370 (orchestrator exception?). handoff 353.

## Verification Results
<!-- Phase 2 (Standard tier) -->
- `feature_list.json` — valid JSON, F007 has plan field ✓
- `feature-plan/SKILL.md` — exists, valid frontmatter, 144 lines ✓
- `resume-heo/SKILL.md` — auto-invoke references present (lines 99, 117) ✓
- No verify-stack available yet (F008) — skipped deeper review

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F008 — Verify-stack skill**:
   - Design: 3 sub-layers (security hard-block, self-review confirm, cross-model warn)
   - Key output: `.claude/verify-report-<feature-id>.md` (consumed by feature-done)
   - Decide: Gemini CLI dependency — graceful degrade when not installed?
   - Decide: static security rules — which rules to include for non-developer projects?
3. **Optional**: resolve Open Question #1 (reflect frequency) if it affects F008 design
