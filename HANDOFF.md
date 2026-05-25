<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feature completed, 1 commit)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F009 — Feature-done enhancement (next up, not started)
- **Status**: between-features (F008 completed, F009 queued)
- **Last action**: feature-done for F008 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F008 Verify-stack skill
- ✓ Created `~/.claude/skills/verify-stack/SKILL.md` (197 lines)
  - 3-layer flow: Security (hard block) → Self-review (confirm) → Cross-model (warn)
  - Security: 6 universal static patterns (secrets, SQLi, XSS, command injection, hardcoded creds, path traversal) + LLM false-positive suppression
  - Self-review: 5-item checklist + confidence score (0-100%)
  - Cross-model: Gemini CLI conditional trigger (diff>100 / confidence<70% / --strict) + graceful degrade when not installed
  - Output: `.claude/verify-report-<feature-id>.md` consumed by feature-done
- ✓ Self-applied (dogfood): ran verify-stack on F008 itself, all layers passed (85% confidence)
- ✓ QA passed (4/4 checks), committed as `feat: F008`

### Cumulative components (8 of 16 built)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement
- ✓ [4] feature-plan skill
- ✓ [5] verify-stack skill (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 16 컴포넌트 중 8개 미빌드 -->

### Phase 2 (BUILD) — 1 remaining
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
- Chose 6 universal static security patterns over language-specific linting. Reason: non-developer projects span multiple languages; universal patterns avoid false-positive explosion.
- Chose conditional cross-model trigger (diff>100 / confidence<70% / --strict) over always-on. Reason: cost awareness — Gemini CLI adds latency and token cost; small diffs don't benefit enough.

## Open Questions
<!-- 이전 핸드오프에서 이월 + 신규 -->
1. **Reflect frequency** (Phase 4): every 5 features, every 10, or on demand only?
2. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill?
3. **Confidence tagging**: hard convention vs. soft?
4. **handoff merge vs overwrite in meta mode**: less relevant now (heo-active), but spec question remains
5. **Skill max-line policy**: verify-stack 197 lines (under 200). init-project 370 (orchestrator exception?). handoff 353.

## Verification Results
<!-- Phase 2 (Standard tier) -->
- `verify-stack/SKILL.md` — exists, valid frontmatter, 197 lines ✓
- `feature_list.json` — valid JSON, F008 has plan field + passes: true ✓
- verify-report self-apply — generated and consumed successfully ✓
- instincts.md — self-apply pattern upgraded to confidence: high (2 observations) ✓

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F009 — Feature-done enhancement**:
   - Consume `.claude/verify-report-<feature-id>.md` as QA evidence
   - Add visual check for UI features (browser screenshot + PRD comparison)
   - Record successes (not just failures) to feed `/reflect`
   - Update feature-done SKILL.md (currently 184 lines — budget ~16 lines for additions)
3. **Optional**: resolve Open Question #1 (reflect frequency) since F010 is next after F009
