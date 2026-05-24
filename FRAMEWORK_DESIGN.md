<!-- 새 프레임워크 설계 문서. 본문 영어 + 한글 주석. -->
<!-- 6개 자산(OMC, ECC, gstack, superpowers, Karpathy, 사용자 현재 워크플로)을 통합한 점진적 업그레이드 계획. -->

# Framework Design — Unified Claude Code Workflow

## 0. North Star
<!-- 무엇을 만들고 무엇을 안 만드는지를 먼저 못박는다. -->

Build a **minimal-surface, maximally-leveraged** Claude Code framework that:
- Keeps the user's existing artifact-first pipeline (`prd-creator → init-project → feature-done`) as the **spine** — no rewrites.
- Absorbs the **single best idea** from each of OMC, ECC, gstack, superpowers, Karpathy — not the whole surface.
- Preserves the bilingual convention (Korean conversation, English artifacts with Korean comments).
- Stays under a hard ceiling: ≤ 200 lines per skill, ≤ 10 skills total.
- Upgrades happen **one at a time**, each independently shippable and reversible.

**Anti-goals** <!-- 하지 않을 것을 명시 -->
- No 60-agent / 232-skill bloat (ECC trap).
- No mandatory-everything (superpowers trap when overused).
- No mode proliferation (OMC trap: autopilot/ralph/team/ultrawork/ultraqa/deep-interview).
- No role-cosplay multiplication (gstack trap: CEO/eng/design/QA/CSO).

---

## 1. Phase Model

```
  DEFINE          SCAFFOLD         BUILD ⇄ VERIFY (loop)         MAINTAIN
  ───────         ────────         ──────────────────            ────────
  prd-creator  →  init-project  →  [code] ⇄ feature-done    →   optimize-claude-md
       ↑                                       │                       │
       │                                       ▼                       │
       └─────────────────── REFLECT (cross-project memory) ◀───────────┘
```

The current pipeline is **structurally sound**. The 4 frameworks contribute *depth* within each phase, not new phases.

---

## 2. Asset Strength Map
<!-- 각 자산에서 한 가지 핵심 강점만 추출. 나머지는 의도적으로 버린다. -->

| Asset | The ONE thing worth absorbing |
|---|---|
| **OMC** | Multi-provider synthesis (`/ask codex` + `/ask gemini` + `/ask claude`) for second opinions on hard problems |
| **ECC** | Multi-language rule packs auto-installed into `.claude/rules/<lang>.md` |
| **gstack** | Skill chaining via artifacts (design doc → code → review → ship — each writes the input for the next) |
| **superpowers** | TDD-as-default with verification-before-completion enforcement |
| **Karpathy** | 4 behavioral principles (Think / Simplify / Surgical / Goal-Driven) — **already embedded in user's CLAUDE.md template** ✓ |
| **사용자 현재** | Artifact-first pipeline + strict `passes: true` gate + failures.log → lessons-learned auto-accumulation |

Everything else is **explicitly out of scope** for v1.

---

## 3. Gap Diagnosis

| Phase | Current State | Missing |
|---|---|---|
| DEFINE | 6-section PRD via 1:1 chat | No pre-PRD brainstorming when the idea is still fuzzy |
| SCAFFOLD | Karpathy 4 principles + bilingual CLAUDE.md + feature_list.json | No language-specific rules (TS vs Python vs Rust); no project-profile selection |
| BUILD | Direct implementation, no execution mode | No TDD discipline; no cross-model sanity check on hard tasks |
| VERIFY | feature-done: strict step-by-step QA + git commit | No layered review (code review → security → cross-model); no pre-commit verifier |
| MAINTAIN | optimize-claude-md (3-stage gate) + find-skills | No skill garbage collection; no instinct extraction from failures.log |
| REFLECT | failures.log → lessons-learned.md (recurring patterns only) | No structured cross-project memory beyond mistakes |

---

## 4. New Framework Skeleton (Target State)

```
SKILLS (≤ 10 total)
├── prd-creator           [keep, +brainstorm pre-step]
├── init-project          [keep, +language rule packs]
├── feature-done          [keep, +verify-stack]
├── optimize-claude-md    [keep as-is — already Karpathy-aligned]
├── find-skills           [keep as-is]
├── brainstorm            [NEW — superpowers-style ideation before PRD]
├── verify-stack          [NEW — review/security/cross-model layer for feature-done]
├── ask-panel             [NEW — OMC-style multi-provider synthesis on demand]
└── reflect               [NEW — instinct extraction from failures.log + cross-project KB]

RULES (~/.claude/rules/)
├── lessons-learned.md    [keep — failures patterns]
├── ts-rules.md           [NEW — language packs, lazy-loaded by init-project]
├── py-rules.md           [NEW]
└── (add as needed)

HOOKS (~/.claude/hooks/)
├── session-start.sh      [keep]
├── PostToolUse.sh        [keep, +emit to failures.log AND instinct candidate stream]
└── (no new hooks)

CONVENTIONS
├── Bilingual artifacts (English body + Korean comments) — keep
├── ≤ 200 lines per skill / per CLAUDE.md — keep
├── Artifact-first (every phase outputs a file the next phase reads) — keep
└── Strict `passes: true` gate — keep
```

---

## 5. Component Mapping Table
<!-- 각 컴포넌트가 어떤 자산에서 어떤 아이디어를 빌렸는지 명시. 추후 트레이드오프 판단 시 추적성. -->

| Component | Idea Source | What Specifically | Why Not Just Adopt Wholesale |
|---|---|---|---|
| `brainstorm` (NEW) | superpowers `brainstorming` skill | Socratic divergence → convergence before requirements lock-in | superpowers makes it mandatory; we keep it optional and only when user explicitly invokes |
| `prd-creator` (KEEP+) | gstack `/office-hours` | Single-question cadence, periodic summarization | Already does this — only add: forward link to `brainstorm` when answers are vague |
| `init-project` (KEEP+) | ECC multi-language rules, OMC skill scopes | Language-pack auto-install into `.claude/rules/<lang>.md`; project-profile (`minimal` / `core` / `full`) selection | ECC ships 12+ ecosystems; we ship only what the user actually uses (start with TS, Python) |
| `verify-stack` (NEW) | gstack `/review` + `/cso` + `/codex`, ECC AgentShield, superpowers verification-before-completion | Layered verifier called by `feature-done` BEFORE setting `passes: true`. Steps: (1) self-review diff; (2) security scan (secrets/permissions); (3) cross-model second opinion on touched files | None of them alone is right: gstack chains too much, ECC is too heavy, superpowers is too strict. We compose a minimal stack. |
| `feature-done` (KEEP+) | superpowers TDD, OMC UltraQA loop | Insert `verify-stack` call before `passes: true`. Add optional `--strict` flag to enable TDD red-green-refactor when feature has testable surface | Keep the existing strict-QA mindset; just layer verify-stack on top |
| `ask-panel` (NEW) | OMC `/ask codex|gemini|claude`, gstack `/codex` | On-demand cross-model panel for design decisions or stuck debugging. Returns 2-3 perspectives + synthesis | OMC's smart routing is too automatic — we keep it user-invoked |
| `reflect` (NEW) | ECC continuous-learning v2 (instinct extraction), gstack GBrain | Periodic skill: read failures.log + recent commits → propose instincts/patterns → save to `~/.claude/rules/instincts.md` (separate from lessons-learned for clear semantics) | ECC's v2 has confidence scoring + clustering; v1 just does "appears ≥2 times" pattern detection (matches user's current feature-done logic) |
| `optimize-claude-md` (KEEP) | — | No changes; already enforces Karpathy-aligned 3-stage gate | Solid as-is |
| `find-skills` (KEEP) | — | No changes; npx skills ecosystem discovery | Solid as-is |
| Karpathy 4 principles | Karpathy CLAUDE.md | Already in init-project's CLAUDE.md template | Already absorbed ✓ |

---

## 6. Upgrade Roadmap (one at a time, in priority order)
<!-- "하나씩 업그레이드"라는 사용자 요청 반영. 각 단계는 독립적으로 검증 가능해야 함. -->

Each upgrade must satisfy:
1. **Shippable independently** — works even if later upgrades are never built.
2. **Reversible** — can be removed without breaking the spine.
3. **Tested via at least one real task** before declaring done.

### Upgrade #1 — `verify-stack` (HIGHEST VALUE)
**Why first:** The biggest delta between user's current pipeline and the 4 frameworks. `feature-done` already enforces strict QA, but lacks code-review / security / cross-model layers. Adding `verify-stack` immediately closes the largest quality gap.

**Scope:**
- New skill `verify-stack` (≤ 200 lines).
- 3 sub-steps, each independently skippable: self-review diff, security scan (secrets + dangerous patterns), cross-model opinion (uses `ask-panel` if installed, else skipped with notice).
- Hook into `feature-done` Step 2-A as a pre-commit gate.
- `--quick` flag (skip cross-model) and `--strict` flag (force all three).

**Done criteria:**
- Running `feature-done` on a real feature triggers verify-stack.
- Each sub-step produces actionable output (not "looks fine").
- Failure in any sub-step blocks `passes: true`.

### Upgrade #2 — `brainstorm` (HIGH VALUE)
**Why second:** Fixes the "vague idea → premature PRD" failure mode without altering the proven prd-creator flow. Pure upstream addition.

**Scope:**
- New skill `brainstorm` (≤ 150 lines).
- Triggered by `/brainstorm` or vague openings ("뭔가 만들고 싶은데", "아이디어가 있는데 정리 안 됨").
- Output: structured idea brief written to `BRAINSTORM.md` — feeds directly into prd-creator's opening question.
- prd-creator's Step 1 gets a one-line check: "BRAINSTORM.md가 있으면 첫 질문 대신 그걸 요약하고 확인부터."

### Upgrade #3 — `init-project` language packs (MEDIUM)
**Why third:** Quality-of-life improvement, not a quality-gap closer. Defer until usage shows which languages actually recur.

**Scope:**
- Add `~/.claude/rules/ts-rules.md`, `py-rules.md` (start with these two only).
- init-project Step 5 detects PRD tech stack and copies the matching rule pack into the project's `.claude/rules/`.
- Each pack ≤ 100 lines, language-specific gotchas only (no generic "write clean code" filler).

### Upgrade #4 — `ask-panel` (MEDIUM)
**Why fourth:** Useful but requires Gemini/Codex CLI setup. Build only after at least one real "stuck on a design decision" moment proves the need.

**Scope:**
- New skill `ask-panel` invokable as `/ask-panel <question>`.
- Synthesizes 2-3 provider responses with explicit attribution.
- Falls back to Claude-only mode if other CLIs not installed (don't error).

### Upgrade #5 — `reflect` + cross-project memory (LOWER)
**Why fifth:** The current `failures.log → lessons-learned.md` loop already captures the highest-leverage learnings. Instinct extraction is a refinement, not a missing capability.

**Scope:**
- New skill `reflect` (≤ 200 lines).
- Reads last N commits + failures.log + lessons-learned.md.
- Proposes instincts (patterns with confidence ≥ 2 occurrences) → user confirms → written to `~/.claude/rules/instincts.md`.
- Runs on demand (`/reflect`) or after every 10 completed features.

### Not on the roadmap (intentionally)
- Execution modes (autopilot/ralph/team) — too much surface for marginal value
- Notification bridges (Telegram/Discord/Slack) — orthogonal to coding quality
- Browser primitives + prompt-injection defense — only relevant for agentic-browsing use cases
- Multi-platform adapters (Cursor/Codex/OpenCode) — defer until Claude Code stops being the primary surface

---

## 7. Open Questions
<!-- 다음 대화 전에 사용자에게 확인이 필요한 것들. -->

1. **`verify-stack`의 security scan은 정적 규칙(ECC AgentShield 축소판) vs. LLM 기반 reviewer 중 어느 쪽?** 정적이면 유지비 낮음/오탐 가능, LLM이면 유연/토큰 비용.
2. **`ask-panel`은 어느 CLI를 우선 지원?** 사용자 환경에 gemini-cli / codex-cli 설치 여부 확인 필요.
3. **`brainstorm`은 prd-creator 안에 통합 vs. 별도 스킬?** 별도면 명확하지만 스킬 1개 증가, 통합이면 prd-creator가 200줄을 넘길 수 있음.
4. **언어 팩 우선순위:** TS/Python 외에 자주 쓰는 언어가 있는지.

---

## 8. Success Criteria for the Whole Framework
<!-- Karpathy의 goal-driven 원칙을 프레임워크 자체에 적용. -->

The unified framework is working if, after ~10 real features completed with it:
- **DEFINE phase**: PRD.md averages ≤ 3 clarifying rounds (vs. current baseline — measure).
- **VERIFY phase**: Zero post-commit "actually this was broken" rollbacks for features that passed verify-stack.
- **REFLECT phase**: Cross-project lessons-learned.md grows by at least 1 entry / 5 features.
- **MAINTAIN phase**: No skill exceeds 200 lines; total skills ≤ 10.
- **Conversational**: Korean conversation feels natural; English artifacts read cleanly.

If any criterion fails after 10 features, the corresponding upgrade is reverted or redesigned.
