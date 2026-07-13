<!-- HEO_UPGRADE 변경 로그. 영문 본문 + 한글 주석 (HEO 이중언어 규약). 최신 버전이 맨 위. -->
# Changelog

All notable changes to HEO_UPGRADE are recorded here. Newest first.

## v2.1 — 2026-07-08 — "Design Direction Update"

<!-- 결과물이 "AI 평균값 룩"으로 흐르는 걸 앞단에서 막는 디자인 방향 단계 추가. -->

v2.1 adds the design dimension HEO was missing. The pipeline shaped requirements, tech, and
quality — but never decided **how the product should look**. Since HEO frequently builds
visible artifacts, a committed visual direction now lives in the SHAPE phase, grounded in a
2026 design-judgment reference installed by default.

The design gap has two halves, and both are addressed: a **judgment layer** (deciding a
direction up front, so generation doesn't default to the statistical average) and a **visual
layer** (showing directions as real pictures and checking the built result back against them —
because prose loses to pictures, and a model can't see what it renders). Tokens alone give
consistency without conviction; the picture is what carries the direction from decision to code.

### Added
- **`/design-sketch` (NEW skill, SHAPE phase)** — the visual-direction sibling of
  `architecture-sketch`. Reads the PRD, judges two orthogonal axes — **platform** (web / mobile)
  × **purpose** (landing / dashboard / document / app) — and offers **2–3 distinct directions as
  picture mockups** (not prose: *prose loses to pictures*). The mockups come from a **design
  model**, and **the user chooses one of three routes**: (1) generate directly via a connected
  Pencil (`mcp__pencil__*`) or Google Stitch (`stitch-mcp` / SDK), (2) receive a **ready-to-paste
  prompt per direction** to run in Stitch/Pencil themselves and drop the image into `design-refs/`,
  or (3) let Claude **hand-code an HTML mockup under an anti-generic guardrail** (commit a specific
  §3-checked direction first, ban the defaults, keep 2–3 genuinely distinct stances, define
  light/dark tokens, save to `design-refs/<slug>.html`). The guardrail — not a blanket ban on
  hand-coding — is what prevents free-drawing the average; a committed, checklist-passed HTML
  anchor is often better for non-developers because they can click it. The
  recommendation is **load-bearing** (opinionated
  default + reason + easy override), because the anti-generic effect comes from committing to a
  direction (among directions that passed the distinctiveness check), not from who picks it. Locks concrete design tokens into `DESIGN_PROPOSAL.md` and
  keeps the chosen screen(s) in `design-refs/` as the visual anchor. Loads only the matching
  `platforms/` + `profiles/` files (progressive disclosure). Skips non-visual projects.
  Tracking: **F021**.
  - Files: `framework/skills/design-sketch/SKILL.md`,
    `platforms/{web,mobile}.md`, `profiles/{landing,dashboard,document,app}.md`.
- **`framework/rules/design.md` (NEW rule, always installed)** — a 2026 frontend-design judgment
  baseline available in every project even without the skill. Contains the *AI-is-an-intern*
  meta-principle (AI generates the statistical average — Inter + purple-blue gradient + three
  cards; direction up front is the fix), a universal core (cognitive clarity, motion-as-structure,
  transparent/reversible, accessibility-as-infrastructure, token systems, the four states), a
  **judgment-to-pixels section (§1a)** (prose loses to pictures; commitment over connoisseurship;
  the blind-designer screenshot loop), a two-axis selection guide, an anti-generic checklist, and
  universal anti-patterns. Treated as a static convention rule (updated by `-Force`/`--force`,
  not user data).

### Enhanced
- **`/architecture-sketch`** — after saving, routes UI projects to `/design-sketch` before
  `/init-project`; explicitly scoped to tech/structure only (look-and-feel is owned by
  design-sketch).
- **`/init-project`** — reads `DESIGN_PROPOSAL.md` (Step 1c), scaffolds its design tokens into a
  base stylesheet matched to the styling approach (Tailwind theme / `tokens.css` / `theme.ts` /
  self-contained `<style>`), defining light **and** dark (Step 3.7), **preserves `design-refs/`**
  as the visual anchor, then consumes and deletes the proposal prose (Step 8). Warns—doesn't
  block—when a UI project has no proposal.
- **`/feature-done`** — added **Step 2-V, a visual verification loop** for UI features: render →
  screenshot → compare against `design-refs/` + tokens + `design.md` → regenerate on drift. This
  closes the "blind designer" gap — a model can't see what it renders, so without this the
  committed direction can slip back to the average at the implementation layer. Falls back to a
  structural check when no screenshot tooling exists; skips for non-visual features.

### Design constraints (deliberate)
<!-- 범용 프론트엔드 기준: 대시보드에 한정하지 않음. 취향은 사람이 결정. 접근성은 협상 대상 아님. -->
- **General-purpose, not dashboard-only.** Dashboards are one of four purpose profiles; the rule
  and skill cover landing/document/app equally.
- **Taste stays human.** The skill offers directions and recommends one, but never decides mood or
  brand for the user.
- **Accessibility is non-negotiable** (contrast, keyboard, no color-only meaning, reduced-motion)
  — not presented as a taste option.
- Grounded in 2026 web research (Figma, Envato, Designlab, Shuffle/DEV on AI sameness, Muzli,
  UXPin, LogRocket, and per-type sources cited inside each reference file).

### Docs & tracking
- `README.md`: skills 17 → 18, "What's New in v2.1", version marker → v2.1, new `/design-sketch`
  row, design.md in cross-cutting rules and file structure, Quick Start step.
- `docs/index.html`: v2.1 badge, skills table synced to 18, new changelog section.
- `feature_list.json`: added F021 (`passes:true`).
- Installers unchanged — both already copy `framework/rules/*.md` generically, so `design.md`
  installs automatically.

---

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

### Installer
<!-- 업데이트 시 사용자 학습 데이터 보호. -->
- `install.ps1` / `install.sh` now treat `instincts.md` and `lessons-learned.md` as **user data**:
  they are never overwritten, even with `-Force` / `--force` (created only if absent, shown as
  `KEEP`). This makes updating an existing install safe. Static convention rules
  (`confidence-tags.md`, `cost-awareness.md`) and all skills are still updated by `-Force`.
- Documented the v1 → v2 update flow (`git pull` + `-Force`/`--force` + restart) in README and the HTML docs.

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
