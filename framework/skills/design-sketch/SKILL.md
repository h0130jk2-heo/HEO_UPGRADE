---
name: design-sketch
description: Use AFTER prd-creator (typically alongside/after architecture-sketch) and BEFORE init-project to decide the VISUAL direction of a project that has a user interface — mood, typography, color tokens, layout, and key components — so the build follows one committed design system instead of drifting to generic AI defaults. Triggers on "/design-sketch", "디자인", "디자인 방향", "비주얼", "화면 디자인", "UI 디자인", "룩앤필", "스타일 정해줘", "디자인 잡아줘", "어떻게 보일지", "look and feel", "design direction", "visual direction". Also invoke when architecture-sketch just finished on a project with a visible UI and the user says "다음"/"디자인은?". Skip for projects with no visible surface (pure CLI, library, API). Outputs DESIGN_PROPOSAL.md which init-project consumes to scaffold design tokens.
---

# design-sketch
<!-- architecture-sketch의 "디자인 버전". 기술 대신 비주얼 방향을 코딩 전에 확정한다. -->
<!-- 왜 필요한가: 방향 없이 코딩하면 AI는 평균값(Inter·보라파랑·3열카드)을 뱉는다. 앞단에서 방향을 못박아 일관성을 강제. -->

## Overview
Read the PRD, judge **what kind of thing** is being built (platform + purpose), and propose a
concrete **visual direction** the user can approve **before** init-project scaffolds anything.
This is the design sibling of `architecture-sketch`: that skill commits the tech, this one
commits the look-and-feel. The user should feel like they're approving a mood + a small set of
concrete choices, not picking from a design menu.

The reason this skill exists: without a committed direction, generation drifts to the
statistical average (see `~/.claude/rules/design.md` §0). Deciding direction up front is the
fix.

## ⚠️ Output Convention
`DESIGN_PROPOSAL.md` convention:
- English body. Korean comments only for non-obvious context (not heading translations).
- Save to project root (alongside PRD.md / ARCHITECTURE_PROPOSAL.md).

## Preconditions
1. **PRD.md must exist.** If not → "PRD가 먼저 필요해요. `/prd-creator`부터 시작할까요?"
2. **Does the project even have a visible UI?** Pure CLI / library / API → tell the user design
   direction isn't needed and stop. Don't force a design step on a non-visual project.
3. **If DESIGN_PROPOSAL.md already exists** → "이미 디자인 제안서가 있어요. 새로 만들까요, 기존 걸 수정할까요?"
Read silently: `PRD.md`, `ARCHITECTURE_PROPOSAL.md` and `BRAINSTORM.md` if present.

## Cost Estimate
<!-- PRD + design.md 코어 + 해당 프로파일/플랫폼 파일 로드 + 방향안 생성 → 중간 규모. -->
Before starting, show:
```
💰 예상 비용: 컨텍스트 중 (PRD + 디자인 규칙 + 해당 프로파일 읽기 + 방향안 생성). 진행할까요?
```
After completion, append to `.claude/cost-log.jsonl` per `~/.claude/rules/cost-awareness.md`.

## Step 1: Judge the two axes (silent)
From PRD (+ ARCHITECTURE_PROPOSAL if present), determine both axes. See the selection guide in
`~/.claude/rules/design.md` §2.
- **Platform axis** — web, mobile, or both. Mark primary vs. secondary.
- **Purpose axis** — landing / dashboard / document / app. A project may have a primary purpose
  and a secondary one (e.g. a marketing landing + an app behind login). Mark primary vs.
  secondary.
Do NOT show this analysis raw. Use it to load the right guidance and shape the recommendation.
Internally scan a **wider candidate set** (mood / type / layout combinations) before compressing
to the 2–3 you present — this maps to an agency's *client-presentation* stage (a curated few),
not a team brainstorm dump (Crazy 8s).

## Step 2: Load only the matching guidance
Read the universal core (`~/.claude/rules/design.md`) plus **only** the files for the axes you
detected:
- Platforms: `platforms/web.md` and/or `platforms/mobile.md`
- Profiles: `profiles/{landing|dashboard|document|app}.md` for the primary (and secondary).
Skip the rest — this keeps context lean (progressive disclosure).

## Step 3: Show 2–3 directions **as rendered pictures**, not prose
<!-- 핵심: 산문은 그림에 진다. 방향안을 실제 화면으로 보여줘야 비개발자가 고르고, 구현이 앵커를 얻는다. -->
Present **2–3 distinct visual directions**, each as an actual representative screen — not a
paragraph. Prose descriptions lose to pictures both for the person choosing and for the model
that later builds (see `~/.claude/rules/design.md` §1a). Each direction is a coherent stance
(mood + type + color + layout), never a slider.

### 3a. Ask the user how to generate the mockups
The mockups should be **rendered pictures, not prose** — produced by one of **three routes** the
user picks (below). The trap this skill guards against is *free-drawing the statistical average*,
not HTML itself: Route 3 lets Claude hand-code an HTML mockup **only under an anti-generic
guardrail**. Pick the representative
screen(s): **one for the primary purpose (required)**, plus **one for the secondary purpose if
there is one** (e.g. app + dashboard → an input/home screen *and* a monthly-dashboard screen — one
screen would miss the secondary purpose). Then let the user choose the route:

> "방향안을 실제 화면으로 만들 방법을 골라주세요:
> 1. **Stitch/Pencil로 직접 생성** — 연결돼 있으면 제가 바로 각 방향의 화면을 뽑아 `design-refs/`에 넣어요. (최고 충실도, 도구 연결 필요)
> 2. **프롬프트만 받기** — 각 방향의 프롬프트를 드릴게요. Stitch(무료)나 Pencil에 붙여넣어 뽑은 뒤 이미지를 `design-refs/`에 저장해주세요. (도구 품질을 쓰되 연결은 불필요)
> 3. **HTML 목업으로 바로 만들기** — 제가 각 방향을 눌러볼 수 있는 HTML 화면으로 직접 만들어 `design-refs/`에 넣어요. (외부 도구 없이 빠름, 비개발자에게 유리 — 단 '평균값 방지 가드레일'을 지켜 만듭니다)"

- **Route 1 — connected tool.** Pencil (`mcp__pencil__*`: `get_guidelines` → `batch_design` →
  `get_screenshot` / `export_html`) or Google Stitch (`stitch-mcp` proxy / SDK `STITCH_API_KEY`:
  `get_screen_image` / `get_screen_code`). Save each to `design-refs/<direction-slug>.png`. If the
  chosen tool isn't actually connected, say so and offer Route 2 — never silently fall back to
  hand-coding.
- **Route 2 — prompt.** Emit a ready-to-paste prompt **per direction × per chosen screen**. Each
  prompt must carry the universal fields (platform, purpose, layout, style, color palette,
  typography, key features) **plus the loaded platform/profile file's "Route 2 prompt must-include"
  items** — those purpose- and platform-specific essentials are what make the tools produce
  non-generic screens. Pause until the user saves the images into `design-refs/`, then continue.
- **Route 3 — HTML mockup (Claude가 직접).** 외부 도구 없이 바로 눌러볼 수 있는 목업을 만든다.
  비개발자·도구 미연결 상황에 적합하고, 결과물이 정적 이미지가 아니라 클릭 가능한 화면이라 이후 구현
  검증 앵커로도 유리하다. **단 'AI 평균값' 함정을 피하는 가드레일을 반드시 지킨다:**
  (a) `~/.claude/rules/design.md` §3 anti-generic 체크리스트를 먼저 적용해 **확정된 구체 방향**을
  코드로 옮긴다 — 백지에서 즉흥으로 그리지 않는다; (b) 기본값("Inter + 보라파랑 그라데이션 + 3열
  카드") 금지; (c) 2~3개 방향을 서로 **확연히 다르게**(type/color/layout stance); (d) 색 토큰은
  **라이트/다크 둘 다**; (e) 각 화면을 `design-refs/<direction-slug>.html`로 저장(구현 앵커로 영구
  보존). 이 가드레일을 지키면 "Claude가 그린 HTML = 평균값"이 아니라 "확정 방향의 실제 앵커"가 된다.
  가드레일을 지킬 수 없으면 Route 1/2로 안내한다.

Keep the directions genuinely different (type/color/layout stance) and off the averaged default
(design.md §3) — not "Inter + purple-blue gradient + three cards" without a real reason.

### 3b. Present them with a load-bearing recommendation
Show the generated screens (display the images, or open exported HTML) and make the
recommendation **do the work** — an opinionated default with a reason and an easy override, not
a neutral menu (design.md §0):

> "PRD를 봤어요. 이건 **[platform] × [purpose]** 성격이라 [핵심 우선순위 한 줄]이 중요해요.
> 세 방향을 실제 화면으로 만들어 봤어요 (Stitch/Pencil로 생성, `design-refs/`에 이미지로 있어요):
>
> **1. [방향명 — 예: "Calm Editorial"]** — [무드 한 줄]
> **2. [방향명]** — … / **3. [방향명]** — …
>
> → **저는 [N번]을 추천해요. 이유: [이 제품/사용자에 맞는 이유 한 줄].** 이대로 갈까요, 아니면
> 다른 번호로 할까요?"

The anti-generic effect comes from **committing to one direction up front** — among directions
that already passed the distinctiveness check — not from who picks it; a user who simply says
"그걸로 가자" to the recommendation still escapes the average. Let them approve, switch, or blend.

## Step 4: Confirm and lock concrete tokens
Once a direction is chosen, turn it into concrete, buildable values with the user's OK:
- **Type**: heading + body font choices, scale (e.g. 1.25 ratio), body size, line-height.
- **Color**: semantic tokens (surface/text/border/primary/accent + success/warning/error +
  **focus** ring), defined for **both light and dark** (adjusted, not inverted). Verify WCAG
  contrast — text 4.5:1, large text 3:1, non-text/UI components & focus ring 3:1 (SC 1.4.11).
- **Space & radius**: one spacing scale (4/8px), corner radius, elevation approach.
- **Primitives (optional)**: behind the semantic tokens, you may list the raw greyscale ramp
  (~4–8 hex steps) the neutrals derive from — promotes design.md §1.5's "8–12 step grey scale"
  from implicit to explicit. Skip if the semantic tokens already suffice.
- **Motion**: default duration/easing, and the promise to honor `prefers-reduced-motion`.
Surface accessibility non-negotiables now (contrast, keyboard, no color-only meaning) — these
are not up for taste debate.

## Step 5: Save DESIGN_PROPOSAL.md
```markdown
<!-- init-project가 이 문서를 소비해 디자인 토큰/기본 스타일을 스캐폴딩한다. -->

# Design Proposal — [Project Name]

## Product & Axes
- **Platform**: [web / mobile / both — primary vs secondary]
- **Purpose**: [landing / dashboard / document / app — primary vs secondary]
- **What matters most here**: [one line from the profile(s)]

## Chosen Direction
**[Direction name]** — [one-line mood/stance] [confidence tag]

## Visual References
<!-- 구현 시점의 Claude가 앵커로 삼는 실제 화면. 산문보다 이 경로가 방향을 살린다. -->
<!-- 이 파일들은 프로젝트에 영구 보존된다 (DESIGN_PROPOSAL.md는 소비 후 삭제되지만 refs는 남는다). -->
- Primary-purpose screen: `design-refs/[direction-slug].png` (+ `.html` if exported)
- Secondary-purpose screen (if the purpose axis had a secondary): `design-refs/[slug]-[purpose].png`

## Design Tokens
### Typography
- Heading: [font] · Body: [font] · Scale: [ratio] · Body: [px] · Line-height: [n]
### Color (semantic — light / dark)
| Token | Light | Dark |
|---|---|---|
| surface.base | ... | ... |
| text.primary | ... | ~#FAFAFA |
| primary | ... | ... |
| accent | ... | ... |
| focus (ring, ≥3:1) | ... | ... |
| success / warning / error | ... | ... |
### Space & Radius & Motion
- Spacing scale: [4/8px steps] · Radius: [n] · Motion: [duration/easing] · reduced-motion: honored

## Key Components & Layout
- [e.g. top KPI row + card grid for dashboard / hero + single CTA for landing]
- The five states designed: loading / empty / partial / error / success (partial optional if not applicable)

## Platform Notes
- [thumb-zone / responsive / hover-fallback notes as applicable]

## Accessibility Commitments
- WCAG AA contrast (text 4.5:1 · large text 3:1 · non-text/UI & focus ring 3:1) · visible focus
  indicator · full keyboard reach · no color-only meaning · reduced-motion

## Rejected Directions
- **[name]** — why not chosen [confidence tag]
```
Keep the chosen direction's mockup(s) in `design-refs/` (do NOT delete them — they are the
visual anchor the build compares against). Then:
> "DESIGN_PROPOSAL.md에 저장하고, 고른 방향의 화면을 `design-refs/`에 남겼어요. `/init-project`를
> 부르면 이 토큰을 Style Dictionary 포맷 또는 shadcn theme.css 등으로 매핑하고, 기존 컴포넌트
> 라이브러리가 있다면 재사용을 우선하며, 이후 각 기능은 이 화면을 기준으로 검증돼요."

## Quality Check Before Saving
- [ ] Both axes stated with primary/secondary
- [ ] 2–3 directions were offered **as rendered mockups** (not prose), and the user chose
- [ ] The recommendation was load-bearing (opinionated default + reason + easy override)
- [ ] Chosen direction is NOT the generic default (checked against design.md §3)
- [ ] A screen per purpose (primary required; secondary if any) saved in `design-refs/` and path-referenced in DESIGN_PROPOSAL.md
- [ ] Route 2 prompts (if used) included the platform/profile "must-include" items
- [ ] Color tokens defined for both light and dark; contrast noted
- [ ] The five states named (partial optional if not applicable)
- [ ] Accessibility commitments listed (non-negotiable)
- [ ] At least 1 rejected direction recorded
- [ ] Confidence tags on the direction rationale per `~/.claude/rules/confidence-tags.md`

## Hard Rules
- **NEVER scaffold files.** This skill proposes; init-project creates. Only DESIGN_PROPOSAL.md
  is written.
- **ALWAYS show directions as pictures, not prose** (design.md §1a). **Let the user pick one of
  three routes:** (1) generate directly via a connected design model (Pencil `mcp__pencil__*` or
  Google Stitch `stitch-mcp`/SDK), (2) receive a ready-to-paste prompt per direction to run in
  Stitch/Pencil themselves, or (3) Claude hand-codes an HTML mockup **under the anti-generic
  guardrail** (commit a specific non-generic direction from design.md §3 first, apply the
  anti-generic checklist, 2–3 genuinely distinct directions, light/dark tokens, save to
  `design-refs/<slug>.html`). The former blanket ban on hand-coding is **replaced by Route 3's
  guardrail**: the real risk is *free-drawing the average*, not HTML per se — a committed,
  checklist-passed direction in HTML is a valid anchor and is often better for non-developers (they
  can click it). Never block on a tool that isn't connected — offer Route 2 or 3 instead.
- **Make the recommendation load-bearing.** Opinionated default + reason + easy override, never a
  neutral "pick one of three." A user who only ever approves the recommendation must still get a
  non-generic result — that is the test. Mood/brand remain the human's call, but commitment to
  *a* direction — **among directions that have already passed the anti-generic distinctiveness
  check** — is what defeats the average, not who picks it (design.md §0).
- **KEEP the chosen mockup(s) in `design-refs/`.** They are the visual anchor for implementation
  and must survive into the project (unlike DESIGN_PROPOSAL.md, which is consumed and deleted).
- **ALWAYS load only the matching profile/platform files** — not all of them.
- **NEVER offer the averaged default** ("Inter + purple-blue gradient + three cards") as a
  direction unless there's a concrete reason for this product.
- **ALWAYS treat accessibility as non-negotiable**, not a direction option (contrast, keyboard,
  no color-only meaning, reduced-motion).
- **NEVER auto-invoke init-project.** Tell the user to run it.
- **SKIP for non-visual projects** (CLI, library, API) — don't manufacture a design step.
