<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Standard (1 feat commit this session)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: F013 — Cost awareness (next up, not started)
- **Status**: between-features (F012 completed, F013 queued)
- **Last action**: feature-done for F012 (QA passed, committed)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F012 Confidence tagging
- ✓ Created `~/.claude/rules/confidence-tags.md` (global rule: 4-tag definition + criteria + examples)
- ✓ Updated `~/.claude/skills/feature-plan/SKILL.md` — tag instructions in output template + quality check
- ✓ Updated `~/.claude/skills/architecture-sketch/SKILL.md` — tags on stack reasoning, alternatives, complexity
- ✓ Updated `~/.claude/skills/verify-stack/SKILL.md` — confidence score → tag mapping (90%→verified, 70%→high, 50%→medium, <50%→guess)
- ✓ Updated `~/.claude/skills/project-doctor/SKILL.md` — tags on diagnosis results + fix suggestions
- ✓ Hard enforcement approach: tag instructions embedded in skill output templates, not just documented

### Cumulative components (12 of 16 built)
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
- ✓ [12] confidence tagging (NEW this session)
- ✓ [13] handoff skill v1.1
- ✓ [14] resume-heo skill

## What's Left
<!-- 남은 일 — 16 컴포넌트 중 4개 미빌드 -->

### Cross-cutting — 1 remaining
- [ ] **F013** cost awareness

### Phase 3 (SHIP) — 3 remaining (Could priority)
- [ ] **F014 [7] pre-ship-check**
- [ ] **F015 [8] deploy**
- [ ] **F016 [9] monitor**

## Decisions Made
<!-- 이번 세션 결정 사항 -->
- F012: Chose hard enforcement (tag instructions in each skill's output template) over soft convention (docs-only). Reason: soft convention relies on Claude remembering to tag — hard enforcement places the instruction where output is generated.

## Open Questions
<!-- 미해결 질문 -->
1. **Cost awareness implementation**: hook? skill output? `/cost-estimate` skill? (carried from previous sessions)
2. **PRD.md drift**: F011 and F012 checkboxes still unchecked in PRD.md — run `/project-doctor` to fix

## Verification Results
<!-- Phase 2 (Standard tier) -->
- F012 feat commit already verified via feature-done QA pipeline
- confidence-tags.md exists with 4 tag definitions ✓
- 4 skill SKILL.md files have tagging instructions ✓
- No conflict with existing instincts.md confidence format ✓
- Self-apply demonstrated tags in session output ✓

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Start F013 — Cost awareness**:
   - Cross-cutting: estimated context size, subagent multiplier, `.claude/cost-log.jsonl`
   - Decide: hook-based? skill output addition? standalone `/cost-estimate` skill?
3. **After F013**: Phase 3 (SHIP) features F014-F016 if desired, all Could priority
