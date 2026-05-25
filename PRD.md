<!-- HEO_UPGRADE 프레임워크 자체의 PRD. dogfooding용. -->
<!-- 본문 영어 + 한글 주석. -->

# PRD — HEO_UPGRADE Framework

## 1. Problem Statement
<!-- 문제 정의 -->

Non-developer users building software with Claude Code lack systematic quality gates, session continuity, and learning loops. The current 5-skill setup (prd-creator, init-project, feature-done, optimize-claude-md, find-skills) covers the happy path but misses architecture review, multi-layer verification, session handoff, and cross-project learning.

## 2. Target User
<!-- 대상 사용자 -->

A single non-developer user (Heo) who builds software projects using Claude Code as the primary engineering tool. The framework must be opinionated on engineering so the user can focus on product decisions.

## 3. Solution Overview
<!-- 솔루션 개요 -->

A 4-phase skill framework (SHAPE → BUILD → SHIP → EVOLVE) with 14 skills and 4 cross-cutting layers. Each phase outputs named artifacts the user can inspect. Skills auto-chain where possible; user manually triggers phase entry points.

Authoritative spec: `ADVANCED_SKELETON.md`

## 4. Feature List (MoSCoW)
<!-- 기능 목록 -->

### Must Have
- [x] F001 — Checkpoint hook (PostToolUse counter, every 5 edits)
- [x] F002 — Brainstorm skill (divergent → convergent → BRAINSTORM.md)
- [x] F003 — Handoff skill v1.1 (5-phase session-end, 4 modes, 3 tiers)
- [x] F004 — Resume-heo skill (4-state session-start router)
- [x] F005 — Architecture-sketch skill (ARCHITECTURE_PROPOSAL.md output)
- [x] F006 — Init-project enhancement (consume ARCHITECTURE_PROPOSAL.md + language packs)
- [x] F007 — Feature-plan skill (live per-feature plan from current state)
- [x] F008 — Verify-stack skill (self-review + security + cross-model)
- [x] F009 — Feature-done enhancement (verify-report consumption + visual check)

### Should Have
- [x] F010 — Reflect skill (periodic instinct extraction)
- [ ] F011 — Project-doctor skill (health check)
- [ ] F012 — Confidence tagging (cross-cutting convention + enforcement)
- [ ] F013 — Cost awareness (cross-cutting estimation + logging)

### Could Have
- [ ] F014 — Pre-ship-check skill
- [ ] F015 — Deploy skill (with rollback)
- [ ] F016 — Monitor skill

## 5. Success Criteria
<!-- 성공 기준 -->

- All Must/Should features `passes: true`
- Framework dogfooded on itself (this project) without breaking
- At least 1 real project built end-to-end using the framework after completion
- `instincts.md` has ≥ 5 entries by framework completion
- Total skill count ≤ 16 (currently 14 planned)

## 6. Out of Scope
<!-- 범위 밖 -->

- Multi-user collaboration features
- IDE-specific integrations beyond Claude Code CLI
- Notification bridges (Telegram/Discord/Slack)
- TDD as mandatory discipline
- Role cosplay (PM/CEO/Eng)
