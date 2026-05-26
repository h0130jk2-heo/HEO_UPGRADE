---
name: turbo-build
description: "Automated multi-feature build pipeline. Runs each feature in a fresh claude -p session to prevent context pollution. Independent features execute in parallel."
triggers:
  - "/turbo-build"
  - "터보"
  - "자동 빌드"
  - "한번에 다 만들자"
  - "연속 빌드"
  - "파이프라인 빌드"
  - "turbo"
  - "auto build"
  - "batch build"
  - "기능 개발 시작"
  - "빌드 시작"
---

# Turbo Build — 자동화 빌드 파이프라인

## 개요

`feature_list.json`의 미완성 기능들을 **기능별 독립 세션**으로 자동 빌드.
각 기능이 깨끗한 컨텍스트에서 실행되어 컨텍스트 오염 없음.
독립 기능은 병렬 실행으로 속도 극대화.

## 언제 쓰나

`/init-project` 완료 후 기능 구현을 시작할 때. 일반적 흐름:

```
/prd-creator          ← 기획
/architecture-sketch  ← 설계
/init-project         ← 프로젝트 세팅
/turbo-build          ← 여기서 기능 전부 자동 빌드
```

## Skill Invocation (실행 흐름)

유저가 `/turbo-build` 또는 트리거 문구를 입력하면:

**Step 1: 상태 확인 (silent)**
- 현재 작업 디렉토리에서 `feature_list.json` 읽기
- `passes: false`인 기능 추출
- 의존성 분석하여 Wave 분류

**Step 2: 유저에게 확인**
```
남은 기능: N개 (Wave 3개로 분류됨)
- Wave 1 (병렬 가능): F001, F002, F003
- Wave 2 (Wave 1 완료 후): F004, F005
- Wave 3 (Wave 2 완료 후): F006

어떻게 빌드할까요?
1. 전부 자동 (권장)
2. N개만
3. 프롬프트 미리보기 (dry-run)
```

**Step 3: 옵션 확인**
- 모델: sonnet (기본, 빠름) / opus (품질 우선)
- 병렬: 1 (순차, 안전) / 2-3 (빠름, git conflict 가능)

**Step 4: 파이프라인 실행**
```powershell
& "$env:USERPROFILE/.claude/tools/turbo-pipeline.ps1" `
    -Project "<current-directory>" `
    -Model <선택한모델> `
    -Parallel <선택한수>
```

**Step 5: 결과 리포트**
- passed / failed / skipped 수
- 소요 시간
- decisions.log에서 WARNING 항목 표시 (유저 사후 검토)
- 실패한 기능이 있으면: "F005 실패. 대화형으로 직접 해결할까요?" 제안

## 세션 밖에서 직접 실행 (자러 가면서 걸어두기)

PowerShell 터미널에서:
```powershell
& "$env:USERPROFILE/.claude/tools/turbo-pipeline.ps1" `
    -Project "E:\my-project" `
    -Model sonnet `
    -Parallel 2
```

## 동작 원리

```
feature_list.json 읽기
       |
 의존성 그래프 → Wave 분류
       |
 Wave별 순차 실행 (wave 내부는 병렬 가능):
   |
   +-- 기능마다 fresh claude -p 호출
   |     - 프롬프트 = CLAUDE.md + Architecture.md + 기능 스펙 + Decision Policy
   |     - 이전 기능 구현 디테일 없음 (컨텍스트 오염 방지)
   |     - AI가 구현 + QA + commit까지 자율 수행
   |
   +-- 완료 확인: feature_list.json passes:true?
   |     - Yes → 다음 기능
   |     - No → 로그 기록, 의존 기능도 skip
   |
 Wave 끝 → Architecture.md 새로 읽기 (변경됐을 수 있음)
       |
 최종 리포트 출력
```

## 의사결정 정책

빌드 중 AI가 혼자 결정해야 하는 상황 처리:

| 결정 유형 | 처리 |
|---|---|
| `feature_list.json`의 `decisions` 필드 | 그대로 따름 (재량 없음) |
| 구현 중 소소한 선택 | 자율 판단 + `.claude/decisions.log`에 기록 |
| 큰 결정 (DB, API, 아키텍처) | 보수적 선택 + `WARNING` 마킹 |

유저는 빌드 완료 후 `decisions.log`의 WARNING 항목만 검토하면 됨.

사전에 결정 가능한 것은 `feature_list.json`에 미리 넣기:
```json
{
  "id": "F003",
  "decisions": { "auth": "JWT", "db": "SQLite" }
}
```

## 전제 조건

- `/init-project` 완료 (feature_list.json + CLAUDE.md + Architecture.md 존재)
- Claude Code CLI 인증 완료

## 주의사항

- `--dangerously-skip-permissions` 사용 — 신뢰할 수 있는 프로젝트에서만
- 병렬 실행 시 git conflict 가능 → Parallel 1이 가장 안전
- 기본 타임아웃 10분/기능 — 복잡한 기능은 초과할 수 있음
