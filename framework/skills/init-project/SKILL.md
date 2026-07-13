---
name: init-project
description: >
  Use this skill when the user wants to set up a project environment, initialize a project,
  or start coding after a PRD is ready. Triggers on: "/init-project", "프로젝트 시작",
  "환경 세팅", "초기화", "세팅 해줘", "코딩 시작하자", "프로젝트 셋업", or right after
  prd-creator completes. ALWAYS use this skill when the user wants to go from PRD to
  code — don't just start coding without running this first.
  Consumes ARCHITECTURE_PROPOSAL.md (from /architecture-sketch) for precise tech stack,
  folder layout, and data flow, and DESIGN_PROPOSAL.md (from /design-sketch) for design
  tokens (typography, color, spacing) which it scaffolds into a base stylesheet. Installs
  language packs (.claude/rules/<lang>.md) based on detected stack.
---

# init-project

PRD.md가 완성된 후, 코딩 에이전트가 바로 작업을 시작할 수 있도록 프로젝트 환경을 자동으로 세팅하는 스킬.

## ⚠️ 산출물 작성 규칙 (모든 Step 공통)

**이 skill이 생성하는 모든 파일 산출물은 영어 본문 + 한글 주석으로 작성한다.**

- Markdown 파일 (`CLAUDE.md`, `docs/Architecture.md`, `progress.md`): 본문 영어. 한글 주석은 비자명한 맥락에만 (제목 번역 금지)
- 코드/설정 파일: 본문 영어, 한글 주석은 해당 언어 주석 문법 (`# 한글`, `// 한글`)
- JSON 파일의 `description` 같은 자유 텍스트 필드도 영어 (예: feature_list.json의 description은 영어로)
- 사용자와의 대화는 계속 한국어 — 이 규칙은 **파일 산출물에만** 적용된다
- 아래 Step들의 템플릿은 한국어로 예시를 보이지만, **실제 생성 시 영어로 변환하고 한글은 주석으로 옮길 것**

## Step 1: PRD.md + ARCHITECTURE_PROPOSAL.md 확인

### 1a. PRD.md (필수)

PRD.md를 프로젝트 루트에서 읽는다.

- 없으면: "PRD.md가 없어요. 먼저 `/prd-creator`를 실행해서 PRD를 만들어주세요." 안내 후 종료.
- 있으면: 다음 정보를 추출한다.
  - 제품 한 줄 정의
  - 기술 스택 / 제약 조건 (Constraints 섹션)
  - Must Have 기능 목록
  - Should Have 기능 목록
  - Done Criteria

### 1b. ARCHITECTURE_PROPOSAL.md (선택, 강력 권장)

ARCHITECTURE_PROPOSAL.md를 프로젝트 루트에서 읽는다.

- **있으면**: 다음 정보를 추출하여 Step 2, 3.5, 6에서 우선 사용한다.
  - Recommended Stack (Runtime, Framework, Language, Styling, Data, Deployment target)
  - Project Structure (폴더 트리)
  - Data Flow (ASCII 다이어그램)
  - Technical Decisions 테이블
  - User Decisions 목록
  - Complexity Estimate
- **없으면**: PRD 기반으로 추론 (기존 방식). 사용자에게 안내한다:
  "ARCHITECTURE_PROPOSAL.md가 없어요. PRD 기반으로 진행합니다. 기술 스택 선택을 먼저 하려면 `/architecture-sketch`를 실행해주세요."

**핵심 원칙:** ARCHITECTURE_PROPOSAL.md가 있으면, 거기에 기록된 기술 결정이 PRD의 암묵적 추론보다 우선한다.

### 1c. DESIGN_PROPOSAL.md (선택, 화면 있는 프로젝트에 권장)

DESIGN_PROPOSAL.md를 프로젝트 루트에서 읽는다.

- **있으면**: Design Tokens(Typography, Color light/dark, Space/Radius/Motion), Chosen
  Direction, Key Components, Accessibility Commitments를 추출해 Step 3.7(디자인 토큰 스캐폴딩)과
  Step 2(CLAUDE.md)에서 사용한다.
- **없으면**: 건너뛴다. 화면이 있는 프로젝트인데 없으면 한 번만 안내한다:
  "DESIGN_PROPOSAL.md가 없어요. 디자인 방향 없이 진행하면 기본 스타일이 '평균적인 AI 룩'으로
  흐를 수 있어요. 먼저 `/design-sketch`로 방향을 정하려면 지금 멈춰도 돼요. 그냥 진행할까요?"
  사용자가 진행을 원하면 `~/.claude/rules/design.md`의 공통 코어만 기준으로 삼는다.

## Step 2: CLAUDE.md 생성 (프로젝트 루트)

PRD 내용을 바탕으로 **이 프로젝트에 맞게** CLAUDE.md를 동적으로 생성한다.
템플릿을 복붙하지 말고, PRD에서 읽은 실제 내용으로 채울 것.

반드시 포함할 섹션:

```markdown
# [Project Name] — Developer Guide

## Project Overview
(One-line summary + core purpose, in English)

## Tech Stack
<!-- Source: ARCHITECTURE_PROPOSAL.md if exists, else PRD Constraints -->
- **Runtime**: [e.g., Node.js 20+]
- **Framework**: [e.g., Next.js 14]
- **Language**: [e.g., TypeScript]
- **Styling**: [e.g., Tailwind CSS] (if applicable)
- **Data**: [e.g., SQLite via Prisma]
- **Deployment**: [e.g., Vercel / local only]
- **Disallowed**: ... (reason)

## Working Principles
- Work on one feature at a time.
- Verify actual behavior before declaring completion.
- Never delete data files (JSON, etc.).
- Prefer editing existing files over creating new ones.

## Behavioral Guidelines

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution
**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Output Language Convention
All project artifacts are written in English. Korean HTML comments only when they add non-obvious context (not heading translations). Conversation with the user stays in Korean.

## Codebase Structure
See **`docs/Architecture.md`** for folder tree, file roles, and data flow.
`feature-done` updates `docs/Architecture.md` whenever new files/folders appear.

## Session Start Routine
1. `progress.md` — current state and next task
2. `feature_list.json` — remaining features (`passes: false`)
3. `docs/Architecture.md` — codebase structure and data flow
4. `git log --oneline -10` — recent change history

## Past Mistake Patterns
<!-- 초기엔 비어있음. feature-done 이 .claude/rules/lessons-learned.md 에 누적. -->
(Empty at start.)
```

200줄을 넘지 않도록 유지한다. 폴더별 세부 규칙이 필요하면 `.claude/rules/` 아래에 분리 파일로 만든다.

## Step 3: feature_list.json 생성

PRD의 Must / Should 기능을 최대한 작게 쪼개서 JSON으로 만든다.

**쪼개는 기준:**
- 나쁜 예: `"Outlook 메일 감지 기능"`
- 좋은 예: `"Invoice 키워드가 포함된 제목의 Outlook 메일을 감지하여 콘솔에 출력한다"`

각 항목의 steps[]는 구현 단계를 2~4개로 구체적으로 작성한다.

```json
{
  "project": "[Project Name]",
  "created_at": "[today's date]",
  "_convention": "description and steps are English. 'note_ko' carries the Korean one-liner for quick human scanning.",
  "features": [
    {
      "id": "F001",
      "category": "Must",
      "description": "Concrete, observable behavior in English",
      "note_ko": "한글 한 줄 요약 (세션 시작 hook 출력에 사용)",
      "steps": [
        "Step 1 in English",
        "Step 2 in English"
      ],
      "passes": false
    }
  ]
}
```
<!-- session-start.sh hook 은 note_ko 가 있으면 우선 표시. -->
<!-- JSON은 주석 문법이 없어 `_convention` 필드로 규칙 문서화. -->

모든 항목은 `passes: false`로 초기화한다.

## Step 3.5: docs/Architecture.md 생성

`docs/` 폴더를 만들고 아래 내용으로 `docs/Architecture.md`를 생성한다.
초기 폴더 트리는 PRD의 기술 스택/기능 목록을 참고해 예상 경로까지 미리 채운다.

```markdown
<!-- 코드베이스 구조 문서. 본문 영어 + 한글 주석. feature-done 이 자동 업데이트. -->

# Architecture — [Project Name]

Living document of the codebase structure. Updated by the `feature-done` skill
whenever new files or folders are introduced.

## Folder Layout
<!-- ARCHITECTURE_PROPOSAL.md 의 Project Structure 섹션에서 가져옴. -->
<!-- 없으면 PRD 기반 초기 예상 트리. 미생성 항목은 "(planned)" 표시. -->
(From ARCHITECTURE_PROPOSAL.md Project Structure, or predicted from PRD.)

## Key File Roles
<!-- 기능 완료 시 한 줄씩 누적 -->
(Populated starting from F001 completion.)

## Data Flow
<!-- ARCHITECTURE_PROPOSAL.md 의 Data Flow 다이어그램에서 가져옴. -->
<!-- 없으면 기능이 2개 이상 연결될 때부터 기록. -->
(From ARCHITECTURE_PROPOSAL.md Data Flow diagram, or recorded once two features form a pipeline.)
```

## Step 3.7: 디자인 토큰 스캐폴딩 (DESIGN_PROPOSAL.md 있을 때만)
<!-- 화면 있는 프로젝트에서, 확정된 디자인 방향을 실제 코드 기반으로 심는다. 없으면 이 단계 통째로 건너뜀. -->

DESIGN_PROPOSAL.md가 있으면, 거기 기록된 토큰을 **스택의 스타일링 방식에 맞는 형태**로 실제 파일에 심는다.

### 형태 선택 (Tech Stack의 Styling에 맞춤)
| Styling 방식 | 산출 형태 |
|---|---|
| Tailwind | `tailwind.config`의 theme(색/폰트/spacing/radius) + `:root` CSS 변수(다크: `.dark`) |
| CSS Modules / vanilla CSS | `src/styles/tokens.css` — `:root`(light) + `@media (prefers-color-scheme: dark)` 또는 `[data-theme="dark"]` |
| styled-components / CSS-in-JS | `src/theme.ts` — light/dark theme 객체 |
| 순수 HTML 산출물 (전역 CLAUDE.md의 HTML 목표) | 단일 `<style>`의 `:root` 토큰 블록 (외부 의존 없이 self-contained) |

### 심을 내용
1. **Color 토큰** — DESIGN_PROPOSAL의 semantic 토큰을 light/dark **양쪽** 정의(단순 반전 금지).
   다크 본문 텍스트는 순백(#FFF) 대신 ~#FAFAFA.
2. **Typography** — heading/body 폰트, scale, body 크기, line-height.
3. **Space / Radius / Motion** — spacing 스케일, radius, 기본 duration/easing +
   `@media (prefers-reduced-motion: reduce)` 축소 블록.
4. 접근성 커밋(대비·키보드·색 단독 금지)을 코드 주석으로 남겨 이후 feature가 참조하게 한다.

### 시각 앵커 보존 (design-refs/)
<!-- 토큰은 일관성만 준다. 방향(취향)은 그림이 준다. design-refs/를 반드시 보존한다. -->

DESIGN_PROPOSAL.md의 **Visual References**가 가리키는 `design-refs/` 폴더(고른 방향의 실제 화면
mockup)는 **삭제하지 않고 프로젝트에 보존**한다. 이건 이후 각 기능 구현·검증(feature-done Step 2-V)이
대조하는 시각 앵커다. CLAUDE.md의 Tech Stack/Codebase Structure 근처에 한 줄 포인터를 남긴다:
`Design anchor: design tokens in [파일] + reference screens in design-refs/ (see DESIGN_PROPOSAL direction).`

### 안내
> "DESIGN_PROPOSAL의 디자인 토큰을 [산출 파일]에 심고, 방향 화면은 `design-refs/`에 보존했어요.
> 이후 모든 기능은 이 토큰 + 화면을 기준으로 만들어지고 feature-done에서 스크린샷으로 대조돼요."

DESIGN_PROPOSAL.md가 없으면 이 단계를 건너뛰고, 필요 시 `~/.claude/rules/design.md` 공통 코어를
스타일 판단 기준으로만 참조한다(파일 강제 생성은 하지 않는다).

## Step 4: progress.md 생성

```markdown
<!-- 진행 상황 추적. 본문 영어 + 한글 주석. feature-done 이 완료 항목 누적. -->

# Progress

## Last Updated
[today's date]

## Completed Features
(none — project just started)

## Current State
Project initialized. Ready to start the first feature.

## Next Task
Start implementing F001 from `feature_list.json`.

## Notes
<!-- 자유 메모 영역 -->
```

## Step 5: Hooks (전역에서 자동 적용)

세션 시작 요약 훅(`session-start.sh`)과 도구 에러 자동 기록 훅(`PostToolUse.sh`)은
**전역 `~/.claude/hooks/`에 이미 설치되어 있고** `~/.claude/settings.json`에 등록되어
모든 프로젝트에 자동 적용된다. 프로젝트별 hook 파일/설정을 만들 필요 없다.

훅이 만드는 산출물 (각 프로젝트의 cwd 기준):
- `.claude/failures.log` — 도구 실행 에러 자동 누적 (gitignore 처리됨)
- 세션 시작 시 `progress.md` / `feature_list.json` 기반 상태 요약 출력

훅이 누락된 환경(새 머신 등)이라면 전역 위치 확인:
```bash
ls ~/.claude/hooks/
ls ~/.claude/skills/
```

또한 `.claude/rules/lessons-learned.md`도 전역에 있고, `feature-done` 스킬이
누적 기록한다. 프로젝트별로 별도 생성할 필요 없다.

## Step 6: Language Pack 자동 설치

ARCHITECTURE_PROPOSAL.md (또는 PRD)에서 감지된 주 언어에 맞는 규칙 파일을 프로젝트의 `.claude/rules/`에 설치한다.

### 감지 로직

1. **ARCHITECTURE_PROPOSAL.md 있을 때**: `Recommended Stack → Language` 필드에서 주 언어 감지.
2. **없을 때**: PRD의 Constraints / Tech Stack 섹션에서 추론.
3. **둘 다 불명확할 때**: 사용자에게 물어본다: "주 언어가 뭔가요? (TypeScript, Python, PowerShell, 기타)"

### 설치할 팩

| 감지된 언어 | 설치 파일 | 소스 |
|---|---|---|
| TypeScript / JavaScript | `.claude/rules/typescript.md` | `~/.claude/skills/init-project/packs/typescript.md` |
| Python | `.claude/rules/python.md` | `~/.claude/skills/init-project/packs/python.md` |
| PowerShell | `.claude/rules/powershell.md` | `~/.claude/skills/init-project/packs/powershell.md` |

### 설치 방법

1. 프로젝트 루트에 `.claude/rules/` 디렉토리가 없으면 생성.
2. 소스 팩 파일을 읽어서 프로젝트의 `.claude/rules/<lang>.md`에 복사.
3. 프로젝트가 여러 언어를 사용하면 (예: TS 프론트엔드 + Python 백엔드) **해당되는 팩을 모두** 설치.
4. 이미 같은 이름의 규칙 파일이 있으면 덮어쓰지 않고 안내: "이미 `.claude/rules/<lang>.md`가 있어요. 덮어쓸까요?"

### 사용자 안내

설치 후 알린다:
> "[Language] 코딩 규칙을 `.claude/rules/<lang>.md`에 설치했어요. 이 규칙은 이 프로젝트에서 Claude가 코드를 쓸 때 자동으로 참조합니다."

## Step 6.5: 테스트 프레임워크 셋업

감지된 언어에 맞는 테스트 프레임워크를 설치한다. 테스트 가능한 로직이 있는 기능에서 TDD를 지원하기 위함.

| 언어 | 테스트 프레임워크 | 설치 명령 |
|---|---|---|
| TypeScript/JavaScript | Vitest (Vite 프로젝트) 또는 Jest | `npm install -D vitest` 또는 `npm install -D jest` |
| Python | pytest | `pip install pytest` |
| PowerShell | Pester | 기본 탑재 (5.x) |

### 셋업 절차

1. 감지된 언어의 테스트 프레임워크 설치
2. `package.json`에 `"test"` 스크립트 추가 (JS/TS) 또는 `pytest.ini` 생성 (Python)
3. CLAUDE.md의 Tech Stack 섹션에 테스트 프레임워크 기록
4. `.gitignore`에 coverage 디렉토리 추가 (`coverage/`, `.coverage`, `htmlcov/`)

프로젝트가 순수 설정/문서 프로젝트 (코드 로직 없음)인 경우 이 단계를 건너뛴다.

## Step 7: .gitignore 생성 및 git 초기화

먼저 현재 디렉토리에 git이 초기화되어 있는지 확인한다 (`git status`).
이미 초기화되어 있으면 git init은 건너뛴다.

.gitignore를 생성한다 (프로젝트 성격에 맞게 조정):

```
.env
*.log
output/temp/
dist/
*.tmp
.claude/failures.log
```

초기 커밋 (Step 3.7에서 디자인 토큰 파일을 만들었으면 그 경로도 함께 add):
```bash
git add CLAUDE.md feature_list.json progress.md docs/Architecture.md .gitignore .claude/rules/
# 디자인 토큰 파일이 있으면: git add src/styles/tokens.css (또는 tailwind.config / src/theme.ts 등)
# design-refs/가 있으면 함께 add (시각 앵커 — 보존): git add design-refs/
git commit -m "init: project scaffold from PRD"
```

## Step 8: ARCHITECTURE_PROPOSAL.md 삭제 + 완료 안내

### 8a. 제안서 정리

ARCHITECTURE_PROPOSAL.md를 소비했다면 삭제한다:
```bash
rm ARCHITECTURE_PROPOSAL.md
```
핵심 내용은 이미 `CLAUDE.md`(Tech Stack)와 `docs/Architecture.md`(Folder Layout, Data Flow)에 반영되었으므로 원본은 불필요.

DESIGN_PROPOSAL.md를 소비했다면(Step 3.7) 삭제한다:
```bash
rm DESIGN_PROPOSAL.md
```
디자인 토큰은 이미 스타일 파일(예: `tokens.css` / `tailwind.config` / `theme.ts`)에 심겼으므로 원본은 불필요.

### 8b. 완료 안내

다음 형식으로 결과를 출력한다:

```
✅ 프로젝트 초기화 완료

생성된 파일:
- CLAUDE.md (개발 가이드)
- feature_list.json ([N]개 기능)
- docs/Architecture.md (코드베이스 구조)
- progress.md (진행 상황 추적)
- .gitignore
- .claude/rules/[lang].md (언어팩 — [설치된 언어 목록])
- [디자인 토큰 파일 — DESIGN_PROPOSAL.md 있었을 때만, 예: src/styles/tokens.css]
- [design-refs/ — 시각 앵커 화면, 보존됨 — 있었을 때만]

소비된 파일:
- ARCHITECTURE_PROPOSAL.md → CLAUDE.md + Architecture.md에 반영 후 삭제
- [DESIGN_PROPOSAL.md → 토큰은 스타일 파일에, 시각 레퍼런스는 design-refs/에 남기고 원본 삭제 — 있었을 때만]

기능 목록 요약:
[Must] F001: ...
[Must] F002: ...
[Should] F003: ...

👉 이제 새 세션을 열고 작업을 시작하세요.
   첫 번째 기능: F001 — [설명]
```
