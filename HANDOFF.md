<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feature completed, 1 commit)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F007 — Feature-plan skill (next up, not started)
- **Status**: between-features (F006 completed, F007 queued)
- **Last action**: feature-done for F006 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F006 Init-project enhancement
- ✓ Added ARCHITECTURE_PROPOSAL.md consumption logic to `init-project/SKILL.md`
  - Step 1b: reads and extracts Recommended Stack, Project Structure, Data Flow, Technical Decisions
  - Step 2: Tech Stack section now uses architecture data (6 concrete fields: Runtime/Framework/Language/Styling/Data/Deployment)
  - Step 3.5: Folder Layout and Data Flow sourced from architecture proposal
  - Step 8a: deletes ARCHITECTURE_PROPOSAL.md after consuming (content lives in CLAUDE.md + Architecture.md)
- ✓ Designed and built language pack system (Step 6):
  - Detection logic: ARCHITECTURE_PROPOSAL.md → PRD → user prompt
  - 3 packs created in `~/.claude/skills/init-project/packs/`:
    - `typescript.md` (29 lines) — strict TS, ESM, patterns, pitfalls, deps
    - `python.md` (30 lines) — type hints, dataclass, EAFP, pitfalls
    - `powershell.md` (31 lines) — Verb-Noun, COM cleanup, pipeline, comparison ops
  - Multi-language support: installs all matching packs
  - Collision handling: won't overwrite existing rules without asking
- ✓ Updated frontmatter description to mention new capabilities
- ✓ QA passed (6/6 checks), committed as `feat: F006`

### Cumulative components (6 of 14 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 14 컴포넌트 중 8개 미빌드 + cross-cutting 2개 -->

### Phase 2 (BUILD) — 3 remaining
- [ ] **F007 [4] feature-plan** — live per-feature plan reading Architecture + lessons-learned + instincts
- [ ] **F008 [5] verify-stack** — self-review + security + cross-model (Gemini)
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
- Chose **delete ARCHITECTURE_PROPOSAL.md** after consumption (over keeping for reference). Reason: core content migrates to CLAUDE.md + Architecture.md; keeping the original creates stale duplication.
- Chose **all 3 language packs** (TS/JS + Python + PowerShell) for F006 scope. Reason: user uses all three; Rust/Go deferred as before.

## Open Questions
<!-- 이전 핸드오프에서 이월 + 해결된 것 표시 -->

### Resolved this session
- ~~#4 Language pack priority~~ → all 3 (TS/JS + Python + PowerShell)

### Still open
1. **Reflect frequency** (Phase 4): every 5 features, every 10, or on demand only?
2. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill?
3. **Confidence tagging**: hard convention vs. soft?
4. **handoff merge vs overwrite in meta mode**: less relevant now (heo-active), but spec question remains
5. **Skill max-line policy**: init-project now 370 lines (orchestrator exception?). handoff 353, architecture-sketch 215.

## Verification Results
<!-- Phase 2 (Standard tier) -->
- `feature_list.json` — valid JSON ✓
- Language packs — all 3 files exist with correct structure ✓
- Field consistency — architecture-sketch output fields match init-project input fields ✓
- No verify-stack available yet (F008) — skipped deeper review

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F007 — Feature-plan skill**:
   - Design: live per-feature plan that reads Architecture.md + lessons-learned + instincts + recent commits
   - Key output: `plan` field in feature_list.json (replaces static `steps[]`)
   - Decide: should feature-plan be invoked automatically by resume-heo, or manually by user?
3. **Optional**: resolve Open Question #1 (reflect frequency) if it affects F007 design
