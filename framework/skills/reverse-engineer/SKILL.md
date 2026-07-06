---
name: reverse-engineer
description: Use when adopting or resuming an EXISTING codebase that HEO did not scaffold — analyze it and produce HEO-native project artifacts before feature work. Triggers on "/reverse-engineer", "역공학", "기존 코드 분석", "이 코드 분석해줘", "코드베이스 파악", "물려받은 프로젝트", "reverse engineer", "analyze existing code", "understand this codebase". Runs before /init-project on brownfield projects, and is offered by /resume-heo State C.
---

# reverse-engineer

<!-- 기존(브라운필드) 코드베이스를 분석해 HEO 산출물(Architecture.md + 인벤토리 + 의존성 맵)을 생성. -->
<!-- 비개발자를 위해: 결과를 "무엇을/어디서/무엇에 의존" 관점으로 요약. -->

## Overview

Analyze an existing codebase HEO did not create, and produce the same artifacts HEO
projects rely on — so the rest of the framework (feature-plan, verify-stack, feature-done)
works on inherited code. This is HEO's brownfield entry point.

The user should end up with a project they can drive with HEO, not a wall of analysis.

## ⚠️ Output Convention

- English body in artifacts; Korean comments only when they add non-obvious context.
- Write `Architecture.md` and the inventory to the project root.

## Cost Estimate

<!-- 대용량 코드베이스 스캔은 컨텍스트 비용이 큼 -->

Before starting, show:

```
💰 예상 비용: 컨텍스트 [소/중/대] (코드베이스 크기에 따라). 큰 저장소면 핵심 디렉터리만 스캔할까요?
```

Size = source file count (< 50: 소, 50–300: 중, > 300: 대). For 대, offer to scope
to the primary source directories. After completion, append to `.claude/cost-log.jsonl`.

## Preconditions

1. **Existing source must be present.** If the directory looks empty of code → "분석할 기존 코드가 안 보여요. 새 프로젝트면 `/prd-creator`부터 시작할까요?"
2. **If `Architecture.md` already exists** → "이미 Architecture.md가 있어요. 새로 분석할까요, 기존 걸 보완할까요?"

## Step 1: Survey the tree (silent)

- List top-level directories and detect the language/stack from manifest files
  (`package.json`, `requirements.txt`, `pyproject.toml`, `*.csproj`, `go.mod`, etc.).
- Identify entry points (main/index/app files, scripts) and the build/run command.
- Do NOT present raw file dumps. Summarize.

## Step 2: Map components and dependencies (silent)

- Group source into components/modules by responsibility (not by file type).
- For each component: what it does, its public surface, and what it depends on
  (internal modules + external packages).
- Build a dependency map (which component calls which; external deps per component).

## Step 3: Present a plain-language summary (Korean)

Present, in Korean, one concise summary the user can confirm:

```
이 코드베이스를 분석했어요:
  • 종류: [웹앱 / CLI / 라이브러리 / ...]  · 언어/스택: [...]
  • 실행 방법: [build/run 커맨드]
  • 주요 구성요소 ([N]개):
      - [이름] — [한 줄 역할]
      - ...
  • 외부 의존성: [핵심 몇 개]
  • 눈에 띄는 것: [위험/미완성/특이점 — 있으면] [confidence 태그]

▶ 이대로 Architecture.md 와 인벤토리를 저장할까요?
```

Wait for confirmation before writing.

## Step 4: Write artifacts

On confirmation, load `references/inventory-template.md` and write:
1. `Architecture.md` — overview, components, data flow (ASCII), tech stack. Mark
   observed-vs-inferred with confidence tags.
2. Component inventory + dependency map (per the template).

Then confirm:

> "Architecture.md와 인벤토리를 저장했어요. 이제 `/init-project`로 HEO 추적 파일(feature_list.json 등)을 붙이거나, 바로 `/feature-plan`으로 작업을 시작할 수 있어요."

## Step 5: Hand off

- Do NOT scaffold or modify existing source in this skill — analysis only.
- Do NOT auto-invoke init-project; tell the user their options.

## Quality Check Before Saving

- [ ] `Architecture.md` has overview + components + data-flow diagram + stack
- [ ] Component inventory lists every major component with a one-line responsibility
- [ ] Dependency map shows internal + external dependencies
- [ ] Observed facts vs inferences are distinguished with confidence tags
- [ ] No modification to existing source files

## Hard Rules

- **NEVER modify existing source code.** This skill reads and documents only.
- **NEVER fabricate architecture.** If unsure, tag `[guess]` and say so.
- **NEVER dump raw file contents** to the user — always summarize.
- **ALWAYS present the summary in Korean and wait** before writing artifacts.
- **ALWAYS write artifacts in HEO format** (Architecture.md), never AIDLC formats.
