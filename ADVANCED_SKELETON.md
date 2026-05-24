<!-- 비개발자 사용자를 위한 가장 고도화된 Claude Code 프레임워크 골격 제안. -->
<!-- 본문 영어 + 한글 주석. 기존 흐름 유지 제약 없이 종합 검토 결과. -->

# HEO_UPGRADE — A Framework for Non-Developer Software Building

<!-- 프레임워크 이름: HEO_UPGRADE. 사용자(Heo)의 기존 워크플로를 업그레이드하는 차원이라는 의미. -->
<!-- 결정 사항 반영: Phase 3 (SHIP) 포함, 체크포인트 매 5 편집, 4-phase 골격 확정. -->


## 0. What "Advanced" Means Here

For a **non-developer** building software with Claude Code, "advanced" is NOT:
- More agents, modes, or skills
- More automation surface
- More technical sophistication exposed to the user

"Advanced" IS:
- **Outputs code quality close to a senior engineer** despite the user not being one
- **Catches errors the user cannot spot** (security, architecture drift, subtle bugs)
- **Learns over time** — both from failures AND successes
- **Transparent enough** that the user can intervene at any phase
- **Opinionated on engineering details**, so the user doesn't suffer choice fatigue
- **Evidence-based** — every claim of "done" is verified, not trusted
- **Resilient** — local failures don't cascade into project-wide breakage

The benchmark: after building 10 features with this framework, the user should be able to ship code they couldn't have written, debugged, or reviewed alone — and trust it.

---

## 1. Top-Level Architecture (4 Phases + 4 Cross-cutting Layers)

```
                          ╔══════════════════════════════════╗
                          ║   CROSS-CUTTING LAYERS            ║
                          ║   ─ Memory & Learning Loop        ║
                          ║   ─ Confidence Tagging            ║
                          ║   ─ Cost Awareness                ║
                          ║   ─ Bilingual Artifacts           ║
                          ╚══════════════════════════════════╝

  PHASE 1 — SHAPE                       PHASE 2 — BUILD (per feature)
  (idea → buildable scaffold)           (scaffold → verified feature)

  [idea]                                ┌─────────────────────────────┐
    ↓ /brainstorm  (smart-skip)         │ /feature-plan               │
    ↓ /prd-creator                      │   ↓ (live plan, not static) │
    ↓ /architecture-sketch  (NEW)       │ [implement]                 │
    ↓ /init-project                     │   ↓ checkpoint every N edits│
                                        │ /verify-stack               │
                                        │   ↓ (review/security/cross) │
                                        │ /feature-done               │
                                        │   ↓ (commit + visual)       │
                                        └─────────────────────────────┘
                                                 ↻ (loop)

  PHASE 3 — SHIP (optional)             PHASE 4 — EVOLVE (continuous + session boundary)
  (only when project deploys)           (always running in background)

  /pre-ship-check                       /handoff (at session END, NEW)
    ↓                                     └─ 5-phase + 3-tier ceremony, outputs HANDOFF.md
  /deploy (with rollback)               /resume-heo (at session START, NEW)
    ↓                                     └─ reads HANDOFF.md, routes to next action
  /monitor                              /reflect (every N features)
                                          └─ instinct extraction (failures + successes)
                                        /optimize-claude-md (on demand)
                                        /project-doctor (NEW, health check)
```

**Total skills: 14.** Most fire **automatically per phase** when invoked by the prior step. The user manually invokes Phase 1 entry, Phase 3 entry, `/handoff` at session END, and `/resume-heo` (or just says "계속") at session START.

---

## 2. Phase 1 — SHAPE

**Goal:** Turn a fuzzy idea into a buildable scaffold without forcing the user to specify what they don't know yet.

### 2.1 `/brainstorm` (NEW, smart-skip)
**What:** Divergent → convergent ideation when the idea is vague.
**Smart-skip:** Detects clarity of user's opening line. If the line already contains a clear product definition ("이메일에서 영수증 추출하는 스크립트"), skip directly to prd-creator. If vague ("뭔가 만들고 싶은데 잘 모르겠어"), enter brainstorm mode.

**Detection heuristic (simple, non-LLM):**
- Has noun + verb + target user? → skip
- Otherwise → enter brainstorm

**Brainstorm sub-flow:**
1. Divergent: 3-5 questions to expand idea space ("어떤 문제를 해결하고 싶나?", "비슷한 것 본 적 있나?")
2. Convergent: User picks one direction
3. Output: `BRAINSTORM.md` → fed into prd-creator as the opening summary

### 2.2 `/prd-creator` (KEEP + minor enhancement)
**Keep:** 6-section MoSCoW PRD, 1:1 chat, bilingual artifact.
**Enhance:** If `BRAINSTORM.md` exists, summarize it first and ask "이 방향 맞아?" instead of opening cold.

### 2.3 `/architecture-sketch` (NEW)
**What:** Before init-project scaffolds files, produce an **architecture proposal** the user can validate.

**Why this matters for non-developers:**
Currently init-project decides the tech stack + folder layout + entry points implicitly. The user has no chance to say "Python이 더 낫지 않을까?" or "이건 너무 복잡한데 더 단순하게". architecture-sketch surfaces this decision as a visible artifact.

**Output:** `ARCHITECTURE_PROPOSAL.md` containing:
- Tech stack with reasoning ("PowerShell이 Outlook COM 접근이 쉬워서 추천")
- Top-level folder layout (proposed, not yet created)
- Key data flow diagram (ASCII)
- 2-3 alternative approaches considered, why rejected
- Estimated complexity (XS/S/M/L) for the whole project

**User can:** confirm, request alternative, or modify before init-project runs.

### 2.4 `/init-project` (KEEP + receives architecture proposal)
**Keep:** Creates CLAUDE.md + feature_list.json + Architecture.md + progress.md + git init.
**Change:** Reads from `ARCHITECTURE_PROPOSAL.md` instead of inferring from PRD alone. Removes ARCHITECTURE_PROPOSAL.md after consuming it.
**Add:** Language pack auto-install (`.claude/rules/<lang>.md`) based on architecture.

---

## 3. Phase 2 — BUILD (per feature)

**Goal:** Each feature goes from `passes: false` to verified-and-committed without the user catching bugs themselves.

### 3.1 `/feature-plan` (NEW)
**What:** A live, per-feature plan generated when each feature is picked up.

**Why this is critical for non-developers:**
The current `init-project` writes static `steps[]` at project start. By feature F005, the architecture may have shifted; the steps written at F001-time are stale. `/feature-plan` regenerates a fresh plan based on **current** architecture state, lessons-learned, and recent commits.

**Inputs:**
- Current feature from `feature_list.json`
- Current `Architecture.md` state
- `~/.claude/rules/lessons-learned.md` (project + global)
- `~/.claude/rules/instincts.md` (from reflect skill)
- Recent commits

**Outputs (≤ 50 lines):**
- Specific files that will be touched
- 3-5 step implementation plan (replaces the static steps[])
- Risk list ("이 feature는 F002와 의존성 있음, 깨질 위험")
- Verification approach for THIS feature ("UI면 브라우저로 확인 가능")
- Updates `feature_list.json` with the live plan in `plan` field

### 3.2 Implementation with checkpoints
**What:** During implementation, every N tool calls Claude pauses and self-checks against the feature-plan.

**Why this matters for non-developers:**
The user can't review code-in-flight. If Claude is going off-track at edit #15 but the user only sees the final result, the entire feature is wasted. A checkpoint at every ~5 file edits asks: "Am I still on plan? Anything need to change?"

**Mechanism:**
- Triggered by `PostToolUse` hook counting Edit/Write calls per feature
- At N=5, Claude posts a 1-line status: "✓ on plan" or "⚠ deviation: <description>, OK to continue?"
- User can interrupt; otherwise continues

### 3.3 `/verify-stack` (NEW)
**What:** Multi-layer code review BEFORE feature-done's update-and-commit.

**3 sub-layers (already agreed in earlier discussion):**

| Layer | Trigger | Action | Failure mode |
|---|---|---|---|
| Security | Always | Static rule scan first; LLM only on hits to suppress false positives | **Hard block** (cannot pass with security failure) |
| Self-review | Always | Diff vs. feature-plan vs. PRD goal | **Confirm** (user can override with reason) |
| Cross-model | Conditional* | Gemini reviews the same diff | **Warn** (logged, doesn't block) |

*Cross-model trigger: when diff > 100 lines, OR when self-review confidence < 70%, OR when user adds `--strict` flag.

**Output:** `.claude/verify-report-<feature-id>.md` (consumed by feature-done, then deleted).

### 3.4 `/feature-done` (KEEP + enhancement)
**Keep:** Strict step-by-step QA, `passes:true` gate, file updates, lessons-learned auto-accumulation, git commit, next-feature suggestion.

**Enhance:**
- Reads `.claude/verify-report-*.md` from verify-stack as part of the QA evidence
- If feature has visual surface (PRD or architecture mentions UI/HTML), invokes a brief visual check (open in browser, screenshot, compare to PRD description)
- Successes (not just failures) are recorded to feed `/reflect`

---

## 4. Phase 3 — SHIP (optional)

**Goal:** When the project actually deploys somewhere (web app, npm package, executable, etc.), make deployment safe for a non-developer.

**Triggers:** User invokes `/pre-ship-check` OR PRD indicates the project will be shipped.

### 4.1 `/pre-ship-check`
- Verifies all features `passes: true`
- Checks for unresolved warnings in lessons-learned
- Validates secrets are in `.env` (not committed)
- Confirms README/docs exist if it's a public package
- Confirms deploy target is configured (Vercel? Cloudflare? Just an exe?)

### 4.2 `/deploy` (only if applicable)
- Runs the actual deployment command
- Tags the git commit with deploy timestamp
- Stores rollback info in `.claude/deploy-history.json`
- If deployment is to a hosted platform with rollback capability, registers the rollback command for `/rollback`

### 4.3 `/monitor` (only if applicable)
- Lightweight: checks if the deployment is reachable, returns expected response
- If broken, suggests `/rollback`

**Skip-when:** Personal scripts, learning projects, throwaway prototypes — Phase 3 simply doesn't fire. The framework doesn't impose deploy ceremony on non-deploying projects.

---

## 5. Phase 4 — EVOLVE (continuous + session-end)

**Goal:** Framework + project + user all get better over time. Sessions can be paused safely and resumed without context loss.

### 5.-1 `/resume-heo` (NEW, at session START)

**What:** The session-start mirror of `/handoff`. Routes the user's "계속" / "이어서" / "/resume-heo" to a specific next action based on previous session state.

**Why this matters for non-developers:**
After a `/handoff`, HANDOFF.md captures state — but the user still needs to know "what do I type to actually resume?" `/resume-heo` answers that. Non-developers shouldn't have to interpret HANDOFF.md themselves or compose the right invocation; they say "계속" and the skill routes.

**Triggers:** "/resume-heo", "계속", "이어서", "이어가자", "재개", "어디까지였지", "어디서 멈췄지", "어제 어디까지", "다시 시작", "지난번 이어서"

**4-state classifier:**
| State | Signal | Action |
|---|---|---|
| **A. Mid-feature** | HANDOFF.md status=in-progress OR feature_list.json has `_session_state` | Summarize where we stopped, propose continuation step, optionally invoke `/feature-plan` for live re-plan |
| **B. Between-features** | HANDOFF.md status=completed AND `passes: false` features remain | Suggest next feature, propose `/feature-plan` |
| **C. Fresh-start (stale)** | Project exists but HANDOFF.md missing or > 7 days old | Show project state + offer choice (pick feature / health check / cleanup) |
| **D. No project** | No project files | Suggest `/brainstorm` or `/prd-creator` (or consume existing BRAINSTORM.md) |

**Output:** A Korean summary + a single proposed action. **Never auto-executes.** Waits for user confirmation or redirect.

**Hint integration:** `session-start.sh` displays a "재개 방법" footer that mentions "계속" / "이어서" / "/resume-heo" so the user knows what to type.

### 5.0 `/handoff` (NEW, at session END)

**What:** A 5-phase session-end ceremony that scales by work intensity.

**Why this matters for non-developers:**
Splitting work across sessions to avoid context pollution is good practice, but **how state transfers between sessions** determines whether the next session can resume cleanly. `feature-done` covers the FEATURE boundary; `handoff` covers the SESSION boundary regardless of feature state (including mid-feature pauses).

**Triggers:** "/handoff", "오늘 여기까지", "끝낼게", "잠깐 멈출게", "세션 끝", "wrap up"

**5 phases** (adapted from OMC's Cleanup/Verify/Reflect/Persist/Ship framework):
1. **Capture** — Current state, feature progress, uncommitted changes
2. **Verify** (Light skips) — Quick sanity check; verify-stack if feature completed
3. **Reflect** (Light skips) — Append to lessons-learned (failures) or instincts (successes)
4. **Persist** — progress.md state, decisions log, `_session_state` field in feature_list.json
5. **Wrap-up** — Generate HANDOFF.md, WIP git commit if mid-feature

**3 tiers** (auto-detected from commit count + uncommitted size + feature passes + Architecture changes):
- **Light**: Trivial session → only Capture + Wrap-up
- **Standard**: 1 feature completed or moderate work → all 5 phases
- **Advanced**: Multi-feature or Architecture changes → all 5 + project-doctor + optimize-claude-md diagnose

**Output:** `HANDOFF.md` at project root (overwrites each session). `session-start.sh` reads this on next session start to surface "Where We Stopped" and "Next Session — Start Here".

### 5.1 `/reflect` (NEW, periodic)
**What:** Periodic skill that extracts instincts from failures AND successes.

**Trigger:** After every N completed features (default N=5) OR on demand.

**Inputs:**
- Last N features (commits, verify-reports, lessons-learned entries)
- Successes (what worked) AND failures (what was hard)

**Outputs:**
- New entries to `~/.claude/rules/instincts.md` — patterns observed ≥ 2 times
- Confidence-graded ("3번 관찰됨, confidence: high" or "2번, low")
- User confirms before committing instincts (avoid runaway pattern-matching)

**Difference from current `lessons-learned`:**
- `lessons-learned.md` = past mistakes ("don't do X again")
- `instincts.md` = positive patterns ("when doing X, prefer Y")
- Both feed feature-plan as input

### 5.2 `/optimize-claude-md` (KEEP)
Existing 3-stage gate (Diagnose → Plan → Execute). No changes needed.

### 5.3 `/project-doctor` (NEW)
**What:** Health check across the project's framework artifacts.

**Checks:**
- Is `CLAUDE.md` over 200 lines?
- Are there stale `(planned)` items in `Architecture.md` that should be marked as built?
- Is `feature_list.json` drift (features added but no corresponding PRD update)?
- Are `lessons-learned` entries older than 6 months that haven't recurred?
- Skills installed but never invoked in last 30 days?

**Output:** Health report + suggested fixes (user picks which to apply).

---

## 6. Cross-Cutting Layers

These are NOT skills. They are aspects woven through every phase.

### 6.1 Memory & Learning Loop
```
feature-done (failure/success captured)
   → reflect (pattern extracted)
     → instincts.md / lessons-learned.md (stored)
       → feature-plan (consumed on next feature)
         → better plan
```

Memory layers:
- **Per-project**: `progress.md`, `Architecture.md`, `feature_list.json`
- **Per-user (global)**: `~/.claude/rules/lessons-learned.md`, `~/.claude/rules/instincts.md`
- **Per-session**: `MEMORY.md` (already used)

### 6.2 Confidence Tagging
Every Claude statement of fact or recommendation in framework outputs is tagged:
- `[verified]` — directly observed (file exists, test passed)
- `[high]` — strong inference (3+ corroborating signals)
- `[medium]` — single signal or moderate inference
- `[guess]` — no strong basis

**Why for non-developers:** They can't independently judge Claude's confidence. Making it explicit lets them know when to push back.

### 6.3 Cost Awareness
Before any multi-step skill that may consume significant tokens:
- Show estimated context size
- Show whether it spawns subagents (multiplier)
- Allow user to skip the expensive sub-step (e.g., cross-model verify)

Recorded to `.claude/cost-log.jsonl` for project budgeting.

### 6.4 Bilingual Artifacts (KEEP)
English body + Korean `<!-- 한글 -->` comments. Already established convention.

---

## 7. New vs. 6 Source Frameworks — Comprehensive Comparison

| Capability | This Skeleton | User's Current | OMC | ECC | gstack | superpowers | Karpathy |
|---|---|---|---|---|---|---|---|
| Idea elicitation | brainstorm (smart-skip) | — | — | research-first | /office-hours | brainstorming (mandatory) | — |
| PRD generation | prd-creator | prd-creator | prd agent | — | /office-hours+plan | writing-plans | — |
| Architecture review upfront | architecture-sketch | implicit | — | — | implicit | — | — |
| Scaffold | init-project | init-project | exec agent | install.sh | git clone | — | — |
| Per-feature live planning | feature-plan | static steps[] | — | — | — | writing-plans per | — |
| In-progress checkpoints | every N edits | — | ralph loop | — | — | — | — |
| Self code review | verify-stack layer 1 | — | — | — | /review | requesting-review | — |
| Security scan | verify-stack layer 2 (static+LLM) | — | — | AgentShield | /cso | — | — |
| Cross-model review | verify-stack layer 3 (Gemini) | — | /ask gemini | — | /codex | — | — |
| Functional verification | feature-done | feature-done | verify agent | — | /qa | verification-before | — |
| Visual verification | feature-done (conditional) | — | — | — | /qa + /design-shotgun | — | — |
| Commit + artifact update | feature-done | feature-done | — | — | /ship | finishing-branch | — |
| Pre-ship checklist | pre-ship-check | — | — | — | /ship implicit | — | — |
| Deployment | deploy | — | — | — | /land-and-deploy /canary | — | — |
| Monitoring | monitor | — | — | — | — | — | — |
| Learning from failures | reflect + lessons-learned | lessons-learned | — | continuous-learning v2 | — | — | — |
| Learning from successes | reflect + instincts | — | — | continuous-learning v2 | — | — | — |
| Cross-project knowledge | instincts.md (global) | lessons-learned (global) | — | continuous-learning | GBrain | memory dir | — |
| Health monitoring | project-doctor | optimize-claude-md (partial) | — | — | — | — | — |
| Behavioral principles | Karpathy 4 (in CLAUDE.md) | Karpathy 4 (in CLAUDE.md) | — | — | — | — | ✓ |
| Confidence tagging | Cross-cutting | — | — | — | — | — | partially (Think Before) |
| Cost awareness | Cross-cutting | — | partial (token analytics) | — | — | — | — |
| Bilingual artifacts | Cross-cutting | ✓ | — | — | — | — | — |
| Total skills (approx.) | ~12 | 5 | 19+ agents | 60 agents + 232 skills | 23 skills | ~12 skills | 0 (principles only) |

---

## 8. Why This Is "Most Advanced" for a Non-Developer

| Dimension | Argument |
|---|---|
| **Quality output without engineering knowledge** | Multi-layer verify (review/security/cross-model) catches what the user can't. Confidence tags surface uncertainty. Architecture-sketch makes tech-stack decisions visible BEFORE coding. |
| **Learns over time** | Both failures AND successes are mined for patterns. Cross-project instincts transfer between projects. |
| **Transparency at every phase** | Every phase outputs a named artifact (BRAINSTORM.md → PRD.md → ARCHITECTURE_PROPOSAL.md → feature_list.json → verify-report → commit). User can read or intervene anywhere. |
| **Opinionated on engineering** | Tech stack, lint rules, test approach — all decided by architecture-sketch / language packs / verify-stack with rationale. User confirms direction, framework decides details. |
| **Evidence-based** | feature-done's strict `passes:true` gate + verify-stack reports + functional verification. No "looks right, ship it". |
| **Resilient** | Per-feature isolation (failures don't cascade). Rollback registered on deploy. Lessons captured from every incident. Checkpoints catch drift early. |
| **Manageable surface** | 12 skills, NOT 60 or 232. Most fire automatically per phase. User manually invokes ~3 entry points (brainstorm/PRD entry, feature start, ship). |
| **Compatible with current** | User's existing 5 skills are kept; 7 added. No rewrites. |

---

## 9. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Surface too large for non-dev to track | Medium | High | Auto-invoke per phase; user only triggers entry points |
| Token cost explosion (especially cross-model + checkpoints) | Medium | Medium | Cross-cutting cost awareness layer; checkpoints skippable; cross-model conditional |
| False confidence from multiple verify layers ("everything passed → ship it") | Medium | High | Confidence tags expose uncertainty; verify-stack reports must be specific not generic |
| Skill bloat over time | Low | Medium | project-doctor checks for unused skills; 200-line per-skill cap enforced |
| Visual verification limited by Claude Code's tooling | High | Low | Use what's available (Read images, browser MCP if installed); graceful degrade |
| Cross-model dependency (Gemini CLI) fragility | Medium | Low | Graceful degrade when not installed; not a hard requirement |
| User overwhelm by Phase 1 length (4 skills before first code) | Medium | Medium | Smart-skip in brainstorm; architecture-sketch can be expressed in 30 lines for simple projects |
| Lock-in to this framework | Low | Medium | Each skill is standalone markdown; can be removed without breaking spine (prd → init → feature-done) |

---

## 10. What This Replaces vs. What This Keeps

**KEEP (from user's current):**
- `prd-creator` (with `BRAINSTORM.md` consumption)
- `init-project` (with `ARCHITECTURE_PROPOSAL.md` consumption + language packs)
- `feature-done` (with `verify-report` consumption + visual check conditional)
- `optimize-claude-md`
- `find-skills`
- Bilingual artifact convention
- Karpathy 4 principles in CLAUDE.md template
- `lessons-learned.md` accumulation

**ADD (NEW):**
- `/brainstorm`
- `/architecture-sketch`
- `/feature-plan`
- `/verify-stack`
- `/handoff` (session-END ceremony, 5-phase + 3-tier)
- `/resume-heo` (session-START router, 4-state classifier)
- `/reflect`
- `/project-doctor`
- `/pre-ship-check`, `/deploy`, `/monitor` (optional, only for shipping projects)
- Cross-cutting: confidence tags, cost awareness, in-progress checkpoints, **HANDOFF.md handoff doc**

**EXPLICITLY EXCLUDED (out of scope):**
- Mode-selection menus (OMC's autopilot/ralph/team)
- 60+ specialized agent definitions (ECC)
- Notification bridges (Telegram/Discord/Slack)
- Multi-platform adapters (Cursor/Codex/OpenCode beyond Claude Code)
- Browser primitives + prompt-injection defense (gstack) — defer until agentic browsing is in scope
- TDD as mandatory discipline (superpowers) — non-dev can't write tests fluently; replaced by verify-stack
- Role cosplay (PM/CEO/Eng/Design/CSO) — replaced by phase-based mental model

---

## 11. Decisions Locked In

- **Framework name**: `HEO_UPGRADE` ✓
- **Phase 3 (SHIP)**: included (deploy/rollback/monitor) ✓
- **Checkpoint frequency**: every 5 Edit/Write tool calls in Phase 2 ✓
- **Cross-model provider** in verify-stack: Gemini CLI ✓

## 11b. Decisions Still Open

1. **Reflect frequency** in Phase 4: every 5 features, every 10, or on demand only?
2. **Brainstorm trigger heuristic**: simple keyword detection OR LLM-judged clarity score?
3. **Implementation order**: pipeline order vs. value-first vs. foundation-first?

---

## 12. Success Criteria for the Whole Framework

After ~10 features built with this skeleton, the framework is working if:

- **Code quality**: No post-commit "actually this was broken" rollbacks on features that passed verify-stack
- **User confidence**: User reports they trust commits they made via this flow more than commits made before
- **Learning**: `instincts.md` has at least 5 entries, all confirmed useful by user
- **Cost**: Token cost per feature is within 1.5× of feature-done-only baseline
- **Surface stability**: Total skills still ≤ 12; no skill exceeds 200 lines
- **Bilingual integrity**: All artifacts maintain English body + Korean comments
- **Resilience**: At least 1 feature where verify-stack caught a bug Claude would have committed otherwise
