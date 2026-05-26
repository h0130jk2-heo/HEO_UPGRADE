---
name: feature-plan
description: Use when starting a new feature or when the user wants to plan implementation before coding. Triggers on "/feature-plan", "기능 계획", "계획 세워줘", "어떻게 만들지", "구현 계획", "플랜 짜줘", "뭐부터 하지", "plan this feature", "how should we build". Also auto-invoked by resume-heo after user confirms the next feature. Generates a live implementation plan by reading current architecture, lessons-learned, instincts, and recent commits.
---

# feature-plan

<!-- 기능 하나를 시작하기 전에, 현재 프로젝트 상태를 기반으로 라이브 구현 계획을 생성. -->
<!-- 정적 steps[]를 대체하는 동적 플랜. 아키텍처 변화·과거 교훈·최근 커밋 반영. -->

## Overview

Generate a live, context-aware implementation plan for a specific feature BEFORE coding starts. Unlike static `steps[]` written at project init, this plan reflects the **current** state: what's already built, what architecture decisions were made, what lessons were learned, and what risks exist.

The plan is saved to `feature_list.json` as a `plan` field on the target feature, and presented to the user for confirmation before implementation begins.

## ⚠️ Important Rules

- **Never start implementation.** This skill plans; implementation begins only after user confirms the plan.
- **Always present the plan in Korean** for user review.
- **Never overwrite an existing plan without asking.** If `plan` field already exists, ask first.
- **Plan output ≤ 50 lines** in the feature_list.json field (keep it scannable).

## ⚠️ Output Convention

Artifact outputs in English. Korean HTML comments only when they add non-obvious context (not heading translations). User-facing conversation is in Korean.

## Preconditions

Before starting, check:

1. **`feature_list.json` must exist.** If not → "feature_list.json이 없어요. `/init-project`부터 시작할까요?"
2. **Identify target feature:**
   - If invoked with argument (`/feature-plan F007`): use that feature ID
   - If no argument: find the first `passes: false` feature in priority order
   - If all features pass: "모든 기능이 완료됐어요. 새 기능을 추가하시겠어요?"
3. **If target feature already has a `plan` field:**
   > "F[XXX]에 이미 계획이 있어요. 새로 만들까요, 기존 걸 유지할까요?"
   Wait for user response.
4. **Check `depends_on`:** If the target feature has `depends_on` and any dependency has `passes: false`, warn:
   > "⚠️ F[XXX]는 F[YYY]에 의존하는데, 아직 완료 안 됐어요. 그래도 계획할까요?"

## Step 1: Read Context (silent)

Read all available context sources. Missing files are fine — work with what exists.

| Source | Purpose |
|---|---|
| `feature_list.json` | Target feature + completed features for context |
| `docs/Architecture.md` or `Architecture.md` | Current project architecture |
| `CLAUDE.md` | Project rules and conventions |
| `~/.claude/rules/lessons-learned.md` | Past mistakes (global, cross-project) |
| `~/.claude/rules/instincts.md` | Positive patterns (global) |
| `HANDOFF.md` | Previous session context |
| `ADVANCED_SKELETON.md` or `PRD.md` | Full spec for the feature (via `skeleton_ref`) |
| `git log --oneline -10` | Recent commits |
| `git diff --stat` | Uncommitted changes |

Also check: does the project have existing code? What patterns/conventions are established?

## Step 2: Analyze (silent)

### 2a. What this feature needs
- Parse the feature's `description` and `skeleton_ref` (if present) to find the full spec
- Identify the concrete deliverable: new skill file? code change? config? hook?
- Determine scope boundaries — what's in, what's explicitly out

### 2b. What's already built
- List completed features (`passes: true`) and their descriptions
- Identify existing files/patterns this feature builds on or integrates with
- Note established conventions (file naming, structure, interaction patterns)

### 2c. What could go wrong
- Unmet `depends_on` dependencies
- Lessons-learned entries relevant to this type of work
- Potential conflicts with recent commits or uncommitted changes
- Complexity assessment (XS/S/M/L)

### 2d. How to verify
- Skill/file deliverable → file existence + content structure check
- UI feature → browser check
- Hook/automation → execution test
- Integration → cross-feature check

## Step 3: Present Plan

Present the plan in Korean, conversational style:

```
📋 F[XXX] — [Feature Name] 구현 계획

이 기능이 하는 일:
  [한두 문장으로 기능 설명]

만들거나 수정할 파일:
  - [path/to/file1] — [역할 한 줄]
  - [path/to/file2] — [역할 한 줄]

구현 단계:
  1. [구체적 단계 — 무엇을, 어디에]
  2. [구체적 단계]
  3. [구체적 단계]
  [3-5단계, 최대 5]

주의할 점:
  - [리스크 — 왜 위험한지 + 대응] [verified/high/medium/guess]
  [없으면 "특별한 리스크 없음"]

과거 교훈 반영:
  - [lessons-learned/instincts에서 관련 항목]
  [없으면 생략]

검증 방법:
  - [확인 방법 + 구체적 체크 항목]

예상 복잡도: [XS/S/M/L] [confidence tag]

▶ 이 계획으로 진행할까요? (수정할 부분 있으면 말씀해주세요.)
```

**Wait for user confirmation before proceeding.**

## Step 4: Handle User Response

### Confirmed ("네", "좋아", "진행", "시작", "ㅇㅇ"):
Proceed to Step 5.

### Adjustment requested:
- Apply feedback, re-present modified sections only, wait for re-confirmation.

### Redirected to different feature:
- Restart from Preconditions with the new feature.

### Cancelled:
- Don't save. End skill.

## Step 5: Save Plan to feature_list.json

After confirmation, add the `plan` field to the target feature:

```json
"plan": {
  "generated_at": "YYYY-MM-DD",
  "context_sources": ["Architecture.md", "lessons-learned.md"],
  "files_to_touch": [
    "path/to/file1",
    "path/to/file2"
  ],
  "steps": [
    "Step 1: concrete action",
    "Step 2: concrete action",
    "Step 3: concrete action"
  ],
  "risks": [
    "Risk description"
  ],
  "verification": [
    "Check 1",
    "Check 2"
  ],
  "complexity": "S"
}
```

Confirm:
> "계획이 저장됐어요. 구현 시작할게요."

## Step 6: Begin Implementation

After saving, proceed directly to implementation following the plan steps. The plan is the roadmap — follow it unless new information surfaces.

If implementation reveals the plan needs adjustment, pause and inform the user before deviating.

## Quality Checks

Before presenting the plan, verify:
- [ ] **Files to touch** lists specific paths (not vague descriptions)
- [ ] **Steps** are 3-5, each actionable (what + where)
- [ ] **Risks** reference specific features/files if dependency-related
- [ ] **Verification** matches the feature type
- [ ] **Complexity** is one of XS/S/M/L
- [ ] **Lessons/instincts** acknowledged if relevant entries exist
- [ ] **Confidence tags** applied to risks and complexity per `~/.claude/rules/confidence-tags.md`

## Hard Rules

- **NEVER start implementing before user confirms the plan.**
- **NEVER fabricate file paths.** Verify with Glob/Read that referenced paths exist or will be created.
- **NEVER ignore lessons-learned or instincts.** If relevant entries exist, the plan must acknowledge them.
- **NEVER produce plans longer than 5 steps.** If genuinely complex, propose splitting.
- **NEVER skip the risk assessment.** Even if minimal, state "특별한 리스크 없음."
- **ALWAYS present the plan in Korean.**
- **ALWAYS save to feature_list.json** after user confirmation.
- **ALWAYS check depends_on** — blocked features need explicit handling.
