---
name: architecture-sketch
description: Use AFTER prd-creator and BEFORE init-project to propose a tech stack, folder layout, and data flow that the user can validate before scaffolding. Triggers on "/architecture-sketch", "아키텍처", "구조 잡아줘", "기술 스택", "tech stack", "어떤 기술로", "설계 제안", "프로젝트 구조", "구조 제안해줘", "스택 추천". Also invoke when prd-creator just completed and the user says "다음" or "이제 만들자" — architecture-sketch comes BEFORE init-project. Outputs ARCHITECTURE_PROPOSAL.md which init-project will consume.
---

# architecture-sketch

<!-- PRD가 있고 init-project 전에, 사용자가 기술 스택과 프로젝트 구조를 확인할 수 있게 하는 스킬. -->
<!-- 비개발자를 위해 설계: 기술 결정을 사용자 관점의 영향(속도, 복잡도, 접근성)으로 설명. -->

## Overview

Read the PRD, analyze what's being built, and propose an architecture the user can validate **before** init-project creates any files. Surfaces direction-level choices (where it runs, where data lives, how complex) while making engineering-level decisions (framework, build tool, lint config) silently.

The user should feel like they're approving a blueprint, not choosing from a tech menu.

## ⚠️ Output Convention

`ARCHITECTURE_PROPOSAL.md` follows the bilingual convention:
- English body, Korean explanatory comments (`<!-- 한글 -->`)
- Save to project root (alongside PRD.md)

## Preconditions

Before starting, check:

1. **PRD.md must exist.** If not → "PRD가 먼저 필요해요. `/prd-creator`부터 시작할까요?"
2. **If ARCHITECTURE_PROPOSAL.md already exists** → "이미 아키텍처 제안서가 있어요. 새로 만들까요, 기존 걸 수정할까요?"

Read silently: `PRD.md`, and `BRAINSTORM.md` if it exists.

## Cost Estimate

<!-- 비용 추정: PRD 분석 + 대안 생성은 중간 규모 컨텍스트 -->

Before starting, show:

```
💰 예상 비용: 컨텍스트 중 (PRD + BRAINSTORM 읽기 + 대안 분석). 진행할까요?
```

After skill completes, append to `.claude/cost-log.jsonl` per `~/.claude/rules/cost-awareness.md`.

## Step 1: Analyze PRD (silent)

Extract from PRD.md:
- **Product type**: What is being built? (web app, CLI tool, script, desktop app, API, automation, etc.)
- **Feature inventory**: Count and complexity of features; any that imply specific tech (e.g., "실시간 알림" → WebSocket, "이메일" → email API)
- **Target user/environment**: Who runs it, where, on what devices?
- **External dependencies**: APIs, services, databases mentioned or implied
- **Complexity signal**: Feature count × integration count → rough XS/S/M/L estimate

Do NOT present this analysis to the user. Use it to inform the recommendation.

## Step 2: Present Recommended Architecture

Lead with the recommendation and its strengths. Use user-facing language, not framework jargon.

Template (adapt per project):

> "PRD를 분석했어요. 이 프로젝트에 맞는 구조를 제안합니다.
>
> **추천 스택: [이름 — 예: "Next.js + SQLite 웹앱"]**
>
> 이 스택의 장점:
> - [사용자 관점 강점 1 — 예: "브라우저에서 바로 쓸 수 있어서 설치가 필요 없어요"]
> - [사용자 관점 강점 2 — 예: "데이터가 로컬에 저장돼서 서버 비용이 없어요"]
> - [사용자 관점 강점 3 — 예: "나중에 배포하기도 쉬워요"]
>
> **프로젝트 구조:**
> ```
> project-name/
> ├── src/
> │   ├── ...
> │   └── ...
> ├── ...
> └── package.json
> ```
>
> **데이터 흐름:**
> ```
> [사용자 입력] → [처리 단계] → [결과/저장]
> ```
>
> **프로젝트 복잡도: [XS/S/M/L]**
> [한 문장으로 이게 사용자에게 뭘 의미하는지 — 예: "기능 5개 이하의 간단한 프로젝트, 하루면 기본 구조 완성 가능"]"

## Step 3: Surface Direction-Level Choices

After presenting the recommendation, identify if there are **direction-level** choices the user should weigh in on. These are choices where:
- Either option is defensible
- The trade-off affects something the user can feel (speed, complexity, access, cost)
- The user's preference matters more than engineering best practice

### Types of direction-level choices (pick relevant ones, max 2):

| Choice | When to surface | User-facing framing |
|---|---|---|
| **Where does it run?** | PRD doesn't specify platform clearly | "내 컴퓨터에서만 vs 브라우저에서 어디서든" |
| **Where is the data?** | Multiple valid storage options | "파일로 간단히 vs DB로 구조적으로" |
| **How complex?** | Features could be built minimal or structured | "빠르게 동작하는 최소 버전 vs 나중에 확장하기 좋은 구조" |
| **Hosted or local?** | Web app that could be static or hosted | "내 컴퓨터에서 실행 vs 인터넷에 올려서 어디서든" |

Present each as a conversation question (one at a time):

> "한 가지 방향을 정하면 좋겠어요:
>
> 1. **[옵션 A]** — [강점]. [트레이드오프]
> 2. **[옵션 B]** — [강점]. [트레이드오프]
>
> → 추천은 **[A or B]**입니다. [왜 — 한 문장]. 어떻게 하실래요?"

Wait for user's answer before continuing.

### When to skip choices:

If the PRD makes the direction obvious (e.g., "Python 스크립트", "Chrome 확장", "웹사이트"), there's nothing to ask. Just present the recommendation with:

> "다른 방향 원하시면 말씀해주세요."

### Execution-detail decisions (decide silently):

These are engineering choices the skill decides without asking. Briefly note them in the ARCHITECTURE_PROPOSAL.md under "Technical Decisions" but don't surface as questions:

- Specific framework/library (React vs Vue vs Svelte)
- Package manager (npm vs pnpm vs yarn)
- Test framework
- Lint/format config
- Build tool
- CSS approach (Tailwind vs CSS modules vs vanilla)
- API layer (REST vs tRPC vs GraphQL)

For each, pick the option that is: (a) most common (largest ecosystem), (b) simplest for the project size, (c) best supported by Claude Code.

## Step 4: Save ARCHITECTURE_PROPOSAL.md

After user confirms the recommendation (and any choices are resolved), save:

```markdown
<!-- 아키텍처 제안서. init-project가 이 문서를 읽고 프로젝트를 스캐폴딩한다. -->
<!-- 본문 영어, 한글은 HTML 주석. -->

# Architecture Proposal — [Project Name]

## Product Summary
<!-- PRD에서 추출한 한 줄 요약 -->
[One sentence from PRD]

## Recommended Stack
<!-- 추천 기술 스택 -->
- **Runtime**: [e.g., Node.js 20+]
- **Framework**: [e.g., Next.js 14 (App Router)]
- **Language**: [e.g., TypeScript]
- **Styling**: [e.g., Tailwind CSS]
- **Data**: [e.g., SQLite via Prisma / local JSON files / Supabase]
- **Deployment target**: [e.g., Vercel / local only / Cloudflare Pages]

### Why this stack
<!-- 이 스택을 추천하는 이유 (사용자 관점) -->
[2-3 bullet points, user-facing language] [each with confidence tag]

## Project Structure
<!-- 제안 폴더 구조 (아직 생성 안 됨) -->
```
[folder tree with brief annotations]
```

## Data Flow
<!-- 핵심 데이터 흐름 -->
```
[ASCII diagram: input → processing → output/storage]
```

## Alternatives Considered
<!-- 검토했으나 추천하지 않는 대안 -->

### [Alternative 1 name]
- **Strengths**: [what's good about it]
- **Why not chosen**: [concrete reason — not "worse", but specific trade-off] [confidence tag]

### [Alternative 2 name]
- **Strengths**: [what's good about it]
- **Why not chosen**: [concrete reason] [confidence tag]

## Technical Decisions
<!-- 엔지니어링 세부 결정 (사용자에게 질문 안 한 것들) -->
| Decision | Choice | Reason |
|---|---|---|
| [e.g., Package manager] | [e.g., npm] | [e.g., Default, widest compatibility] |
| [e.g., Test framework] | [e.g., Vitest] | [e.g., Fast, Vite-native] |

## Complexity Estimate
<!-- 프로젝트 복잡도 추정 -->
**[XS / S / M / L]** — [one sentence explanation of what this means for timeline and effort] [confidence tag]

## User Decisions Recorded
<!-- 사용자가 직접 결정한 방향 선택 -->
- [e.g., "웹앱으로 브라우저에서 접근" (over desktop app)]
- [e.g., "로컬 SQLite" (over cloud DB)]
```

Then confirm:

> "ARCHITECTURE_PROPOSAL.md에 저장했어요. `/init-project`를 부르면 이 구조대로 프로젝트를 만들어요."

## Quality Check Before Saving

All checks must pass:

- [ ] **Recommended Stack** has concrete names (not "a web framework" but "Next.js 14")
- [ ] **Project Structure** shows actual proposed folder/file names
- [ ] **Data Flow** has an ASCII diagram (not just text description)
- [ ] **At least 2 Alternatives** are documented with specific rejection reasons
- [ ] **Complexity Estimate** is one of XS/S/M/L with a user-facing explanation
- [ ] **Technical Decisions** table has at least 3 entries
- [ ] **User Decisions** lists any direction-level choices the user made (empty only if no choices were surfaced)
- [ ] **Confidence tags** applied to stack reasoning, alternative rejections, and complexity per `~/.claude/rules/confidence-tags.md`

## Hard Rules

- **NEVER scaffold files.** This skill proposes; init-project creates. No `mkdir`, no `npm init`, no file writes except ARCHITECTURE_PROPOSAL.md.
- **NEVER ask the user to choose between specific frameworks/libraries.** "React vs Vue"는 engineering detail — skill이 결정. "웹 vs 데스크톱"은 direction — 사용자가 결정.
- **NEVER present more than 2 direction-level choices.** If more exist, pick the 2 most impactful and decide the rest silently.
- **NEVER skip the data flow diagram.** Even for simple scripts, show the flow.
- **NEVER auto-invoke init-project after saving.** Tell the user to do it.
- **ALWAYS lead with recommendation strengths**, then mention trade-offs. Not the reverse.
- **ALWAYS include at least 2 alternatives** even if the recommendation is obvious — the user should see that options were considered.
- **ALWAYS use user-facing language** in the conversation. Save technical details for the artifact's "Technical Decisions" table.
