# Purpose: Landing / Marketing
<!-- 방문자를 설득해 하나의 행동(가입·문의·구매)으로 이끄는 페이지. -->
<!-- design-sketch가 목적 축에서 landing을 판별했을 때 로드. 공통 코어 + 해당 플랫폼 파일과 함께 적용. -->

A page whose one job is to persuade a visitor to take a single action. Everything serves
conversion; anything that doesn't is a distraction. Layer this on the universal core
(`~/.claude/rules/design.md`) and the relevant platform file.

## Optimize for
- **The headline.** ~80% of visitors read only the headline and the first subhead line before
  deciding to stay or leave. Make it **benefit-led, not feature-led** (benefit-led converts
  ~27% better), and include a concrete number where honest (~15% better than vague claims).
- **A single, repeated CTA.** One primary action, restated 2–3 times down the page. Pages with
  5+ competing CTAs convert markedly worse. One decision, made easy.
- **Trust, above the fold.** Stack 2–3 forms of social proof (logos, ratings, badges,
  testimonials) high on the page — credibility is established immediately or not at all.
- **A strong hero.** Bold, oversized typography can replace a stock hero image and state the
  value proposition unmissably. A short **video-first hero** showing the real product lifts
  engagement when it loads fast.
- **Scannability.** Bento grids and card sections present a complex product in digestible
  blocks. Visitors scan; they don't read.

## Resist (what usually hurts a landing page)
- **Navigation menus.** Removing top nav from a focused landing page commonly lifts conversion
  ~10–15% — it removes exits. This is the highest-impact, lowest-effort change.
- **Information density.** This is the one purpose where *less* content usually wins. Dashboards
  reward density; landing pages punish it.
- **Multiple asks.** Every extra CTA or form field is friction.

## Platform notes
- **Mobile:** headline ≤ ~8 words / ~44 characters so it lands in one glance; primary CTA in the
  thumb zone; keep the hero light for fast first paint.
- **Web:** exploit the wide hero, but keep the value proposition and CTA visible without scroll.

## Anti-patterns
- ❌ Feature-led headline ("Powered by X engine") instead of a benefit
- ❌ Full site navigation on a conversion page
- ❌ Multiple competing CTAs / a wall of copy
- ❌ Carousel heroes and autoplay video that delays first paint
- ❌ Social proof buried below the fold

## Route 2 prompt — must include
<!-- design-sketch가 프롬프트를 뽑을 때 이 목적에 반드시 넣을 항목. -->
One benefit-led headline; a **single** primary CTA; 2–3 trust signals above the fold; **no
navigation menu**; a hero (bold oversized type or a fast product video).

<!-- Sources (2026): saashero, neelnetworks, moburst, digitalapplied (landing stats), helpfulhero. -->
