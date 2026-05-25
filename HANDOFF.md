<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->

# Handoff — 2026-05-25

## Mode + Tier
- **Mode**: heo-active (git + feature_list.json)
- **Tier**: Advanced (3 feat commits this session)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Feature**: ALL COMPLETE — 16/16 features passes: true
- **Status**: framework-complete
- **Last action**: /reflect (instinct upgrades) + /project-doctor (PRD sync)

## What's Done This Session
<!-- 이번 세션에서 한 일 -->

### F014 Pre-ship-check skill
- ✓ Created `~/.claude/skills/pre-ship-check/SKILL.md` — 5-check ship-readiness diagnostic
- ✓ Checks: all features pass / unresolved warnings / secrets / docs / deploy target
- ✓ Self-applied on HEO_UPGRADE project (dogfood validated)

### F015 Deploy skill
- ✓ Created `~/.claude/skills/deploy/SKILL.md` — 4-phase deploy flow
- ✓ Platform auto-detection (Vercel/Netlify/Docker/npm/Make/PyPI)
- ✓ deploy-history.json schema with rollback registration
- ✓ pre-ship-check integration (suggest before deploy)

### F016 Monitor skill
- ✓ Created `~/.claude/skills/monitor/SKILL.md` — 3-phase post-deploy health check
- ✓ Reachability check (HTTP + platform-specific)
- ✓ Rollback suggestion with double-confirm flow
- ✓ deploy-history.json consumption for URL + rollback command

### Maintenance
- ✓ /project-doctor — PRD.md 6 checkboxes synced (F011-F016 → [x])
- ✓ /reflect — 2 confidence upgrades (dogfood diagnostics low→high, diagnostic pattern reuse low→medium) + 1 merge (self-apply entries consolidated)

### Cumulative components (16 of 16 built — COMPLETE)
<!-- 누적 빌드 현황 -->
- ✓ [0] checkpoint hook — PostToolUse.sh + session-start.sh
- ✓ [1] brainstorm skill
- ✓ [2] architecture-sketch skill
- ✓ [3] init-project enhancement
- ✓ [4] feature-plan skill
- ✓ [5] verify-stack skill
- ✓ [6] feature-done enhancement
- ✓ [7] pre-ship-check skill (NEW this session)
- ✓ [8] deploy skill (NEW this session)
- ✓ [9] monitor skill (NEW this session)
- ✓ [10] reflect skill
- ✓ [11] project-doctor skill
- ✓ [12] confidence tagging
- ✓ [13] cost awareness
- ✓ [14] handoff skill v1.1
- ✓ [15] resume-heo skill

## What's Left
<!-- 프레임워크 자체는 완성. 남은 건 실전 검증. -->

### Framework complete — next steps are usage, not building
- [ ] First real project end-to-end using the full framework
- [ ] Verify success criteria from ADVANCED_SKELETON.md §12
- [ ] Optional: README.md for the framework (if sharing)

## Decisions Made
<!-- 이번 세션 결정 사항 -->
- Built all 3 SHIP phase skills (F014-F016) in one session. Reason: data flow between them (deploy-history.json shared by deploy→monitor, pre-ship-check→deploy) made sequential build more consistent for integration.
- Chose project-doctor pattern (silent check → report → user picks) for pre-ship-check. Reason: diagnostic skills should share UX pattern to minimize user learning cost.
- Deploy skill designed as action skill (vs. diagnostic) with mandatory user confirmation. Reason: deploys are irreversible; safety > convenience.

## Open Questions
<!-- 미해결 질문 -->
1. No CLAUDE.md in this meta-project — expected? (Framework builds skills in ~/.claude/, not in project root)
2. No Architecture.md — acceptable for a skill framework, but could be useful for onboarding

## Verification Results
<!-- Phase 2 (Advanced tier) -->
- F014, F015, F016 all passed feature-done QA pipeline
- All 3 SKILL.md files have valid frontmatter + required sections
- /project-doctor: all checks pass after PRD sync
- /reflect: instincts.md updated (7 entries: 2 high, 2 medium, 3 low)

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->
1. **Read this HANDOFF.md** — `session-start.sh` will show summary
2. **Framework is COMPLETE** — all 16/16 features built and passing
3. **Next milestone: first real project** — pick an idea and run the full SHAPE→BUILD→SHIP flow
4. **Optional cleanup**: add README.md, run `/optimize-claude-md` on future projects
