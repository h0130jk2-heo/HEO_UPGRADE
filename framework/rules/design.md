# Design — Cross-Cutting Convention (Frontend Judgment, 2026)
<!-- 프레임워크가 만드는 "보이는 산출물"의 디자인 판단 기준. 항상 로드되는 규칙. -->
<!-- 이 파일은 "무엇이 좋은 디자인인가"의 감각(공통 코어)만 담는다. -->
<!-- 목적별/플랫폼별 상세 가이드는 design-sketch 스킬이 온디맨드로 로드한다. -->

This file is the always-loaded **design judgment baseline** for any visible artifact HEO
produces (web pages, apps, dashboards, reports). It carries the **universal core** — the sense
of what "good" means in 2026 — plus a **selection guide** that maps a project to the right
platform and purpose guidance. Deep per-type guidance lives in the `design-sketch` skill's
`platforms/` and `profiles/` files, loaded only when relevant.

Use this whenever you generate or review UI, choose colors/typography, or lay out a page —
even if the user never invokes `/design-sketch`. Judgment applies without a skill; the skill
just commits it to an artifact up front.

---

## 0. Meta-principle — you are the lead, AI is the intern
<!-- 2026 디자인 담론에서 가장 반복적으로 등장하는 원칙. -->

AI generates the **statistical average of everything it has seen**. Ask for "a clean modern
site" and you get the mean: Inter font, purple-to-blue gradients, three equal feature cards,
glassmorphism, rounded corners, entrance animations. It looks polished and is instantly
forgettable — because polish is not taste, and the average has no point of view.

- **Never stop at "it looks good."** A generated interface can look finished while missing
  brand personality, emotional nuance, and strategic clarity. Looking done ≠ being right.
- **Split the work 75/25.** Let AI carry the ~75% that is genuinely conventional (scaffolding,
  standard patterns, layout logic). Spend the saved effort on the ~25% that is the product's
  own point of view — a real visual direction, one custom interaction, copy with a voice.
- **Premium = coherence, not complexity.** What reads as "premium" is not more effects — it is
  consistent letter-spacing and line-height, hierarchy from deliberate scale contrast, a
  repeating spacing rhythm, and motion timing that feels purposeful. Every element serves this
  product's specific goal.
- **The fix for generic is direction, given up front.** Generic output is what you get when the
  input is vague. Strong design direction — real components, concrete tokens, a chosen visual
  stance — decided *before* generation is the whole reason `design-sketch` exists.

Treat AI output the way you would a junior designer's: critique it, curate it, argue with it —
then approve.

**The effect comes from commitment, not connoisseurship.** What defeats the average is that
*some* specific direction was chosen before building — not that an expert chose it. A
non-designer who simply approves a recommendation still escapes the mean, as long as a concrete
direction is locked up front. So the recommendation must be **load-bearing**: an opinionated
default with a reason and an easy override ("I recommend A because X — go with it?"), never a
neutral "pick one of three." The test of this whole approach is whether a user who *only ever
accepts the recommendation* still gets a non-generic result.

---

## 1. Universal core — applies to every platform and purpose
<!-- 산출물 종류와 무관하게 항상 적용되는 2026 공통 원칙. -->

1. **Cognitive clarity over sensory richness.** The 2026 shift is away from visual theatrics
   toward calm, understandable interfaces. Minimize decision points per screen; use whitespace
   and hierarchy to cut cognitive load. Ask "does this reduce effort?" not "is this exciting?"
2. **Motion is structure, not decoration.** Animation exists to explain what just happened,
   what is happening, and what comes next — state, feedback, continuity. Purposeful timing,
   never ornamental. Always honor `prefers-reduced-motion`.
3. **Be transparent and reversible** (especially for AI features). Show *why* a result appeared
   and how confident it is; provide override/opt-out and undo. Trust drives adoption.
4. **Accessibility is infrastructure, not a retrofit.** Design it from the wireframe: WCAG
   contrast (4.5:1 body text), full keyboard reach, readable type. **Never encode meaning by
   color alone** — pair with text, icon, or pattern.
5. **Build on a token system.** Reference semantic tokens (`color.surface.primary`,
   `space.4`), not raw hex/px. Define light and dark by adjusting each token, not by inverting.
   In dark mode, never use pure white (#FFFFFF) for body — use ~#FAFAFA over an 8–12 step grey
   scale.
6. **Always design the four states.** loading / empty / error / success. An interface that only
   shows the happy path is unfinished.

### Universal baseline numbers
<!-- 어느 산출물에서나 무난한 출발점. 프로파일이 이를 조정할 수 있다. -->
- **Type**: body ≥16px; line-height ~1.5; line length 45–75 characters; 3–4 hierarchy levels.
- **Color**: escape the generic default palette; neutral base + 1 accent; verify contrast.
- **Spacing**: one scale (e.g. 4/8px steps); repeat it for visual rhythm.

---

## 1a. From judgment to pixels — the direction must survive to the build
<!-- 판단 층에서 평균값을 막아도, 실행 층에서 재발하면 소용없다. 이 섹션이 그 갭을 메운다. -->

Tokens and prose are necessary but not sufficient. Two failure modes recur when a direction is
only written down:

- **Prose loses to pictures.** A paragraph describing a direction is far weaker than an actual
  representative screen — both for the human choosing it and for the model building from it.
  Non-designers especially pick a direction far more reliably from three *images* than three
  descriptions. So a direction should be shown as a concrete visual (a rendered mockup screen),
  not only named. That visual can come from a **design/image model** (Stitch, Pencil) **or**,
  when no such tool is connected, from Claude hand-coding an HTML mockup — but only under an
  **anti-generic guardrail**: commit a specific §3-checked direction first, ban the defaults,
  keep 2–3 genuinely distinct stances, and define light/dark tokens (this is `design-sketch`
  Route 3). What must never happen is *free-drawing the average* — an ungoverned mockup
  improvised from a blank page is only the model's own mean again. The former blanket ban on
  hand-coding is thus replaced by the guardrail: the real risk is the average, not HTML per se.
  Tokens give **consistency**; a visual reference gives **conviction and
  direction**. Without the picture, output tends to reach ~60% and stall into "consistency
  without conviction."
- **You are a blind designer.** A model cannot see what it renders, so at implementation time it
  will improvise layout, hierarchy, and motion — re-introducing the very average the judgment
  layer prevented. The fix is a loop: **render → screenshot → compare against the chosen visual
  reference and tokens → regenerate on drift.** A direction only survives to the product if the
  built result is checked back against the reference, not assumed.

Concretely: `design-sketch` presents directions as rendered mockups and records the chosen
reference image path in `DESIGN_PROPOSAL.md`; `feature-done` runs the screenshot-compare loop on
UI features. The reference image is the anchor that carries the direction from decision to code.

## 2. Selection guide — two orthogonal axes
<!-- 프로젝트를 읽고 두 축을 각각 판별한다. 하나에 하나만 고르는 게 아니라, 해당되는 것 모두 + 주/보조. -->

A visible artifact is shaped by **two independent axes**. A project can span several values on
each — pick every value that applies and mark **primary vs. secondary**.

**Axis A — Platform** (where it runs; controls layout, input, conventions):

| Platform | Core concerns | Full guide |
|---|---|---|
| **web** | responsive breakpoints, hover states, wide canvas, mouse+keyboard, higher density OK | `design-sketch/platforms/web.md` |
| **mobile** | touch targets ≥44pt/48dp, thumb zone (bottom third), no hover, safe-area, iOS-HIG vs Material-3 native conventions | `design-sketch/platforms/mobile.md` |

**Axis B — Purpose** (what it is for; controls what matters vs. what to resist):

| Purpose | Optimizes for | Actively resist | Full guide |
|---|---|---|---|
| **landing** | first impression, headline, single CTA, trust signals, persuasion | dense info, nav menus, multiple CTAs | `design-sketch/profiles/landing.md` |
| **dashboard** | data clarity, KPI hierarchy, chart-to-question fit, scannability | decoration, storytelling motion, over-interactivity | `design-sketch/profiles/dashboard.md` |
| **document** | readability, typographic hierarchy, reading rhythm, print/PDF fidelity | interaction, motion, hero visuals | `design-sketch/profiles/document.md` |
| **app** | task efficiency, component consistency, the four states, undo | marketing flair | `design-sketch/profiles/app.md` |

**How to compose:** the same virtue can flip between purposes — high information density is a
strength in a dashboard and a liability on a landing page. When axes combine, apply the
platform constraints to the purpose's priorities (e.g. *mobile × dashboard* = KPI hierarchy,
but re-flowed for the thumb zone with fewer visible elements).

`design-sketch` reads the PRD, judges both axes, loads only the matching files, and writes the
combination into `DESIGN_PROPOSAL.md`.

---

## 3. Anti-generic checklist — the "tells" of averaged AI design
<!-- 결과물이 "AI 평균값"으로 미끄러졌는지 자가 점검. 하나라도 무의식적으로 나왔다면 방향을 다시 세운다. -->

Flag output that drifted to the mean and give it a real point of view instead:

- [ ] Default font (Inter/Roboto) chosen by inertia, not intent
- [ ] Purple→blue gradient with no reason tied to the brand
- [ ] Three equal feature cards as the default section shape
- [ ] Glassmorphism / entrance animations added for their own sake
- [ ] Generic SaaS blue that makes the product indistinguishable from every competitor
- [ ] Layout that could belong to any product — no decision reflects *this* one

---

## 4. Universal anti-patterns — reject in any artifact
<!-- 모든 산출물 공통 금지. 프로파일별 do/don't는 각 profiles 파일에. -->

- ❌ Shipping AI-generated layout without a human usability pass — coherent-looking ≠ usable
- ❌ Spectacle over clarity — bold interaction that blocks the task
- ❌ Accessibility bolted on after launch instead of designed in
- ❌ Adopting a trend wholesale without checking it against the actual users
- ❌ Meaning carried by color alone
- ❌ Only the happy path designed (missing empty/error/loading)

---

## Sources (2026)
<!-- 업데이트 시 재조사 기준점. -->
Figma State of the Designer 2026 · Envato UX/UI trends 2026 · Designlab / UI Things (AI as
intern) · Shuffle & DEV (AI sameness / premium feel) · Ripplix (motion) · UXPin & Muzli
(tokens / dark mode) · parallelHQ (AI trust) · LogRocket (reversible UX). Per-type sources are
cited inside each `platforms/` and `profiles/` file.
