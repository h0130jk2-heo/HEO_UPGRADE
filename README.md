<!-- HEO_UPGRADE 프레임워크 README. 영문 본문 + 한글 주석. -->

# HEO_UPGRADE

<!-- 비개발자를 위한 Claude Code 소프트웨어 빌드 프레임워크 -->

A skill framework for non-developers building software with [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Four phases guide a project from fuzzy idea to deployed product, with quality gates the user doesn't need engineering expertise to operate.

**[HTML Documentation](docs/index.html)** | **[GitHub Repository](https://github.com/h0130jk2-heo/HEO_UPGRADE)** | **[Changelog](CHANGELOG.md)**

> **Version 2.1 (2026-07-08) — "Design Direction Update"**: 1 new skill (`/design-sketch`) + 1 new always-installed rule (`design.md`, a 2026 frontend-design judgment baseline) + 2 enhanced skills. HEO now commits a **visual direction** up front — platform (web/mobile) × purpose (landing/dashboard/document/app) — so builds stop drifting to generic AI defaults. See [What's New in v2.1](#whats-new-in-v21) below.
>
> **Version 2 (2026-07-06) — "Brownfield & Rigor Update"**: 1 new skill + 4 enhanced skills — brownfield codebase adoption, a deeper app-level security checklist, requirements depth with user stories, and provider-neutral NFR patterns. See [What's New in v2](#whats-new-in-v2) below or the full [CHANGELOG](CHANGELOG.md).

## What's New in v2.1

<!-- 디자인 방향 업데이트. 결과물이 "AI 평균값 룩"으로 흐르는 걸 앞단에서 방지. -->

v2.1 closes HEO's biggest remaining gap: nothing in the pipeline decided **how the product
should look**. Since HEO often builds visible artifacts (dashboards, reports, web/mobile UIs),
a committed visual direction now sits in the SHAPE phase, grounded in a 2026 design-judgment
reference that installs by default.

| Skill / Rule | Type | What it adds |
|---|---|---|
| `/design-sketch` | **NEW skill** | SHAPE-phase visual-direction step. Reads the PRD, judges **platform (web/mobile) × purpose (landing/dashboard/document/app)**, and offers 2–3 directions **as picture mockups** via one of **three routes** the user picks: (1) generate directly via a connected Pencil/Google Stitch, (2) receive a ready-to-paste prompt to run in Stitch/Pencil themselves, or (3) let Claude hand-code an HTML mockup **under an anti-generic guardrail** (commit a §3-checked direction first, no defaults, 2–3 distinct stances, light/dark tokens). The guardrail — not a blanket ban on hand-coding — is what prevents free-drawing the average, and a clickable HTML anchor is often better for non-developers. The recommendation is **load-bearing** (opinionated default + easy override) — committing to a direction is what beats the average, not who picks it. Outputs `DESIGN_PROPOSAL.md` (tokens) + keeps the chosen screen in `design-refs/` as the visual anchor. Skips non-visual projects. |
| `design.md` | **NEW rule** | Always-installed frontend-design judgment baseline (2026): the *AI-is-an-intern* meta-principle, a universal core (clarity, motion-as-structure, transparent/reversible, accessibility, tokens), a **judgment-to-pixels section** (prose loses to pictures; the blind-designer screenshot loop), a two-axis selection guide, and an anti-generic checklist. Backed by `platforms/` + `profiles/` reference files loaded on demand. |
| `/architecture-sketch` | Enhanced | Hands off to `/design-sketch` for UI projects; explicitly leaves look-and-feel to it (tech/structure only). |
| `/init-project` | Enhanced | Consumes `DESIGN_PROPOSAL.md`, scaffolds design tokens into a base stylesheet (Tailwind theme / `tokens.css` / `theme.ts` / self-contained `<style>`) in light **and** dark, and preserves `design-refs/` as the visual anchor. |
| `/feature-done` | Enhanced | Adds a **visual verification loop** (Step 2-V) for UI features: render → screenshot → compare against `design-refs/` + tokens → regenerate on drift. Closes the "blind designer" gap so the committed direction survives to the built product. |

**The gap, in one line:** the judgment layer (decide a direction up front) plus the **visual layer** (show it as pictures, and check the build back against them) — because tokens give consistency without conviction, and a model can't see what it renders.

**Counts:** skills 17 → 18; features 20 → 21 (F021). Tracking: feature **F021**.

## What's New in v2

<!-- v2 변경 이력. 브라운필드 진입점 + 앞단 엄격성 강화. 배포는 프로바이더 중립 유지. -->

v2 deepens HEO's front-end rigor and adds a **brownfield entry point** for existing codebases, while keeping **deployment provider-neutral** (no cloud lock-in) and preserving HEO conventions (bilingual artifacts, confidence tags, lightweight opt-in gates).

| Skill | Type | Before → After |
|---|---|---|
| `/reverse-engineer` | **NEW** | *(did not exist)* → Analyzes an existing codebase → `Architecture.md` + component inventory + dependency map. Read-only. Wired into `/resume-heo` State C so inherited projects have a brownfield entry point. |
| `/verify-stack` | Enhanced | Security = 6 static patterns → **15-item app-level checklist** (`references/security-checklist.md`), opt-in via `--strict` or a production-grade PRD. Cloud-infra rules (network gateways, redundancy, quotas) excluded — HEO's `/deploy` owns deployment. Report `Summary` structure unchanged. |
| `/prd-creator` | Enhanced | Fixed 6-section PRD → **adaptive depth** (minimal / standard / comprehensive) + **conditional User Stories** with acceptance criteria and MoSCoW traceability for complex/multi-user projects (auto-skipped for simple tools). 1:1 chat style kept. |
| `/architecture-sketch` | Enhanced | Stack + folder proposal → **+ conditional provider-neutral NFR patterns** (performance targets, resilience: timeouts/circuit-breaker/graceful-degradation, scalability). Surfaced only for M/L projects. No infra/deploy/cloud specifics. |
| `/resume-heo` | Enhanced | 4-state router → State C now **detects brownfield** (source present, no HEO artifacts) and routes to `/reverse-engineer`; State C vs State D made mutually exclusive. |

**Counts:** skills 16 → 17; features 16 → 20 (F017–F020, all `passes:true`).

## Why This Exists

<!-- 기존 5개 스킬(prd-creator, init-project, feature-done, optimize-claude-md, find-skills)만으로는
     아키텍처 검토, 보안 스캔, 세션 연속성, 학습 루프가 빠져 있었음. -->

Claude Code can write code for you, but "code that works" and "code you can trust" are different things. HEO_UPGRADE fills the gap with:

- **Multi-layer verification** — security scan + self-review + cross-model review before every commit
- **Session continuity** — handoff at end, resume at start, no context lost
- **Learning loops** — failures AND successes are mined for patterns across projects
- **Visible decisions** — every phase outputs a named artifact the user can inspect or override

## Architecture

<!-- 4 Phase + 4 Cross-cutting Layer -->

```
  PHASE 1 — SHAPE                    PHASE 2 — BUILD (per feature)
  (idea → buildable scaffold)        (scaffold → verified feature)

  /brainstorm  (smart-skip)          /turbo-build (automated pipeline)
  /prd-creator                        ── or manual ──
  /architecture-sketch               /feature-plan
  /design-sketch (UI projects)       [implement] + checkpoint every 5 edits
  /init-project
                                     /verify-stack (security/review/cross-model)
                                     /feature-done (QA + commit)  ↻ loop

  PHASE 3 — SHIP (optional)          PHASE 4 — EVOLVE (continuous)

  /pre-ship-check                    /handoff    (session end)
  /deploy                            /resume-heo (session start)
  /monitor                           /reflect    (instinct extraction)
                                     /project-doctor (health check)
                                     /optimize-claude-md

  ─────── CROSS-CUTTING ───────
  Memory & Learning Loop │ Confidence Tagging │ Cost Awareness │ Bilingual Artifacts
```

## Skills (18)

<!-- 18개 스킬 목록. Phase별 분류. -->

| Phase | Skill | What it does |
|---|---|---|
| SHAPE | `/brainstorm` | Divergent → convergent ideation when the idea is vague |
| SHAPE | `/prd-creator` | Adaptive-depth MoSCoW PRD via 1:1 chat, with conditional User Stories + acceptance criteria for complex projects |
| SHAPE | `/architecture-sketch` | Tech stack + folder layout proposal, with conditional provider-neutral NFR patterns (performance/resilience/scalability) |
| SHAPE | `/design-sketch` | Visual-direction proposal (platform × purpose axes) → design tokens in `DESIGN_PROPOSAL.md`; keeps builds off generic AI defaults |
| SHAPE | `/init-project` | Scaffold files, CLAUDE.md, git init, language packs, design tokens |
| SHAPE | `/reverse-engineer` | Analyze an existing codebase into HEO artifacts (brownfield entry) |
| BUILD | `/turbo-build` | Automated pipeline: builds all features in fresh sessions (no context pollution) |
| BUILD | `/feature-plan` | Live per-feature plan from current architecture state |
| BUILD | `/verify-stack` | 3-layer review: security (hard block, strict app-level checklist opt-in) → self-review → cross-model |
| BUILD | `/feature-done` | Strict QA pipeline → `passes:true` → commit → next feature |
| SHIP | `/pre-ship-check` | 5-check ship-readiness diagnostic |
| SHIP | `/deploy` | Platform-detected deploy + git tag + rollback registration |
| SHIP | `/monitor` | Post-deploy reachability check + rollback suggestion |
| EVOLVE | `/handoff` | 5-phase session-end ceremony (3 tiers: Light/Standard/Advanced) |
| EVOLVE | `/resume-heo` | 4-state session-start router ("계속" is enough) |
| EVOLVE | `/reflect` | Instinct extraction from failures + successes |
| EVOLVE | `/project-doctor` | Health check: CLAUDE.md size, drift, stale lessons |
| EVOLVE | `/optimize-claude-md` | 3-stage CLAUDE.md audit and compression |

## Cross-Cutting Conventions

<!-- 모든 스킬에 횡단 적용되는 규칙 4가지 -->

| Layer | Location | Purpose |
|---|---|---|
| **Confidence Tagging** | `~/.claude/rules/confidence-tags.md` | `[verified]` / `[high]` / `[medium]` / `[guess]` on every actionable claim |
| **Cost Awareness** | `~/.claude/rules/cost-awareness.md` | One-line cost estimate before expensive steps; append to `.claude/cost-log.jsonl` |
| **Design Judgment** | `~/.claude/rules/design.md` | 2026 frontend-design baseline: AI-as-intern, universal core, platform × purpose selection, anti-generic checklist |
| **Memory & Learning** | `instincts.md` + `lessons-learned.md` | Cross-project pattern accumulation with confidence grading |
| **Bilingual Artifacts** | Convention | English body + `<!-- 한글 주석 -->` in all generated files |

## Quick Start

<!-- 사용법 -->

```
# 1. Say "계속" or "/resume-heo" to resume previous work
# 2. Or start fresh:
/brainstorm          # if idea is vague
/prd-creator         # if idea is clear
/architecture-sketch # review tech stack before coding
/design-sketch       # decide visual direction (UI projects) before coding
/init-project        # scaffold and start building

# 3. Build all features automatically:
/turbo-build         # runs each feature in a fresh session (recommended)

# 3-alt. Or build one at a time (manual):
/feature-plan        # plan → implement → /feature-done

# 4. When ready to ship:
/pre-ship-check → /deploy → /monitor

# 5. Session boundary:
/handoff             # at end ("오늘 여기까지")
계속                  # at start (next session)
```

## Installation

<!-- 다른 컴퓨터에 설치하는 방법 -->

Clone this repo, then run the install script to copy skills, rules, and tools into `~/.claude/`.

**Windows (PowerShell):**
```powershell
.\install.ps1          # first install
.\install.ps1 -Force   # overwrite existing
```

**macOS / Linux:**
```bash
bash install.sh          # first install
bash install.sh --force  # overwrite existing
# turbo-build requires jq: sudo apt install jq (or brew install jq)
```

The scripts copy `framework/skills/` → `~/.claude/skills/` and `framework/rules/` → `~/.claude/rules/`. Existing files are skipped unless `-Force` / `--force` is used.

### Updating an existing install (v1 → v2)

<!-- 기존 설치자 업데이트 방법. -Force가 필요하지만 학습 데이터는 자동 보존됨. -->

A plain install **skips files that already exist**, so it would add the new `/reverse-engineer` skill but leave your other skills on v1. To actually update the changed skills, pull the latest and re-install with `-Force` / `--force`:

**Windows (PowerShell):**
```powershell
git pull
.\install.ps1 -Force
```

**macOS / Linux:**
```bash
git pull
bash install.sh --force
```

Then **restart Claude Code** so it reloads the skills.

**Your learning data is safe.** `-Force` / `--force` overwrites skill files and the static
convention rules (`confidence-tags.md`, `cost-awareness.md`) with the new versions, but
**`instincts.md` and `lessons-learned.md` are never overwritten** — the installer treats them as
user data and only creates them if they don't yet exist. On update you'll see them marked
`KEEP  (user data preserved)` in the output.

> ⚠️ These two files live in `~/.claude/rules/` (per-machine, per-user) and are **not** tracked in
> this repo. If you want them backed up or synced across machines, copy them manually — the
> installer will never touch existing copies.

## File Structure

<!-- 프로젝트 루트 파일 구조 -->

```
HEO_UPGRADE/
├── ADVANCED_SKELETON.md           # Authoritative spec (4 phases, 16 features)
├── PRD.md                         # Product requirements
├── FRAMEWORK_DESIGN.md            # Initial design notes
├── feature_list.json              # Feature tracking (20/20 passes:true)
├── progress.md                    # Cumulative session log
├── HANDOFF.md                     # Last session handoff state
├── install.ps1                    # Windows installer
├── install.sh                     # macOS/Linux installer
├── docs/index.html                # HTML documentation page
├── framework/                     # Portable framework bundle
│   ├── skills/                    # 18 skill definitions
│   ├── tools/                     # Automation scripts (turbo-pipeline.ps1)
│   └── rules/                     # 4 cross-cutting rules
└── .gitignore

~/.claude/
├── skills/                        # 18 skill definitions (SKILL.md each)
│   ├── brainstorm/
│   ├── architecture-sketch/
│   ├── design-sketch/             # platforms/ + profiles/ reference files
│   ├── init-project/
│   ├── prd-creator/
│   ├── reverse-engineer/
│   ├── turbo-build/
│   ├── feature-plan/
│   ├── verify-stack/
│   ├── feature-done/
│   ├── pre-ship-check/
│   ├── deploy/
│   ├── monitor/
│   ├── handoff/
│   ├── resume-heo/
│   ├── reflect/
│   ├── project-doctor/
│   └── optimize-claude-md/
└── rules/                         # Global cross-cutting rules
    ├── confidence-tags.md
    ├── cost-awareness.md
    ├── design.md                  # Frontend-design judgment baseline (2026)
    ├── instincts.md               # Positive patterns (7 entries)
    └── lessons-learned.md         # Failure patterns
```

## Status

<!-- 현재 상태 -->

- **Version**: v2.1 (2026-07-08) — Design Direction Update
- **Framework build**: Complete (20/20 features, 11 sessions)
- **Success criteria**: 3/7 verified now, 3 deferred to first real project, 1 minor (15 vs 14 skills)
- **Next milestone**: First real project end-to-end using the full SHAPE → BUILD → SHIP flow

## Design Principles

<!-- 설계 원칙 -->

1. **Opinionated on engineering, transparent on decisions** — the framework decides tech details but shows its reasoning
2. **Evidence over trust** — every `passes:true` is verified, not self-reported
3. **Learn from both failure and success** — lessons-learned captures mistakes, instincts captures what worked
4. **Phase gates, not mandatory ceremony** — SHIP phase skips for non-deploying projects; brainstorm smart-skips for clear ideas
5. **Session-safe** — work can be paused mid-feature and resumed without context loss
