---
name: brainstorm
description: Use BEFORE prd-creator when the user's idea is still fuzzy or vague. Triggers on phrases like "/brainstorm", "뭐 만들지 모르겠어", "아이디어가 있는데 막연해", "정리가 안 됨", "발산", "고민 중인데", "어떨까", "막연한 생각", "something to build but not sure", "kind of want to make", "ideas for". ALSO invoke this when the user's opening message lacks (a) a concrete product noun, (b) a specific target user, or (c) is shorter than ~30 characters and contains hedge words ("뭔가", "막연", "잘 모르겠", "idea"). Outputs BRAINSTORM.md which prd-creator will consume on its next run.
---

# brainstorm

<!-- 아이디어가 막연할 때 prd-creator 들어가기 전에 발산→수렴 1:1 대화로 방향을 잡는 스킬. -->
<!-- 비개발자가 PRD를 즉시 쓸 수 없는 상황(아이디어가 정리 안 됨)에서 한 단계 앞에서 받아주는 역할. -->

## Overview

Run a focused **divergent → convergent** conversation that turns a fuzzy idea into a concrete direction before PRD writing. One question at a time. Korean conversation, English artifact.

The goal is to make the user feel like they're talking to a thoughtful product collaborator — not filling out a survey.

## ⚠️ Output Convention

`BRAINSTORM.md` convention:
- English body. Korean comments only when they add non-obvious context (not heading translations).
- Save to project root (alongside where PRD.md will go)

## Conversation Rules

- **Ask one question at a time.** Never stack multiple questions.
- **Korean conversation, English save.** Mirror prd-creator's convention.
- **3 divergent questions baseline.** Extend to 5 only if the user remains vague after 3.
- **Then converge.** Summarize what you heard, propose 2–3 derived directions, ask the user to pick one (or propose their own).
- **Trigger save** when the user picks a direction OR explicitly says "확정", "저장", "이걸로", "done", "save", "결정".

## Opening Line

Start with a single, low-pressure open question that acknowledges fuzziness:

> "아이디어가 아직 막연해도 괜찮아요. 어떤 문제 때문에 뭔가 만들고 싶어졌어요?"

Don't introduce yourself. Don't explain the process. Just ask.

## Phase 1: Divergent (3 questions baseline, up to 5)

Pick 3 of the following questions, choosing based on what's most unclear from the user's opening. Save the rest for if convergence fails.

1. **Problem origin**: "본인이 겪은 문제예요, 아니면 다른 사람을 보고 만들고 싶어졌어요?"
2. **User**: "누가 이걸 쓰게 될 거 같아요? 본인? 가족? 회사? 잘 모르는 사람들?"
3. **Reference**: "비슷한 거 본 적 있어요? 있다면 그것의 어떤 점이 답답해서 이걸 만들고 싶어요?"
4. **Trigger event**: "왜 지금 만들고 싶어졌어요? 최근에 뭔가 있었나요?"
5. **Simplest version**: "가장 단순한 버전이 동작한다면 어떤 모습일까요? 한 문장으로요."

After each answer, briefly reflect what you heard (1 line) before moving to the next question. Example: *"음, 그러니까 외부에 의존하지 말고 본인이 직접 처리하고 싶다는 거네요. 그럼 —"*

## Phase 2: Convergent (2–3 directions)

After 3 (or up to 5) divergent answers, summarize and propose:

> "지금까지 들은 걸 정리하면 [한 문장 요약]이에요. 여기서 가능한 방향이 2-3개 보여요:
>
> 1. **[방향 1 한 줄 이름]** — [한 줄 설명]
> 2. **[방향 2 한 줄 이름]** — [한 줄 설명]
> 3. **[방향 3 한 줄 이름]** — [한 줄 설명] (선택)
>
> 어느 방향이 가장 와닿아요? 아니면 더 좋은 다른 방향이 있나요?"

Wait for the user's choice (or alternative). Never pick for them.

## Saving BRAINSTORM.md

When the user confirms a direction, write to `BRAINSTORM.md` in the project root:

```markdown
<!-- prd-creator가 이 문서를 읽고 PRD.md를 작성한다. -->

# Brainstorm — [Project working title]

## Chosen Direction
[One concrete sentence describing the picked direction]

## Why This Direction
[2–3 sentences synthesizing the user's reasoning from divergent answers]

## Problem
[The problem the user wants to solve, concrete]

## Target User
[Who will use it — named, not "users" or "people"]

## Minimum Viable Shape
[One paragraph describing the simplest working version]

## Alternatives Considered
- **[Alternative 1 name]** — [brief description, why rejected]
- **[Alternative 2 name]** — [brief description, why rejected]

## Open Questions for PRD
- [Question 1 left for PRD]
- [Question 2 left for PRD]
```

Then confirm:

> "BRAINSTORM.md에 저장했어요. 이제 `/prd-creator`를 부르면 이걸 읽고 PRD 작업으로 넘어갈게요."

## Quality Check Before Saving

All four checks must pass:

- [ ] **Chosen Direction** is one concrete sentence — not still vague, not a category ("앱", "도구"), but a specific shape
- [ ] **Target User** is named — actual role/group, not "users" or "people"
- [ ] **Minimum Viable Shape** is describable in one short paragraph with concrete actions
- [ ] At least one **Alternative** is recorded with a rejection reason

If any check fails, ask one more targeted question before saving (don't save with placeholder content).

## Hard Rules

- **Never pick a direction for the user.** Even if one option seems obvious, present the choice.
- **Never auto-invoke prd-creator after saving.** Tell the user to do it; respect their pacing.
- **Never save with TBD/vague placeholders.** Ask one more question instead.
- **Never expand divergent past 5 questions.** If the user is still vague after 5, write what you have with explicit "Open Questions" and let prd-creator handle the rest.
