<!-- HEO_UPGRADE 변경 로그. 영문 본문 + 한글 주석 (HEO 이중언어 규약). 최신 버전이 맨 위. -->
# Changelog

All notable changes to HEO_UPGRADE are recorded here. Newest first.

## v2 — 2026-07-06 — "Brownfield & Rigor Update"

<!-- 브라운필드 진입점 + 앞단(보안·요구사항·NFR) 엄격성 강화. 배포는 프로바이더 중립 유지. -->

v2 deepens HEO's front-loaded rigor and adds a **brownfield entry point** for existing
codebases, while keeping **deployment provider-neutral** (no cloud lock-in) and preserving
HEO conventions (bilingual artifacts, confidence tags, lightweight opt-in gates).

### Added
- **`/reverse-engineer` (NEW skill, SHAPE phase)** — HEO's brownfield entry point. Analyzes
  an existing codebase (that HEO did not scaffold) and produces native HEO artifacts:
  `Architecture.md`, a component/module inventory, and a dependency map. Read-only — never
  modifies source. Includes `references/inventory-template.md`.
  - Files: `framework/skills/reverse-engineer/SKILL.md`,
    `framework/skills/reverse-engineer/references/inventory-template.md`.
  - Tracking: feature **F017**.

### Enhanced
- **`/verify-stack`** — Layer 1 security expanded from **6 static patterns → a 15-item
  app-level security checklist** (`references/security-checklist.md`), loaded on-demand when
  the user passes `--strict` or the PRD is production-grade. Covers secrets, injection, XSS,
  input validation, authentication, session, access control (IDOR), error handling
  (fail-closed), and dependency/supply-chain hygiene. The verify-report `## Summary` structure
  is unchanged (feature-done depends on it). Tracking: feature **F018**.
- **`/prd-creator`** — Added **adaptive depth** (minimal / standard / comprehensive) and
  **conditional User Stories** (with acceptance criteria + MoSCoW traceability) for complex or
  multi-user projects; simple tools auto-skip stories. Kept HEO's 1:1 conversational style.
  Template gained an optional User Stories block. Tracking: feature **F019**.
- **`/architecture-sketch`** — Added a **conditional, provider-neutral NFR-patterns section**:
  performance targets, resilience patterns (timeouts, circuit breaker, graceful degradation,
  health checks), and scalability principles. Surfaced only for M/L or reliability-critical
  projects. No infrastructure, deployment, or cloud-service specifics. Tracking: feature **F020**.
- **`/resume-heo`** — State C (fresh-start) now **detects brownfield projects** (source present
  but no `Architecture.md`/`feature_list.json`) and routes them to `/reverse-engineer`. State C
  and State D were made mutually exclusive (State D excludes the source-present case).

### Design constraints (deliberate exclusions)
<!-- 의도적으로 범위에서 제외한 것들 — HEO의 경량·프로바이더 중립 원칙 유지. -->
- **No cloud/infra lock-in**: multi-region, disaster-recovery strategies, infra-as-code,
  auto-scaling infrastructure, and cloud-service specifics are intentionally out of scope.
  Deployment stays provider-neutral and is owned by HEO's `/deploy` and `/monitor`.
- **Kept HEO's lightweight gates**: opt-in gates and confidence tags rather than heavy
  per-stage approval ceremony or mandatory audit logging.

### Docs & tracking
- `README.md`: skills 16 → 17 (new `/reverse-engineer` row + updated enhanced-skill
  descriptions), added "What's New in v2", version marker, and this changelog link.
- `docs/index.html`: v2 badge, skills table synced to 17, enhanced descriptions updated, new
  "변경 이력 — v2" section, counts reconciled (17 skills / 20 features).
- `feature_list.json`: added F017–F020 (all `passes:true`).
- Fixed a pre-existing stray-character typo in `prd-creator/SKILL.md`.

### Engineering notes
- Built via brainstorming → spec → plan → subagent-driven execution (6 tasks, each with a
  per-task review, plus a final whole-branch review).
- All 5 touched `SKILL.md` files stay within the ≤ 220-line budget.

---

## v1 — 2026-05-26 — Initial framework build

<!-- 최초 프레임워크 완성본 (10 세션). -->

- 16 skills across 4 phases (SHAPE / BUILD / SHIP / EVOLVE) + 4 cross-cutting layers
  (memory & learning loop, confidence tagging, cost awareness, bilingual artifacts).
- 16/16 features `passes:true` over 10 sessions.
