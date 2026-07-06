<!-- verify-stack Layer 1의 전체(strict) 보안 체크리스트. 앱 레벨 중심, 클라우드 인프라 규칙 제외. -->
# Security Checklist (App-Level)

Loaded on `--strict` or when the PRD is production-grade. Each item is compliant / non-compliant / N/A.
Non-compliant items on a Must-have surface are HARD BLOCK (same as Layer 1 core patterns).

## Core (always, mirrors the 6 static patterns)
1. **Secrets** — no API keys/tokens/passwords in source; use env/secret store.
2. **Injection** — parameterized queries; no string-built SQL/NoSQL/OS commands.
3. **XSS** — user input escaped before HTML output; no unsafe innerHTML.
4. **Command injection** — no user input passed to shells/eval.
5. **Hardcoded credentials** — no connection strings with embedded creds.
6. **Path traversal** — user-supplied paths sanitized/allowlisted.

## Extended (strict)
7. **Encryption** — sensitive data encrypted at rest and in transit (TLS). Applies to whatever store the app uses (DB/file/cache) — provider-neutral.
8. **Input validation** — every external input: type check, length/size bounds, format allowlist.
9. **Authentication** — passwords hashed with an adaptive algorithm; no weak hashing; brute-force protection on login.
10. **Session management** — server-side expiry; invalidation on logout; secure/httpOnly/sameSite cookies.
11. **Access control (authZ)** — deny-by-default; object-level ownership checks (prevent IDOR); server-side role checks for privileged actions.
12. **Error handling** — fail closed; generic user-facing errors (no stack traces/internal paths); resources released on error paths.
13. **Dependency / supply chain** — lock file committed; no unused deps; no `latest` tags in production build configs; trusted registries only.
14. **Sensitive-data logging** — no secrets/PII in logs.
15. **Deny-by-default network posture** *(only if the app defines its own firewall/CORS rules)* — restrict CORS origins (never `*` on authenticated endpoints); open only required ports. Provider-neutral principle; skip infra specifics.

## Excluded (cloud-infrastructure / deployment-coupled — out of scope for HEO)
Provider-level infrastructure hardening and deployment-layer security posture are out of scope for
this app-level checklist — that responsibility belongs to HEO's own deploy/monitor skills, not
verify-stack.
