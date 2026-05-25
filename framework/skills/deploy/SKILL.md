---
name: deploy
description: "Run deployment for the current project. Use when the user calls /deploy, says \"배포\", \"배포해줘\", \"deploy\", \"출시\", \"릴리스\", \"release\", \"publish\", or after /pre-ship-check passes. Runs the deploy command, tags git, stores rollback info in deploy-history.json."
---

# deploy

<!-- 실제 배포 실행 스킬. pre-ship-check가 "출하 가능 여부"면 이건 "실제 출하". -->
<!-- Action 스킬 — 진단이 아닌 실행. 되돌리기 어려우므로 반드시 유저 확인 필수. -->

## Overview

Execute the actual deployment for the current project. Tags the git commit, records deploy history with rollback info. This is an **action skill** (not diagnostic) — it modifies external state.

**Trigger:** On-demand (`/deploy`) or after `/pre-ship-check` passes.

## Preconditions

1. **`feature_list.json` must exist.** If not → "feature_list.json이 없어요. `/init-project`부터 시작할까요?"
2. **Suggest pre-ship-check:** If no recent pre-ship-check report exists, suggest:
   > "💡 `/pre-ship-check`를 먼저 실행하는 걸 권장해요. 건너뛸까요?"
   User can skip — deploy doesn't hard-require it.

## Step 1: Pre-flight (silent + confirm)

### 1a. Detect Deploy Platform

Look for deployment config in this order (first match wins):

| Signal | Platform | Deploy command |
|---|---|---|
| `vercel.json` or `.vercel/` | Vercel | `vercel --prod` |
| `netlify.toml` | Netlify | `netlify deploy --prod` |
| `fly.toml` | Fly.io | `fly deploy` |
| `Dockerfile` + `docker-compose.yml` | Docker | `docker compose up -d --build` |
| `package.json` with `"deploy"` script | npm script | `npm run deploy` |
| `Makefile` with `deploy` target | Make | `make deploy` |
| `pyproject.toml` with `[build-system]` | PyPI | `python -m build && twine upload dist/*` |
| None of the above | Unknown | Ask user |

### 1b. Verify Clean State

```
git status --porcelain
```

- **Clean:** Proceed
- **Dirty:** Warn and ask:
  > "⚠️ 커밋되지 않은 변경사항이 있어요. 커밋 후 배포할까요, 아니면 이대로 진행할까요?"

### 1c. Confirm with User

<!-- 배포는 되돌리기 어려운 작업. 절대 자동 실행 금지. -->

Present the deploy plan and **wait for explicit confirmation**:

```
🚀 배포 준비

  플랫폼: [detected platform]
  명령어: [deploy command]
  현재 커밋: [short hash] — [commit message]
  브랜치: [current branch]

▶ 이대로 배포할까요? (명령어 수정도 가능해요.)
```

If platform is "Unknown":
```
배포 설정을 자동으로 감지하지 못했어요.
▶ 배포 명령어를 직접 입력해주세요. (예: "vercel --prod", "npm run deploy")
```

**NEVER proceed without user confirmation.**

## Step 2: Execute Deploy

Run the confirmed deploy command. Capture output.

```
⏳ 배포 중... [deploy command]
```

### On Success:

```
✅ 배포 완료!
  [relevant output summary — URL if available]
```

Proceed to Step 3.

### On Failure:

```
❌ 배포 실패
  [error output]

▶ 수정 후 재시도할까요, 아니면 중단할까요?
```

Do NOT proceed to Step 3 on failure. Wait for user direction.

## Step 3: Git Tag + Record

### 3a. Tag the Commit

```bash
git tag -a deploy-YYYYMMDD-HHMMSS -m "Deploy to [platform]"
```

If tag already exists for this timestamp (rapid redeploy), append `-2`, `-3`, etc.

### 3b. Write deploy-history.json

Append a deploy record to `.claude/deploy-history.json`. Create the file if it doesn't exist.

**Schema:**

```json
{
  "deploys": [
    {
      "timestamp": "2026-05-25T14:30:00Z",
      "platform": "vercel",
      "command": "vercel --prod",
      "commit": "abc1234",
      "branch": "main",
      "tag": "deploy-20260525-143000",
      "status": "success",
      "url": "https://my-app.vercel.app",
      "rollback": {
        "command": "vercel rollback",
        "previous_deploy_id": "dpl_xxx"
      }
    }
  ]
}
```

**Fields:**
- `timestamp` — ISO 8601
- `platform` — detected or user-specified
- `command` — exact command executed
- `commit` — short hash of deployed commit
- `branch` — branch name
- `tag` — git tag created
- `status` — "success" or "failed"
- `url` — deploy URL if available from output (null otherwise)
- `rollback.command` — platform-specific rollback command (null if unknown)
- `rollback.previous_deploy_id` — previous deploy ID if available (null otherwise)

### 3c. Platform-Specific Rollback Registration

| Platform | Rollback command | How to get previous ID |
|---|---|---|
| Vercel | `vercel rollback` | Parse deploy output |
| Netlify | `netlify deploy --prod --alias previous` | Previous deploy in history |
| Fly.io | `fly releases rollback` | Auto |
| Docker | `docker compose down && docker compose up -d` | Use previous image tag |
| npm/PyPI | Cannot unpublish easily | Warn: "패키지 배포는 롤백이 어렵습니다" |
| Unknown | User-provided or null | Ask user |

## Step 4: Summary

```
📋 배포 기록 완료

  태그: [git tag]
  기록: .claude/deploy-history.json에 저장됨
  롤백: [rollback command or "롤백 명령어 없음"]

[롤백이 가능한 플랫폼일 때]
  💡 문제가 생기면 `/monitor`로 상태 확인 후 롤백할 수 있어요.
```

## Hard Rules

- **NEVER deploy without explicit user confirmation.** This is the most important rule.
- **NEVER run deploy in the background.** User must see output in real-time.
- **NEVER skip the git tag.** Every deploy gets a tag for traceability.
- **NEVER overwrite deploy-history.json.** Always append to the `deploys` array.
- **ALWAYS capture deploy output** for debugging if something goes wrong.
- **ALWAYS present in Korean.**
- **ALWAYS apply confidence tags** to platform detection and rollback info per `~/.claude/rules/confidence-tags.md`.
- **ALWAYS suggest /pre-ship-check** if no recent check exists (but don't block on it).
