---
name: pre-ship-check
description: "Pre-deployment readiness check. Use when the user calls /pre-ship-check, says \"배포 전 점검\", \"출시 준비\", \"ship 준비\", \"배포 가능?\", \"pre-ship\", \"출하 점검\", or before running /deploy. Verifies all features pass, no secrets leaked, docs exist, deploy target configured. Outputs a ship-readiness report."
---

# pre-ship-check

<!-- 배포 전 준비 상태 일괄 점검. project-doctor가 "프레임워크 건강"이면 이건 "출하 가능 여부". -->
<!-- 읽기 전용 진단 → 리포트 → 유저 선택 수정. project-doctor와 같은 패턴. -->

## Overview

Run 5 ship-readiness checks before deployment. Outputs a structured report with pass/warn/fail per check. The user picks which issues to fix — pre-ship-check never auto-modifies.

**Trigger:** On-demand (`/pre-ship-check`) or before `/deploy`.

## Preconditions

`feature_list.json` must exist. If not → "feature_list.json이 없어요. `/init-project`부터 시작할까요?"

## Step 1: Run All Checks (silent)

Run all 5 checks. Missing files are gracefully skipped (N/A, not failures).

### Check 1: All Features Pass

<!-- 모든 기능이 passes: true인지 확인 -->

- Read `feature_list.json`, count features where `passes: false`
- **Pass:** All features `passes: true`
- **Warn:** Only `Could` priority features remain incomplete
- **Fail:** Any `Must` or `Should` feature has `passes: false`
- Detail: list each incomplete feature with its priority

### Check 2: Unresolved Warnings

<!-- lessons-learned에 미해결 경고가 있는지 확인 -->

- Read `~/.claude/rules/lessons-learned.md`
- Read `~/.claude/rules/instincts.md`
- Look for entries tagged as unresolved or entries from the current project with `confidence: low` in instincts
- Also check: `.claude/failures.log` — if non-empty, there are uncaptured failures
- **Pass:** No unresolved warnings, failures.log empty or absent
- **Warn:** 1-2 low-confidence instincts from this project
- **Fail:** Non-empty failures.log (uncaptured failures exist)

### Check 3: Secrets Check

<!-- 커밋된 코드에 secrets가 노출됐는지 확인 -->

Scan all tracked files for secret patterns (same patterns as verify-stack Layer 1):

| Pattern | What to grep |
|---|---|
| API keys | `sk-`, `AKIA`, `ghp_`, `gho_`, `xox[bpas]-` |
| Hardcoded passwords | `password\s*=\s*["']`, `passwd`, `secret\s*=\s*["']` |
| Connection strings | `mongodb://.*:.*@`, `postgres://.*:.*@`, `mysql://.*:.*@` |
| Private keys | `BEGIN RSA PRIVATE KEY`, `BEGIN OPENSSH PRIVATE KEY` |
| Token assignments | `token\s*=\s*["'][A-Za-z0-9]` (min 20 chars) |

Exclude: `.env`, `.env.*`, `*.example`, test fixtures, documentation examples.

- **Pass:** No secrets found in tracked files
- **Warn:** Potential matches that need manual review
- **Fail:** Clear secret patterns in committed code
- Also verify: `.gitignore` includes `.env` and common secret files

### Check 4: Documentation Exists

<!-- README, 주요 문서 존재 여부 확인 -->

Check for project documentation:
- `README.md` (or `README`) at project root
- `docs/Architecture.md` (or `Architecture.md`)
- `PRD.md` (the original spec)
- `progress.md` (build history)

- **Pass:** README + at least one of Architecture/PRD exists
- **Warn:** README exists but other docs missing
- **Fail:** No README at all
- **N/A:** Project type doesn't need public docs (e.g., personal script, framework)

### Check 5: Deploy Target Configured

<!-- 배포 대상이 설정됐는지 확인 -->

Look for deployment configuration signals:
- `vercel.json`, `netlify.toml`, `fly.toml`, `Dockerfile`, `docker-compose.yml`
- `package.json` scripts containing `deploy`, `build`, `start`
- `.github/workflows/` with deploy-related CI
- `deploy-history.json` (from /deploy skill)
- `Makefile` or `justfile` with deploy target

- **Pass:** At least one deploy config found
- **Warn:** Build config exists but no deploy config
- **Fail:** No deployment configuration at all
- **N/A:** Project doesn't deploy (framework, library, personal script — inferred from PRD or user input)

## Step 2: Present Ship-Readiness Report

<!-- 반드시 한국어로 출력 -->

```
🚀 Pre-Ship Check — 출하 준비 보고서

프로젝트: [project name]
점검 일시: [YYYY-MM-DD]

━━ 점검 결과 ━━

  [✅/⚠️/❌] 기능 완료 상태: [N/M] 완료 [상세] [confidence tag]
  [✅/⚠️/❌] 미해결 경고: [상태 메시지] [confidence tag]
  [✅/⚠️/❌] Secrets 검사: [상태 메시지] [confidence tag]
  [✅/⚠️/❌/N/A] 문서 존재: [상태 메시지] [confidence tag]
  [✅/⚠️/❌/N/A] 배포 설정: [상태 메시지] [confidence tag]

  종합: [✅ Ship-ready / ⚠️ Ship with caution / ❌ Not ready]

━━ 필요 액션 ━━
[⚠️ 또는 ❌인 항목만]

  1. [구체적 수정 제안] [confidence tag]
  2. [구체적 수정 제안] [confidence tag]
  ...

[모든 체크 통과 시]
  ✅ 배포 준비 완료! `/deploy`로 진행할 수 있어요.

▶ 수정할 항목 번호를 알려주세요. (예: "1, 3" / "전부" / "이대로 배포")
```

**Wait for user response.**

## Step 3: Apply Selected Fixes

Only after user selects specific items:

**Incomplete features:**
- List remaining features, suggest running `/feature-plan` on the next one
- Cannot auto-complete features — user must build them

**Unresolved warnings:**
- Run failures.log through the lesson-capture flow (same as feature-done Step 2-A.4)
- Low-confidence instincts: suggest `/reflect` to review

**Secrets found:**
- Move secrets to `.env` file
- Add `.env` to `.gitignore` if missing
- Replace hardcoded values with env var references
- Commit the fix separately: `git commit -m "fix: move secrets to .env"`

**Missing documentation:**
- Generate a basic `README.md` from PRD.md + Architecture.md + feature_list.json
- Ask user to review before committing

**Missing deploy config:**
- Ask what the deploy target is
- Generate minimal config (Vercel/Netlify/Docker/none)
- Or mark as N/A if project doesn't deploy

### After applying:

```
✅ Pre-Ship Check 수정 완료
  - 수정 적용: [N]건
  - 건너뜀: [N]건
  - 상태: [재점검 결과 한 줄]
```

## Hard Rules

- **NEVER modify files without user confirmation.** Diagnostic first.
- **NEVER block on N/A checks.** Framework/script projects legitimately skip deploy/docs checks.
- **NEVER auto-run /deploy after passing.** Only suggest it.
- **ALWAYS present the report in Korean.**
- **ALWAYS gracefully skip missing files** — N/A, not error.
- **ALWAYS apply confidence tags** to findings per `~/.claude/rules/confidence-tags.md`.
- **Secrets findings are HIGH priority** — always list them even if other checks pass.
