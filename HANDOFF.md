<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->
<!-- mode=meta + git 없음 → 이전 HANDOFF.md를 단순 덮어쓰지 않고 병합 처리 (정보 손실 방지). -->

# Handoff — 2026-05-25 (HEO_UPGRADE Build, after handoff v1.1 reinforcement)

## Mode + Tier
- **Mode**: meta (no git in working directory, no feature_list.json)
- **Tier**: Advanced (user-confirmed; auto-detect unavailable in meta mode)

## Where We Stopped
<!-- 어디서 멈췄나 -->
- **Meta-task**: Building the HEO_UPGRADE framework — most recent activity was reinforcing the `/handoff` skill itself based on self-critique
- **Status**: in-progress (4 of 14 components built; handoff v1.1 patches edge cases discovered during real-session test)
- **Last action**: Updated `~/.claude/skills/handoff/SKILL.md` (240→353 lines, Step 1 restructured into Mode+Tier with 4 modes; Steps 2/5/6 made mode-conditional; Hard Rules updated)

## What's Done This Session
<!-- 누적: 이전 HANDOFF.md 내용 + 이번 v1.1 보강 -->

### Components built (4 of 14, unchanged)
- ✓ **[0] checkpoint hook** — `PostToolUse.sh` counts Edit/Write/NotebookEdit every 5 in HEO_UPGRADE-active projects; `session-start.sh` resets counter
- ✓ **[1] brainstorm skill** — `~/.claude/skills/brainstorm/SKILL.md`; divergent → convergent → BRAINSTORM.md; prd-creator Step 0 added
- ✓ **[13] handoff skill** (now v1.1) — see "Latest reinforcement" below
- ✓ **[14] resume-heo skill** — `~/.claude/skills/resume-heo/SKILL.md`; session-start mirror, 4-state classifier

### Latest reinforcement (this round, on top of [13])
- ✓ **handoff v1.1** — Step 1 reorganized into 1a Detect Mode / 1b Detect Tier (mode-branched) / 1c Override / 1d Announce+Confirmation
- ✓ **4 modes** introduced: `heo-active` (git + feature_list.json) / `heo-general` (git only) / `meta` (neither) / `anomaly` (no git but features — warn)
- ✓ **Tier confirmation policy** clarified: Light/Standard in heo-* = announce-and-go; Advanced = explicit Yes/No; meta = always wait for manual pick with conversation-based recommendation
- ✓ **Phase 2/4/5 mode-conditional**: Capture varies by mode; Persist only writes existing files (no auto-create); Wrap-up skips git commit when no git
- ✓ **Hard Rules** updated with mode-aware language (NEVER commit without git, NEVER auto-create progress.md/feature_list.json, etc.)
- ✓ **Pragmatic merge** instead of strict overwrite when mode=meta (this very HANDOFF.md) — applied here to prevent data loss in git-less context

### Other artifacts (unchanged from previous handoff)
- ✓ `session-start.sh` reads HANDOFF.md "Where We Stopped" + "Next Session" + "재개 방법" hint footer
- ✓ `session-start-marker` created at session start
- ✓ `prd-creator/SKILL.md` enhanced with Step 0 (BRAINSTORM.md auto-consumption)
- ✓ Disabled `superpowers` + `andrej-karpathy-skills` plugins
- ✓ `FRAMEWORK_DESIGN.md` (initial conservative design, superseded)
- ✓ `ADVANCED_SKELETON.md` (authoritative spec, 14 components)
- ✓ 4 memory files in `~/.claude/projects/E--AI-100--Project-Basic/memory/`
- ✓ **`~/.claude/rules/instincts.md` (NEW)** — first entry written by this handoff's Reflect phase: "dogfooding skills on real sessions surfaces edge cases that design review misses"

## What's Left
<!-- 남은 일 — 14 컴포넌트 중 10개 미빌드 + cross-cutting -->

### Phase 1 (SHAPE) — 2 remaining
- [ ] **[2] architecture-sketch** — pre-init-project skill that surfaces tech stack / folder layout / alternatives as `ARCHITECTURE_PROPOSAL.md`
- [ ] **[3] init-project enhancement** — consume `ARCHITECTURE_PROPOSAL.md`; install language packs into `.claude/rules/<lang>.md`

### Phase 2 (BUILD) — 3 remaining
- [ ] **[4] feature-plan** — live per-feature plan; reads Architecture + lessons-learned + instincts + HANDOFF.md
- [ ] **[5] verify-stack** — multi-layer review (self-review / security static+LLM / cross-model Gemini); tiered failure
- [ ] **[6] feature-done enhancement** — consume verify-report; visual check if UI; record successes

### Phase 3 (SHIP) — 3 remaining
- [ ] **[7] pre-ship-check**
- [ ] **[8] deploy** (with rollback)
- [ ] **[9] monitor**

### Phase 4 (EVOLVE) — 2 remaining
- [ ] **[10] reflect** — periodic instinct extraction (handoff currently does this lightly; reflect will be more systematic)
- [ ] **[11] project-doctor** — project health check

### Cross-cutting — partially done
- ✓ checkpoint hook
- ✓ bilingual artifacts convention
- ✓ instincts.md initialized (writer = handoff for now)
- [ ] confidence tagging
- [ ] cost awareness

## Decisions Made
<!-- 누적: 이전 결정 + 이번 v1.1 보강 결정 -->

### Architecture (unchanged)
- 4-phase + 4-cross-cutting over 6-phase split (cognitive load for non-developer)
- 14 skills total over ≤10 target (handoff/resume-heo pair justified +2)

### Implementation order (unchanged)
- Hybrid order (checkpoint hook first, then pipeline)

### Naming (unchanged)
- `/resume-heo` over `/resume` (avoid built-in collision)
- `HEO_UPGRADE` over generic naming

### Plugin coexistence (unchanged)
- Disable superpowers + karpathy

### Trigger heuristics (unchanged)
- brainstorm keyword heuristic over LLM clarity score
- checkpoint hook gated on feature_list.json presence

### Failure semantics (unchanged)
- verify-stack tiered failure (security hard-block, others confirm/warn)

### Session boundary (unchanged)
- Single `/handoff` skill over OMC compose-your-own
- `/handoff` + `/resume-heo` symmetric pair

### Session-end mode handling (NEW this round)
- Chose **4 modes (heo-active / heo-general / meta / anomaly)** over single git-assumption. Reason: real test on E:/AI/100. Project/Basic showed the spec failed silently when no git/feature_list — mode-awareness makes failure handling explicit.
- Chose **tier confirmation tiered by risk** (Light/Standard auto-proceed in heo-*; Advanced waits; meta always waits) over "always confirm" or "never confirm". Reason: balance speed vs. safety based on cost-of-mistake.
- Chose **inline complexity (353 lines, over 200 target)** for handoff over extracting HANDOFF.md template to references/. Reason: orchestration logic should stay readable in one place for Claude; the 200-line target is a guideline not a hard rule for inherently complex orchestrators.
- Chose **merge previous HANDOFF.md in meta mode** over strict overwrite. Reason: meta mode has no git → overwrite = data loss. (This is a v1.1.5 implicit behavior; should be made explicit in v1.2.)

## Open Questions
<!-- 미해결 질문 — 이전 6개 + 이번 보강 후 추가 2개 -->

### Carryover from previous handoff
1. **Reflect skill frequency** (Phase 4): every 5 features, every 10, or on demand only?
2. **Cost awareness implementation**: hook? skill output? dedicated `/cost-estimate` skill?
3. **Confidence tagging**: hard convention vs. soft?
4. **Language packs priority** (init-project [3]): TS/JS + Python + PowerShell recommended; Rust/Go deferred
5. **architecture-sketch as separate skill vs inlined into init-project**: lean separate (explicit user review gate)
6. **HEO_UPGRADE testing strategy**: dogfood it by creating PRD.md + feature_list.json for the framework itself?

### NEW this round
7. **handoff v1.2 — merge vs overwrite in meta mode**: should the merge behavior be explicit in the spec, or is overwrite-with-git-as-history the right default and meta is a tolerated edge case?
8. **Skill max-line policy**: handoff is 353 lines, over the ≤200 target. Should we (a) accept inherently-complex orchestrators as exceptions, (b) extract templates to references/, (c) enforce hard cap and split skills? Currently leaning (a).

## Verification Results
<!-- Phase 2 결과 (Advanced tier, mode=meta) -->

### From previous handoff (still valid)
- `bash -n PostToolUse.sh` + `bash -n session-start.sh` — both pass
- checkpoint hook: counter increments, fires at 5, resets correctly; doesn't fire without `feature_list.json`
- session-start.sh: correctly extracts and prints HANDOFF.md "Where We Stopped" + "Next Session"
- 4 modified/new skills registered

### This round (handoff v1.1)
- `wc -l ~/.claude/skills/handoff/SKILL.md` = 353 lines (acceptable; complexity-justified)
- `grep -n "^## "` = 8 main sections + nested HANDOFF.md template — structure intact
- New v1.1 features dogfooded **right now in this handoff invocation**: mode detection correctly identified `meta`, tier auto-detection correctly deferred to user pick, user explicitly selected Advanced — full v1.1 flow exercised and working
- Note: a stricter test (heo-active mode on real git project) is **deferred** until next dogfood opportunity

## Next Session — Start Here
<!-- 다음 세션 첫 행동 -->

1. **Restart Claude Code** to pick up `superpowers`/`karpathy` plugin deactivation (not yet effective in current session)
2. **Read this HANDOFF.md** — `session-start.sh` will print "Where We Stopped" + "Next Session" automatically
3. **Decide on Open Question #6** (dogfooding HEO_UPGRADE on itself):
   - If **yes**: create PRD.md + feature_list.json listing the 10 remaining components as features → next handoffs will be heo-active mode instead of meta
   - If **no**: continue meta-mode workflow as is
4. **Continue with [2] architecture-sketch** (regardless of dogfooding decision):
   - Design `ARCHITECTURE_PROPOSAL.md` template
   - Decide: separate skill vs inlined into init-project (lean separate)
   - Define depth of "design alternatives considered"
   - Build the skill
5. **Verify plugin deactivation** took effect — at session start, skill list should NOT include any `superpowers:*` or `andrej-karpathy-skills:*` entries
