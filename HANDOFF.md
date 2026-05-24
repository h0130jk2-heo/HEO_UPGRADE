<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feature completed, 2 commits)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F006 — Init-project enhancement (next up, not started)
- **Status**: between-features (F005 completed, F006 queued)
- **Last action**: feature-done for F005 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### Dogfood setup (meta → heo-active transition)
- ✓ Created `PRD.md` for HEO_UPGRADE framework (16 features, MoSCoW)
- ✓ Created `feature_list.json` (F001-F004 passes:true, F005-F016 passes:false)
- ✓ `git init` + initial commit — project now in heo-active mode
- ✓ Explained "dogfooding" concept to user

### F005 Architecture-sketch skill
- ✓ Built `~/.claude/skills/architecture-sketch/SKILL.md` (215 lines)
- ✓ Design: reads PRD → recommends architecture (strengths-first) → surfaces max 2 direction-level choices → saves ARCHITECTURE_PROPOSAL.md
- ✓ Key principle: direction-level choices (platform, data, complexity) surfaced to user; engineering details (framework, build tool) decided silently
- ✓ Updated `prd-creator/SKILL.md` closing line to reference `/architecture-sketch` as next step
- ✓ QA passed (6/6 checks), committed as `feat: F005`

### Cumulative components (5 of 14 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 14 컴포넌트 중 9개 미빌드 + cross-cutting 2개 -->

### Phase 1 (SHAPE) — 1 remaining
- [ ] **F006 [3] init-project enhancement** — consume ARCHITECTURE_PROPOSAL.md; language packs

### Phase 2 (BUILD) — 3 remaining
- [ ] **F007 [4] feature-plan** — live per-feature plan
- [ ] **F008 [5] verify-stack** — self-review + security + cross-model
- [ ] **F009 [6] feature-done enhancement** — verify-report + visual check + record successes

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
- Chose **dogfood** (PRD + feature_list.json for HEO_UPGRADE itself) over continuing in meta mode. Reason: enables heo-active mode for real feature tracking with handoff/feature-done.
- Confirmed **architecture-sketch as separate skill** (not inlined into init-project). Reason: explicit user review gate before scaffolding.

## Open Questions
<!-- 이전 핸드오프에서 이월 + 해결된 것 표시 -->

### Resolved this session
- ~~#5 architecture-sketch separate vs inlined~~ → separate (confirmed)
- ~~#6 dogfood HEO_UPGRADE on itself~~ → yes (implemented)

### Still open
1. **Reflect frequency** (Phase 4): every 5 features, every 10, or on demand only?
2. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill?
3. **Confidence tagging**: hard convention vs. soft?
4. **Language packs priority** (init-project F006): TS/JS + Python + PowerShell recommended; Rust/Go deferred
5. **handoff merge vs overwrite in meta mode**: less relevant now (heo-active), but spec question remains
6. **Skill max-line policy**: handoff 353 lines, architecture-sketch 215 lines — accept orchestrators as exceptions?

## Verification Results
<!-- Phase 2 (Standard tier) -->
- `feature_list.json` — valid JSON ✓
- `PostToolUse.sh` — `bash -n` syntax check passed ✓
- No verify-stack available yet (F008) — skipped deeper review

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F006 — Init-project enhancement**:
   - Read current `init-project/SKILL.md` to understand existing behavior
   - Add ARCHITECTURE_PROPOSAL.md consumption logic
   - Design language pack system (`.claude/rules/<lang>.md`)
   - Decide on Open Question #4 (language pack priority: which languages first)
3. **Optional**: resolve Open Question #1 (reflect frequency) if it affects F006 design
