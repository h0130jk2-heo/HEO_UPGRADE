---
name: resume-heo
description: Use at session start to resume previous work. Triggers on "/resume-heo", "계속", "이어서", "이어가자", "재개", "어디까지였지", "어디서 멈췄지", "어제 어디까지", "다시 시작", "지난번 이어서", "resume previous work", "where was I". Reads HANDOFF.md and feature_list.json to determine the resume state, then routes to the appropriate next action (mid-feature continuation / next-feature start / fresh-start prompt). The session-start mirror of /handoff.
---

# resume-heo

<!-- 세션 시작 측 라우터. /handoff와 대칭. -->
<!-- HANDOFF.md 기반으로 상태 판단 후 적절한 후속 액션으로 라우팅. -->

## Overview

The **session-start mirror of `/handoff`**. When the user starts a new session and wants to resume previous work, this skill:

1. Reads the previous session's artifacts (`HANDOFF.md`, `feature_list.json`, `progress.md`)
2. Classifies the resume state (4 categories)
3. Proposes a specific next action with context
4. Waits for user confirmation or redirect

The user typing just "계속" or "이어서" is enough — this skill handles the rest.

## ⚠️ Important Rules

- **Never auto-execute the resume action.** Always propose and wait for user confirmation.
- **Always summarize state in Korean.** The user converses in Korean.
- **Never make assumptions about user intent beyond what HANDOFF.md says.** If HANDOFF.md is missing or stale, ask before proceeding.

## Step 1: Read State Files (silent)

Read these files in order. Each may or may not exist:

```bash
HANDOFF.md           # 이전 세션 종료 시점 핸드오프 — 가장 중요
feature_list.json    # 현재 기능 상태 (_session_state 필드 포함)
progress.md          # 누적 진행 로그
.claude/decisions.log  # 결정 기록
```

Also check:
```bash
git log --oneline -5  # 최근 커밋
git status            # uncommitted 변경
```

## Step 2: Classify Resume State

Match into one of 4 categories:

### State A — Mid-feature (HANDOFF.md says in-progress)
**Signals:**
- `HANDOFF.md` exists AND contains "Status: in-progress"
- OR `feature_list.json` has a feature with `_session_state` field

**Likely:** User paused mid-feature, wants to continue.

### State B — Between-features (last session completed something)
**Signals:**
- `HANDOFF.md` exists AND contains "Status: completed"
- OR most recent commit is "feat:" type
- AND `feature_list.json` has more `passes: false` features remaining

**Likely:** User wants to start the next feature.

### State C — Fresh-start (project exists but no recent handoff)
**Signals:**
- `feature_list.json` exists BUT no `HANDOFF.md` (or HANDOFF.md is older than 7 days)
- OR `progress.md` exists but no recent activity

**Likely:** User returning to a stale project. Needs orientation.

### State D — No project
**Signals:**
- None of `feature_list.json`, `progress.md`, `HANDOFF.md`, `PRD.md` exist
- Possibly `BRAINSTORM.md` exists (mid-brainstorm pause)

**Likely:** No project yet. User wants to start fresh.

## Step 3: Route to Action

### State A — Mid-feature resume

Present:
```
지난 세션 멈춘 지점:
  • Feature: F[XXX] — [name]
  • Status: in-progress
  • 마지막 한 일: [last action]

남은 단계:
  - [ ] [step 1]
  - [ ] [step 2]

미해결 질문 [있을 때만]:
  - [question 1]

▶ 제안: F[XXX]의 [next step]부터 이어가실래요? (다른 작업 원하시면 말씀해주세요.)
```

If user confirms: auto-invoke `/feature-plan` with the current feature ID to generate a fresh live plan that accounts for any architecture drift since the pause. No second confirmation needed — the user already approved the feature.

If user redirects: respect their direction.

### State B — Next feature

Present:
```
지난 세션 완료: F[XXX] — [completed feature]

다음 후보:
  1. [F[XXX+1]] — [name] (Must)
  2. [F[XXX+2]] — [name] (Should)
  3. [F[XXX+3]] — [name] (Should)

▶ 제안: F[XXX+1]부터 시작할까요? (다른 우선순위로 가시려면 알려주세요.)
```

If user confirms: auto-invoke `/feature-plan` to generate a live plan for that feature. No second confirmation needed — the user already approved the feature.

### State C — Fresh-start (stale project)

Present:
```
프로젝트는 있는데 이전 핸드오프가 없거나 오래됐어요.

현재 프로젝트 상태:
  • 완료된 기능: [N]/[M]
  • 마지막 커밋: [date] — [message]
  • progress.md 마지막 항목: [tail 1 line]

▶ 어떤 작업으로 가실래요?
  1. 미완료 기능 중 골라서 (F[XXX], F[YYY], ...)
  2. 코드베이스 점검 먼저 (/project-doctor)
  3. CLAUDE.md 정리 (/optimize-claude-md)
  4. 다른 작업 (자유 입력)
```

Wait for user choice.

### State D — No project

Check whether `BRAINSTORM.md` exists in the cwd:

**If `BRAINSTORM.md` exists:**
```
BRAINSTORM.md에서 정리된 방향이 있네요:
  → [Chosen Direction 한국어 요약]

▶ /prd-creator로 넘어갈까요?
```

**If no BRAINSTORM.md either:**
```
새로 시작하는 프로젝트네요. 어디서부터 갈까요?
  1. 아이디어가 막연 → /brainstorm
  2. 아이디어는 잡혔음, PRD 쓰자 → /prd-creator
  3. 다른 작업 (자유 입력)
```

## Step 4: Wait for User Confirmation

NEVER auto-execute. Always wait for the user to say yes (or redirect) before proceeding.

If the user redirects to a completely different task ("아니, 그것보다 X를 먼저"), respect it and stop the routing logic.

## Hard Rules

- **NEVER overwrite HANDOFF.md** in this skill. (handoff is the writer; resume-heo is read-only.)
- **Auto-invoke `/feature-plan`** after user confirms a feature (State A or B). For all other skills (brainstorm, etc.), wait for explicit user request.
- **NEVER fabricate state** if HANDOFF.md is missing or empty — fall through to State C or D instead.
- **ALWAYS present in Korean.** This skill is the user's first interaction in a session; tone matters.
- **ALWAYS quote specific text** from HANDOFF.md when summarizing (so the user can verify it's reading the right thing).
