---
name: monitor
description: "Lightweight post-deploy health check. Use when the user calls /monitor, says \"모니터\", \"상태 확인\", \"배포 확인\", \"살아있어?\", \"monitor\", \"health check 배포\", \"사이트 확인\", or after /deploy completes. Checks if deployment is reachable and suggests rollback if broken."
---

# monitor

<!-- 배포 후 경량 상태 확인. deploy가 "출하"면 이건 "출하 후 점검". -->
<!-- SHIP 페이즈의 마지막 스킬: pre-ship-check → deploy → monitor. -->

## Overview

Lightweight post-deployment reachability check. Reads deploy info from `.claude/deploy-history.json`, checks if the deployed URL responds, and suggests rollback if broken. This is diagnostic first, action (rollback) only with user confirmation.

**Trigger:** On-demand (`/monitor`) or suggested by `/deploy` after successful deployment.

## Preconditions

1. **Check deploy-history.json:** Read `.claude/deploy-history.json`.
   - **Exists with deploys:** Use the most recent deploy entry.
   - **Empty or missing:** Ask user for the URL to check:
     > "deploy-history.json이 없어요. 확인할 URL을 직접 입력해주세요."

2. **Extract check target from latest deploy:**
   - `url` — the deployed URL to check
   - `rollback.command` — rollback command if available
   - `platform` — for platform-specific health check hints

   If `url` is null in the deploy record:
   > "배포 URL이 기록에 없어요. 확인할 URL을 입력해주세요."

## Step 1: Reachability Check

### 1a. HTTP Check

Attempt to reach the deployed URL:

```bash
curl -s -o /dev/null -w "%{http_code}" --max-time 10 [url]
```

On Windows (PowerShell fallback):
```powershell
try { $r = Invoke-WebRequest -Uri [url] -TimeoutSec 10 -UseBasicParsing; $r.StatusCode } catch { "FAILED: $($_.Exception.Message)" }
```

### 1b. Interpret Response

| HTTP Status | Result | Action |
|---|---|---|
| 200-299 | ✅ Healthy | Report success |
| 301-399 | ⚠️ Redirect | Warn — may be OK, note final destination |
| 400-499 | ❌ Client error | Report failure, suggest investigation |
| 500-599 | ❌ Server error | Report failure, suggest rollback |
| Timeout | ❌ Unreachable | Report failure, suggest rollback |
| DNS failure | ❌ DNS error | Report failure, check domain config |

### 1c. Platform-Specific Checks (optional)

If `platform` is known from deploy-history, run additional checks:

| Platform | Extra check |
|---|---|
| Vercel | `vercel ls --prod` — check deployment status |
| Netlify | Check `_headers` or `_redirects` in response |
| Fly.io | `fly status` — check VM state |
| Docker | `docker ps` — check container running |
| Other | Skip — HTTP check is sufficient |

Platform CLI not installed → skip gracefully, rely on HTTP check alone.

## Step 2: Present Monitor Report

<!-- 반드시 한국어로 출력 -->

### On Success:

```
📡 Monitor — 배포 상태 확인

  URL: [deployed url]
  상태: ✅ 정상 (HTTP [status code])
  응답 시간: [response time]ms
  플랫폼: [platform or "알 수 없음"]
  마지막 배포: [timestamp from deploy-history]

  배포가 정상 작동 중이에요! [verified]
```

### On Failure:

```
📡 Monitor — 배포 상태 확인

  URL: [deployed url]
  상태: ❌ [failure type] (HTTP [status code or error])
  플랫폼: [platform]
  마지막 배포: [timestamp]

  ━━ 문제 진단 ━━

  [status-specific guidance]

  ━━ 권장 조치 ━━

  1. [specific action based on failure type] [confidence tag]
  [롤백 명령이 있을 때]
  2. 롤백: `[rollback command from deploy-history]`

▶ 롤백을 실행할까요? (다른 조치를 원하시면 말씀해주세요.)
```

**Wait for user response before any action.**

## Step 3: Handle Rollback (if requested)

Only when user explicitly requests rollback:

### 3a. Confirm Rollback

```
⚠️ 롤백 확인

  명령어: [rollback command]
  이전 배포로 되돌립니다.

▶ 진행할까요? (Y/N)
```

### 3b. Execute Rollback

Run the rollback command. Capture output.

**On success:**
```
✅ 롤백 완료
  [output summary]

💡 `/monitor`를 다시 실행해서 이전 버전이 정상인지 확인하세요.
```

**On failure:**
```
❌ 롤백 실패
  [error output]

수동으로 확인이 필요해요. 플랫폼 대시보드를 확인해주세요.
```

### 3c. Update deploy-history.json

Append a rollback record:

```json
{
  "timestamp": "2026-05-25T15:00:00Z",
  "platform": "vercel",
  "command": "vercel rollback",
  "commit": "abc1234",
  "branch": "main",
  "tag": "rollback-20260525-150000",
  "status": "success",
  "url": "https://my-app.vercel.app",
  "rollback": null,
  "is_rollback": true,
  "rolled_back_from": "deploy-20260525-143000"
}
```

## Hard Rules

- **NEVER execute rollback without explicit user confirmation.** Double-confirm required.
- **NEVER block on missing deploy-history.json.** Fall back to user-provided URL.
- **NEVER skip the HTTP check.** It's the core of this skill.
- **NEVER assume platform CLI is installed.** Always graceful-skip with HTTP fallback.
- **ALWAYS handle network errors gracefully** — timeout, DNS failure, connection refused.
- **ALWAYS present in Korean.**
- **ALWAYS apply confidence tags** to diagnoses per `~/.claude/rules/confidence-tags.md`.
- **ALWAYS suggest `/monitor` re-run after rollback** to verify recovery.
