---
name: handoff
description: Use at session end to capture state, persist learnings, and produce a handoff document for the next session. Triggers on "/handoff", "/session-end", "오늘 여기까지", "끝낼게", "잠깐 멈출게", "세션 끝", "끊을게", "이만 하자", "save and exit", "wrap up". ALWAYS use this when work needs to be paused mid-feature (not yet at feature completion) — feature-done covers feature boundary; handoff covers session boundary regardless of feature state.
---

# handoff

<!-- 세션 끝낼 때 5-phase ceremony 실행. 다음 세션이 즉시 재개 가능하도록 HANDOFF.md 출력. -->
<!-- OMC의 5-phase 프레임워크(Cleanup/Verify/Reflect/Persist/Ship)를 비개발자 친화로 압축. -->

## Overview

Run a 5-phase session-end ceremony scaled by work intensity. Outputs `HANDOFF.md` which the next session reads first to resume context. Bridges the gap between `feature-done` (feature boundary) and `session-start.sh` (session start).

**5 phases:** Capture → Verify → Reflect → Persist → Wrap-up
**3 tiers (auto-detected):** Light / Standard / Advanced

## ⚠️ Output Convention

`HANDOFF.md` follows the bilingual convention: English body, Korean explanatory comments (`<!-- 한글 -->`). Save to project root.

## Step 1: Detect Mode + Tier

### 1a. Detect Mode (the environment)

Before tier detection, classify the working environment. This determines which auto-detection signals are available.

```bash
git rev-parse --git-dir > /dev/null 2>&1 && HAS_GIT=yes || HAS_GIT=no
[ -f feature_list.json ] && HAS_FEATURES=yes || HAS_FEATURES=no
```

| Git? | feature_list.json? | Mode | What it means |
|---|---|---|---|
| yes | yes | **heo-active** | Full HEO_UPGRADE flow with formal feature tracking |
| yes | no | **heo-general** | Coding in a git repo but no HEO_UPGRADE init — track by commits/diffs only |
| no | no | **meta** | Meta-project / sandbox / docs-only — no auto signals, manual tier classification |
| no | yes | **anomaly** | Unusual; treat as **meta** + warn the user about the missing `.git` |

Remember the mode. All subsequent steps branch on it.

### 1b. Detect Tier (the work intensity)

Branch by mode:

#### Mode = `heo-active`

```bash
SINCE=$(stat -c %y .claude/session-start-marker 2>/dev/null || date -d '8 hours ago')
COMMITS_THIS_SESSION=$(git log --since="$SINCE" --oneline 2>/dev/null | wc -l)
UNCOMMITTED_LINES=$(git diff HEAD --shortstat 2>/dev/null | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | awk '{s+=$1} END {print s+0}')
FEATURES_PASSED=$(git log --since="$SINCE" --oneline 2>/dev/null | grep -c '^[a-f0-9]* feat:')
ARCH_CHANGED=$(git diff HEAD --name-only 2>/dev/null | grep -c "Architecture.md")
```

| Tier | Condition |
|---|---|
| **Light** | `COMMITS=0` AND `UNCOMMITTED_LINES ≤ 5` AND `FEATURES_PASSED=0` AND `ARCH_CHANGED=0` |
| **Standard** | `COMMITS≥1` OR `6 ≤ UNCOMMITTED_LINES ≤ 100` OR `FEATURES_PASSED=1` |
| **Advanced** | `FEATURES_PASSED≥2` OR `ARCH_CHANGED=1` OR `UNCOMMITTED_LINES > 100` |

#### Mode = `heo-general`

Same as heo-active but skip `FEATURES_PASSED` and `ARCH_CHANGED` (set to 0). Tier is decided by `COMMITS_THIS_SESSION` and `UNCOMMITTED_LINES` only.

#### Mode = `meta` (or `anomaly`)

**Auto-detection unavailable.** Compute a coarse estimate from conversation context:
- Count distinct files created/edited this session (the Claude conversation log is the source of truth)
- Note whether design docs / architecture / multi-component changes happened

Then **always ask** the user to pick (do not auto-proceed):

```
> 이 작업은 git/HEO_UPGRADE 컨텍스트 밖이라 자동 tier 감지가 어려워요.
> 다음 중 골라주세요:
>   1. Light    — 5분 이내, 1-2개 파일 수정
>   2. Standard — 30분~2시간, 새 컴포넌트나 여러 파일
>   3. Advanced — 2시간+, 다중 컴포넌트 / 시스템 변경 / 설계 결정
>
> 대화 기반 추천: **[Light/Standard/Advanced]** ← [한 줄 근거]
```

Wait for user's response. Use their pick; if no pick, use the recommendation.

### 1c. User Override

The invocation itself can carry a tier flag: `/handoff light`, `/handoff standard`, `/handoff advanced`. If present, **skip 1b entirely** and use the flagged tier. Don't announce or ask.

### 1d. Announce + Confirmation

For `heo-active` / `heo-general` with NO explicit flag:

```
> 모드: [heo-active / heo-general]
> 감지된 티어: **[tier]**
> [Light/Standard tier]:  → 진행합니다. 다른 강도로 가시려면 지금 알려주세요.
> [Advanced tier]:        → 진행 전에 확인할게요. **Advanced**로 갈까요?
>                          (Yes / Light / Standard / Cancel)
```

**Light/Standard**: announce and proceed in the same turn — user interrupts only if they want a change. (One-message round-trip.)

**Advanced**: explicit yes/no confirmation required (because Advanced runs heavier operations like optimize-claude-md diagnose, more tokens). Wait for user's next message before Phase 1.

For `meta`/`anomaly`: always wait (see 1b).

## Step 2: Phase 1 — Capture (ALL tiers, mode-conditional)

Always runs. Collect according to mode:

### Common (all modes)
- **Last 3 things done this session**: extract from the Claude conversation context (most reliable) + `git log --oneline -3` if git available
- **Outstanding decisions / open questions**: anything the user and Claude discussed but didn't resolve

### Mode = `heo-active` (additional)
- **Current feature**: read `feature_list.json`, find first `passes: false` item
- **Feature state**: in-progress (some steps done) / not-started / completed-this-session / blocked
- **What's left for current feature**: from `steps[]` minus what's verifiably done
- **Uncommitted changes summary**: `git diff HEAD --stat | head -10`

### Mode = `heo-general` (additional)
- **Current task**: from the conversation, what was the user working on this session (1-2 lines)
- **Files touched**: `git diff HEAD --name-only | head -10` + new files via `git status --short`
- **Uncommitted changes summary**: `git diff HEAD --stat | head -10`

### Mode = `meta` / `anomaly` (additional)
- **Current task**: from the conversation, name the meta-work (e.g., "Building HEO_UPGRADE framework", "Editing design docs")
- **Files touched this session**: ask Claude (yourself) to list distinct files created/modified during this conversation
- **No git diff** — note "no git in working directory" in the working notes

Store these in working notes (in-memory, persisted in Phase 4).

## Step 3: Phase 2 — Verify (Standard / Advanced only; Light skips)

**Light**: Skip entirely.

**Standard**:
- Quick syntax check on touched source files. Per language:
  - `.ts`/`.js`: `node --check <file>` (or `tsc --noEmit` if tsconfig exists)
  - `.py`: `python -m py_compile <file>`
  - `.ps1`: `Get-Command pwsh -ErrorAction SilentlyContinue` then parse
  - `.sh`: `bash -n <file>`
- If a feature was just completed this session AND `verify-stack` skill exists, invoke it for that feature's diff.

**Advanced**: Run `verify-stack` on **all touched files** since session start, even if no feature completed.

Record results in working notes. Don't block on warnings; record them as "Open Questions" in HANDOFF.md.

## Step 4: Phase 3 — Reflect (Standard / Advanced only; Light skips)

**Light**: Skip entirely.

**Standard**:
1. Briefly ask the user (or extract from conversation flow):
   > "이번 세션에서 새로 알게 된 것 있어요? 어렵거나 막혔던 부분? 한두 줄로요."
2. Check `.claude/failures.log` for new patterns since last reflection.
3. If a pattern (error type or mistake) appears ≥ 2 times in failures.log: append to **global** `~/.claude/rules/lessons-learned.md`:
   ```
   - [YYYY-MM-DD] [project-name] 문제: [무엇이 잘못됐는지] → 해결: [어떻게 해결했는지]
   ```
4. If a **positive pattern** emerged (something the user said worked well): append to `~/.claude/rules/instincts.md`:
   ```
   - [YYYY-MM-DD] [project-name] 상황: [언제] → 좋은 접근: [무엇] (confidence: low/medium)
   ```
   <!-- instincts.md는 reflect 스킬(미빌드)에서 본격 관리. handoff는 후보 누적만. -->

**Advanced**: Also propose (don't auto-write) updates to user-level skill descriptions if a recurring trigger pattern emerged. Print suggestion:
> "💡 `/[skill-name]`의 description에 `[new trigger phrase]` 추가를 권장합니다. 다음 세션에서 검토해보세요."

## Step 5: Phase 4 — Persist (ALL tiers, mode + tier conditional)

For each artifact below, only act if the underlying file (`progress.md`, `feature_list.json`, `CLAUDE.md`) exists OR can be reasonably created in this mode.

### `progress.md` — append session-end entry

**If `progress.md` exists** (any mode):

- **Light tier**: 1 line:
  ```
  - [YYYY-MM-DD HH:MM] Session paused (light): [one-line summary]
  ```
- **Standard / Advanced**: block:
  ```
  ## Session End — [YYYY-MM-DD HH:MM]
  - Mode: [heo-active / heo-general / meta]
  - Tier: [tier]
  - [heo-active]: Last feature: F[XXX] ([status])
  - [heo-general/meta]: Last task: [task name]
  - This session: [summary]
  - Next: [what to do first next session]
  ```

**If `progress.md` does NOT exist**: skip. Do NOT auto-create — that's `init-project`'s responsibility. HANDOFF.md (Step 6) carries the same info.

### `feature_list.json` — mid-feature state

**Mode = heo-active AND mid-feature only.** Update the in-progress feature with `_session_state`:
```json
"_session_state": {
  "paused_at": "YYYY-MM-DD HH:MM",
  "steps_completed": ["Step 1", "Step 2"],
  "steps_remaining": ["Step 3", "Step 4"],
  "blockers": [],
  "notes": "one-line context for resume"
}
```
Cleared by `feature-done` on completion.

**Mode = heo-general / meta**: skip — no feature_list.json to update.

### `.claude/decisions.log` — Standard/Advanced only

Mode-conditional:
- **heo-active / heo-general**: write to `.claude/decisions.log` (project-local; `.claude/` already exists from hooks)
- **meta**: write to HANDOFF.md's "Decisions Made" section only (no separate log file — meta projects don't accumulate longitudinally)

Format (when writing to log):
```
[YYYY-MM-DD] [feature-id or 'general'] Chose X over Y. Reason: Z.
```

Extract from conversation: any "X를 Y 대신 선택한 이유는 Z" / "chose X over Y" patterns confirmed by the user.

### `/optimize-claude-md` diagnose — Advanced only, if `CLAUDE.md` exists

**Skip if no CLAUDE.md in project root.** Otherwise invoke its Step 1 (diagnose only, not full execution). Print findings as suggestions in the session summary; never auto-fix.

## Step 6: Phase 5 — Wrap-up (ALL tiers, mode-conditional)

### Generate `HANDOFF.md` (overwrite previous if exists):

The "Where We Stopped" section adapts to mode:

```markdown
<!-- 다음 세션이 가장 먼저 읽는 핸드오프 문서. 본문 영어 + 한글 주석. -->
<!-- 이전 HANDOFF.md는 git에 있으면 history에, 없으면 단순 덮어쓰기. -->

# Handoff — [YYYY-MM-DD HH:MM]

## Mode + Tier
- Mode: [heo-active / heo-general / meta / anomaly]
- Tier: [Light / Standard / Advanced]

## Where We Stopped
<!-- 어디서 멈췄나 — mode별 다른 표현 -->

[heo-active 일 때:]
- **Feature**: F[XXX] — [feature name]
- **Status**: [in-progress / completed / blocked]
- **Last action**: [one line]

[heo-general 일 때:]
- **Task**: [task name from conversation]
- **Status**: [in-progress / completed / blocked]
- **Last action**: [one line]

[meta / anomaly 일 때:]
- **Meta-task**: [e.g., "Framework build", "Design doc editing"]
- **Status**: [in-progress / paused / done]
- **Last action**: [one line]

## What's Done This Session
- ✓ [item 1]
- ✓ [item 2]
- ✓ [item 3]

## What's Left
- [ ] [item 1]
- [ ] [item 2]

## Decisions Made
<!-- Standard/Advanced만. heo-active/heo-general은 decisions.log 참조도 함께 표시 -->
- [decision 1: chose X over Y because Z]

## Open Questions
- [question 1]

## Verification Results
<!-- Phase 2 결과. Light = "Skipped". heo-general/meta = mode 사유 명시. -->
[results / "Skipped (Light tier)" / "Skipped (mode lacks verify targets)"]

## Next Session — Start Here
1. Read this HANDOFF.md
2. [specific next action]
3. [optional second action]
```

### Git commit (mode-conditional):

**Mode = `meta` or `anomaly`**: skip commit entirely. Log a one-line note:
> ℹ️ 메타 프로젝트 (git 없음) — commit 생략. HANDOFF.md만 작성됨.

**Mode = `heo-active` or `heo-general`** (git available):

First check: `git diff HEAD --quiet` (exits 0 if nothing to commit).

- **Light tier**:
  - Nothing to commit → skip.
  - Has changes → `git add -u && git commit -m "wip: session paused (light)"`
- **Standard / Advanced**:
  - If `feature-done` already committed the main feature work earlier this session: commit only the handoff-side artifacts:
    ```
    git add HANDOFF.md progress.md feature_list.json .claude/decisions.log 2>/dev/null
    git commit -m "session: handoff at [tier] tier" || true
    ```
  - If mid-feature (heo-active):
    ```
    git add -u
    git commit -m "wip: F[XXX] — [progress summary] (handoff [tier])"
    ```
  - If general work (heo-general):
    ```
    git add -u
    git commit -m "wip: [task summary] (handoff [tier])"
    ```

### Summary to user:

```
✅ Handoff 완료 ([mode] / [tier])

핸드오프 문서: HANDOFF.md
다음 세션: "계속" / "이어서" → /resume-heo 가 자동 처리
         또는 직접: [구체적 first action]

[Standard/Advanced일 때만, 해당 mode에서]
이번 세션 학습:
  - lessons-learned 추가: [N]개  (failures.log 없으면 0)
  - instincts 후보: [N]개         (reflect 미빌드면 0)
  - 결정 기록: [N]개              (mode=meta면 HANDOFF.md만)

[Advanced + CLAUDE.md 존재 시만]
프로젝트 건강:
  - [optimize-claude-md 진단 1줄]

[mode=meta/anomaly 시 별도 알림]
ℹ️ 메타 모드 — git commit 생략됨, decisions.log 대신 HANDOFF.md에만 결정 기록.
```

## Hard Rules

- **NEVER commit if no git** in the working directory. (Mode = meta / anomaly.)
- **NEVER commit if nothing to commit.** Check with `git diff HEAD --quiet` first.
- **NEVER auto-create `progress.md` / `feature_list.json`.** If absent, skip the relevant Persist sub-step (HANDOFF.md carries the same info).
- **NEVER override user's explicit tier flag.** `/handoff <tier>` is authoritative.
- **NEVER auto-create new skills** in Reflect phase. Suggest only.
- **NEVER skip Phase 1 (Capture) or Phase 5 (Wrap-up).** Phases 2-4 are tier/mode-scalable; 1 and 5 are required.
- **NEVER preserve previous HANDOFF.md.** Overwrite. History lives in git (when git exists).
- **ALWAYS** English body + Korean HTML comments in HANDOFF.md.
- **ALWAYS** detect mode (Step 1a) before tier (Step 1b). They drive each other.
- **ALWAYS** wait for explicit user confirmation when mode = `meta` / `anomaly` OR when tier = Advanced. (Light/Standard with heo-active/heo-general can proceed immediately after announce.)
- **ALWAYS** announce the detected mode alongside the tier — the user needs to see both to judge whether the auto-detection is right.
