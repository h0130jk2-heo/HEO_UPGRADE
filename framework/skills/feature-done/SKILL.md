---
name: feature-done
description: Use when a feature is complete or the user says things like "기능 완료", "이거 됐어", "다음 기능으로", "테스트해줘", "완료됐어", "끝났어", or calls /feature-done directly. Triggers the full QA → update → commit → next feature pipeline. NEVER skip this skill when the user declares any feature complete.
---

# feature-done

<!-- 기능 하나가 완료됐을 때 테스트→기록→커밋→다음 기능 제안까지 한 번에 처리하는 스킬 -->

Handles the full pipeline when a single feature is declared complete:
QA test → update records → git commit → suggest next feature.

## ⚠️ 산출물 작성 규칙

이 skill이 **기록/수정하는 모든 파일 산출물**(progress.md, docs/Architecture.md, CLAUDE.md의
과거 실수 패턴 섹션, lessons-learned.md 등)은 **영어 본문 + 한글 주석** 형식을 유지한다.

- Markdown: 본문 영어. 한글 주석은 비자명한 맥락 설명에만 사용 (제목 번역 금지)
- 기존 파일을 수정할 때도 해당 파일의 영문 스타일을 따라간다 (새 줄만 한국어로 추가하지 말 것)
- 커밋 메시지는 한국어 유지 가능 (기존 프로젝트 컨벤션 존중)
- 사용자와의 대화는 한국어

## Pre-flight Check

<!-- feature_list.json 없으면 바로 중단 -->

If `feature_list.json` does not exist, stop immediately and tell the user:
> "feature_list.json not found. Please run /init-project first."

## Execution Steps

### Step 1: Identify the Current Feature

<!-- feature_list.json에서 현재 작업 중인 기능(passes: false) 찾기 -->

Read `feature_list.json`. Find the item currently being worked on (`passes: false`).
Load its `steps[]` array — these are the acceptance criteria to verify.

---

### Step 1-B: Consume Verify Report

<!-- verify-stack 리포트가 있으면 QA 증거로 사용. FIX_REQUIRED면 중단. 완료 후 삭제. -->

Check `.claude/verify-report-<feature-id>.md`: **FIX_REQUIRED** → stop and fix first. **PROCEED** with warnings → note them, continue. **Missing** → continue (verify-stack recommended, not mandatory). Delete the report after Step 2-A completes.

---

### Step 1-C: Run Automated Tests (TDD Gate)

If the feature's `plan.test_spec.testable` is `true`:
1. Run the test suite (`npm test`, `pytest`, `Invoke-Pester`, etc.)
2. ALL tests must PASS. If any fail → STOP. Fix first, re-run, do NOT proceed.
3. Output:
```
Automated Tests:
✅ [test name] — passed
❌ [test name] — FAILED: [reason]
```

If `test_spec.testable` is `false` or no `test_spec` exists → skip to Step 2.

---

### Step 2: QA Testing (Strict)

**Role:** Act as a strict QA tester. Verify each `step` by actually checking — not by eyeballing.

Verification methods:
- File existence → use Read / Glob directly
- Logic correctness → read code, trace execution path
- UI / visual → open in browser if applicable

Output results:
```
Manual QA:
✅ [step description] — passed
❌ [step description] — FAILED: [specific reason]
```

> **WARNING:** Setting `passes: true` without running tests (Step 1-C) AND manual QA (Step 2) is strictly forbidden.

---

### Step 2-A: All Tests Pass

<!-- 전체 통과 시 3단계 처리: feature_list 업데이트 → progress.md 기록 → git commit -->

**1. Update `feature_list.json`**
Set the current feature's `passes` field to `true`.

**2. Update `progress.md`**
Append a completion entry:
```
- [YYYY-MM-DD] [feature name]: [one-line summary]
```
Create `progress.md` if it does not exist.

**3. Update `docs/Architecture.md`**

<!-- 새 파일/폴더가 생겼으면 docs/Architecture.md를 업데이트 -->

이번 기능에서 새로 만들어진 파일/폴더가 있는지 `git diff --name-only HEAD` 로 확인한다.
새 파일/폴더가 있으면 `docs/Architecture.md`를 업데이트한다 (CLAUDE.md 직접 수정 금지 — CLAUDE.md는 Architecture.md를 참조만 함):

- "폴더 구조" 트리에 새 항목 추가 + "(예정)" 표시 제거 (한 줄 설명 포함)
- "주요 파일 역할"에 핵심 파일 1줄 요약 추가 (예: `- scripts/F001_list_inbox.ps1 — Outlook COM 연결 + 받은편지함 출력`)
- 기능 간 데이터 흐름이 생겼으면 "데이터 흐름"에 기록 (예: `F002 → output/invoice_mails.json → F003`)

목적: 다음 세션의 에이전트가 폴더 탐색 없이 Architecture.md만 읽고 바로 구조를 파악할 수 있게 하기 위함.

**4. Analyze `.claude/failures.log`**

<!-- failures.log가 있으면 패턴 분석 → CLAUDE.md 업데이트 → 초기화 후 별도 커밋 -->

Check if `.claude/failures.log` exists and has content:

```powershell
Test-Path .claude/failures.log
Get-Content .claude/failures.log
```

**If the file exists and is non-empty:**

a. Read the file and identify recurring patterns — any error type or mistake that appears **2 or more times** qualifies as a pattern worth recording.

b. For each pattern found, append an entry to the **global** `~/.claude/rules/lessons-learned.md`
   (cross-project knowledge base — shared across all projects):
```
- [YYYY-MM-DD] [project-name] 문제: [무엇이 잘못됐는지] → 해결: [어떻게 해결했는지]
```
Create the file (and `~/.claude/rules/` directory) if it does not exist. There is no line limit for this file.
프로젝트명을 항목 앞에 붙여 다른 프로젝트와 구분되게 한다.

c. Check `CLAUDE.md` line count:
```powershell
(Get-Content CLAUDE.md).Count
```
If it exceeds 200 lines, warn the user:
> "⚠️ CLAUDE.md가 현재 [N]줄입니다. 오래된 항목을 정리하는 것을 권장합니다."

d. Clear `failures.log` (empty it for the next feature):
```powershell
Clear-Content .claude/failures.log
```

e. Commit only the project-local change (the global lessons-learned lives outside the repo):
```
git add .claude/failures.log
git commit -m "chore: clear failures.log after lessons captured"
```
전역 `~/.claude/rules/lessons-learned.md` 변경은 어떤 프로젝트의 git에도 포함되지 않는다.

**If the file does not exist or is empty:** skip this step entirely.

**5. Record Successes**

<!-- 성공 패턴도 기록. /reflect가 나중에 confidence 업그레이드. -->

Append to `~/.claude/rules/instincts.md` (1 line, concise):
`- [YYYY-MM-DD] [project] 상황: [built what] → 좋은 접근: [what worked] (confidence: low — 1회 관찰)`

**6. Git commit**
```
git add .
git commit -m "feat: [feature name] - [one-line description]"
```

**7. Suggest the next feature**

<!-- feature_list.json에서 passes: false 항목 중 우선순위 1개 제안 -->

Find the highest-priority item with `passes: false` in `feature_list.json` and suggest it:
> "Next up: **[feature name]** — [brief description]"

---

### Step 2-B: Any Test Fails

<!-- 실패 시: 원인 명시 → 수정 → 재테스트 → 반복 패턴이면 CLAUDE.md에 기록 -->

1. Clearly state which step failed and why.
2. Fix the issue, then retest that specific step.
3. If this matches a recurring mistake pattern:
   - Add an entry to the `## 과거 실수 패턴` section in `CLAUDE.md`:
     ```
     - [YYYY-MM-DD] Problem: [what went wrong] → Fix: [how it was resolved]
     ```
   - Check the line count of `CLAUDE.md`:
     ```powershell
     (Get-Content CLAUDE.md).Count
     ```
     <!-- 200줄 초과 시 경고 출력 -->
     If it exceeds 200 lines, warn the user:
     > "⚠️ CLAUDE.md is now [N] lines. Consider trimming older entries."
   - Commit the CLAUDE.md update separately:
     ```
     git commit -m "docs: update lessons learned"
     ```

---

## Core Rules

<!-- 이 스킬의 존재 이유 = 테스트 없이 완료 선언하는 습관을 막는 것 -->

- Setting `passes: true` without testing → **strictly forbidden**
- "The code looks right" → **run the test, then decide**
- Hiding failures and moving on → **destroys the reliability of this workflow**
