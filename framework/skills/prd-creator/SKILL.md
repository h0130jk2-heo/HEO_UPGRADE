---
name: prd-creator
description: Use when the user wants to define what to build before coding, write a PRD, clarify product requirements, answer "what should we build?", plan a feature or product, fill out a product requirements document, or says things like "PRD 작성", "기획서 작성", "뭘 만들지 정하자", "요구사항 정리", "제품 정의", "기능 기획", "코딩 시작 전에 정리", or any variation of wanting to define scope before implementation.
---

# PRD Creator

## Overview

Guide the user through a 1:1 conversation to produce a complete `PRD.md`. One question at a time. Natural flow. No forms, no pressure.
d
The goal is to make the user feel like they're talking to a thoughtful product manager — not filling out a template.

## Conversation Rules

- **Ask one question at a time.** Never stack multiple questions.
- **Keep it conversational.** Rephrase to match the user's vocabulary and context.
- **Summarize periodically.** After every 2–3 questions, say: *"지금까지 정리한 내용이에요 —"* and recap what you've captured so far. Ask if anything needs adjusting.
- **Respond in Korean.** Match the user's language. Ask follow-up questions in Korean.
- **Save in English.** PRD.md body is English. Korean comments only when they add context not obvious from the English (e.g., explaining a domain-specific choice). Do NOT add comments that merely translate headings.
- **Trigger save** when the user says "확정", "저장", "완료", "done", "save", or equivalent.

## PRD Sections (Required Coverage)

Work through these naturally — not as a checklist the user sees. You decide the order based on conversation flow. Before saving, verify all 6 are covered.

1. **One-line product definition** — Who is it for, what does it do?
2. **Problem being solved** — What pain, gap, or need does this address?
3. **Primary user & usage frequency** — Who uses it, how often?
4. **Core features** — Categorized as Must / Should / Won't (MoSCoW)
5. **Done criteria** — Concrete, observable behaviors that signal "this works"
6. **Constraints** — Technology limits, team size, timeline, known blockers

## Conversation Flow

```
Ask about the product → ask about the problem → ask about the user → 
  summarize so far → ask about features → ask about done criteria → 
    ask about constraints → final summary → wait for "확정"
```

If the user jumps ahead or volunteers extra info, absorb it and skip ahead accordingly. Don't re-ask what you already know.

## Step 0: Check for BRAINSTORM.md

Before asking anything, check whether `BRAINSTORM.md` exists in the project root.

**If `BRAINSTORM.md` exists:**
1. Read it.
2. Open by summarizing the chosen direction in Korean and asking confirmation:
   > "BRAINSTORM.md에서 정리된 방향이 있네요 — *[Chosen Direction을 한국어로]*. 이 방향으로 PRD 작성할게요. 추가하거나 바꾸고 싶은 부분 있어요?"
3. Treat the BRAINSTORM.md content as already-covered material for these PRD sections:
   - One-line product definition (from Chosen Direction)
   - Problem being solved (from Problem)
   - Primary user (from Target User)
4. Skip directly to the NOT-yet-covered PRD sections (typically Features in MoSCoW, Done criteria, Constraints), plus any "Open Questions for PRD" listed in BRAINSTORM.md.

**If `BRAINSTORM.md` does NOT exist:**
Proceed with the Opening Line below. BUT after the user's first response, if their reply is vague (lacks a concrete product noun, lacks a named user, or is shorter than ~30 characters with hedge words like "뭔가/막연/잘 모르겠/idea"), pause and suggest brainstorm:
> "아이디어가 아직 좀 정리가 안 된 거 같아요. `/brainstorm`을 먼저 돌려서 방향 잡고 오는 게 어떨까요? 아니면 이대로 PRD 작업 계속할까요?"

Respect the user's choice. If they say continue, continue.

## Opening Line

(Only used when `BRAINSTORM.md` does not exist.)

Start with a single open question:

> "어떤 걸 만들려고 하세요? 한 줄로 설명해 주세요."

Don't introduce yourself, don't explain the process. Just ask.

## Saving the PRD

When the user confirms:

1. Read `references/prd-template.md` to get the template structure
2. Fill in all 6 sections using the conversation content
3. Write to `PRD.md` in the current working directory
4. Say: *"PRD.md에 저장했어요. 다음은 `/architecture-sketch`로 기술 스택과 프로젝트 구조를 잡아볼게요."*

**Write in English.** Body text in English. Korean HTML comments only when they add non-obvious context (e.g., why a constraint exists, domain background). Do NOT add comments that merely translate headings.

## Quality Check Before Saving

All 6 sections must have substantive content (not just "TBD" or vague placeholders). If any are thin, ask one more targeted question before saving.

For quantitative verification, check:
- [ ] All 6 required sections present
- [ ] Features categorized into Must / Should / Won't
- [ ] Done criteria are observable behaviors (not feelings or vague goals)
- [ ] Constraints section is specific (not "we'll figure it out")
