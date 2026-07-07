<!-- HEO_UPGRADE 프레임워크 README. 영문 본문 + 한글 주석. -->

# HEO_UPGRADE

<!-- 비개발자를 위한 Claude Code 소프트웨어 빌드 프레임워크 -->

A skill framework for non-developers building software with [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Four phases guide a project from fuzzy idea to deployed product, with quality gates the user doesn't need engineering expertise to operate.

**[HTML Documentation](docs/index.html)** | **[GitHub Repository](https://github.com/h0130jk2-heo/HEO_UPGRADE)**

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
  /init-project                      [implement] + checkpoint every 5 edits
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

## Skills (17)

<!-- 17개 스킬 목록. Phase별 분류. -->

| Phase | Skill | What it does |
|---|---|---|
| SHAPE | `/brainstorm` | Divergent → convergent ideation when the idea is vague |
| SHAPE | `/prd-creator` | Adaptive-depth MoSCoW PRD via 1:1 chat, with conditional User Stories + acceptance criteria for complex projects |
| SHAPE | `/architecture-sketch` | Tech stack + folder layout proposal, with conditional provider-neutral NFR patterns (performance/resilience/scalability) |
| SHAPE | `/init-project` | Scaffold files, CLAUDE.md, git init, language packs |
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

## File Structure

<!-- 프로젝트 루트 파일 구조 -->

```
HEO_UPGRADE/
├── ADVANCED_SKELETON.md           # Authoritative spec (4 phases, 16 features)
├── PRD.md                         # Product requirements
├── FRAMEWORK_DESIGN.md            # Initial design notes
├── feature_list.json              # Feature tracking (16/16 passes:true)
├── progress.md                    # Cumulative session log
├── HANDOFF.md                     # Last session handoff state
├── install.ps1                    # Windows installer
├── install.sh                     # macOS/Linux installer
├── docs/index.html                # HTML documentation page
├── framework/                     # Portable framework bundle
│   ├── skills/                    # 17 skill definitions
│   ├── tools/                     # Automation scripts (turbo-pipeline.ps1)
│   └── rules/                     # 4 cross-cutting rules
└── .gitignore

~/.claude/
├── skills/                        # 17 skill definitions (SKILL.md each)
│   ├── brainstorm/
│   ├── architecture-sketch/
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
    ├── instincts.md               # Positive patterns (7 entries)
    └── lessons-learned.md         # Failure patterns
```

## Status

<!-- 현재 상태 -->

- **Framework build**: Complete (16/16 features, 10 sessions)
- **Success criteria**: 3/7 verified now, 3 deferred to first real project, 1 minor (15 vs 14 skills)
- **Next milestone**: First real project end-to-end using the full SHAPE → BUILD → SHIP flow

## Design Principles

<!-- 설계 원칙 -->

1. **Opinionated on engineering, transparent on decisions** — the framework decides tech details but shows its reasoning
2. **Evidence over trust** — every `passes:true` is verified, not self-reported
3. **Learn from both failure and success** — lessons-learned captures mistakes, instincts captures what worked
4. **Phase gates, not mandatory ceremony** — SHIP phase skips for non-deploying projects; brainstorm smart-skips for clear ideas
5. **Session-safe** — work can be paused mid-feature and resumed without context loss
