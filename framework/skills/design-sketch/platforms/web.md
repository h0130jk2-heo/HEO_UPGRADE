# Platform: Web
<!-- 브라우저(주로 데스크톱~반응형)에서 실행되는 산출물의 디자인 가이드. -->
<!-- design-sketch가 플랫폼 축에서 web을 판별했을 때만 로드. 공통 코어(rules/design.md)에 더해서 적용. -->

Guidance for artifacts that run in a browser. Layer this on top of the universal core in
`~/.claude/rules/design.md`. If the project also targets mobile, load `mobile.md` too and
compose (see "Responsive handoff" below).

## What web gives you (and what to exploit)
- **A wide canvas** — multi-column layouts, side-by-side comparison, higher information density
  than mobile can carry. Use it, but let clarity (not the empty space) decide density.
- **Hover and focus states** — affordances on pointer-over: previews, tooltips, row highlights.
  Never make hover the *only* path to an action (touch and keyboard users lose it).
- **Mouse + keyboard** — support both. Every interactive element must be reachable and operable
  by keyboard (Tab order, visible focus ring, Enter/Space activation, Esc to dismiss).

## Concrete rules
- **Responsive by default.** Design mobile-first breakpoints even for a "desktop" app; content
  must re-flow, not just shrink. Common breakpoints: ~640 / 768 / 1024 / 1280px.
- **Constrain measure.** Cap text columns at 45–75 characters even on wide screens — full-width
  body text is hard to read. Use a max-width container.
- **Layout systems that scale:** CSS Grid for page structure; **bento grids** and **card-based**
  sections for scannable, responsive blocks (a dominant, well-worn 2026 pattern).
- **Performance is design.** Largest Contentful Paint under ~2.5s; lazy-load below-the-fold
  media; avoid layout shift (reserve image/embed dimensions). A slow page reads as a broken one.
- **Density with restraint.** Because web *allows* more, it also invites clutter — apply the
  universal "cognitive clarity over richness" rule harder here.

## Anti-patterns
- ❌ Action reachable only on hover (breaks touch + keyboard)
- ❌ Full-viewport-width paragraphs (no max-width)
- ❌ Fixed pixel layouts that don't re-flow on smaller viewports
- ❌ Heavy hero media that tanks LCP
- ❌ Desktop-only design with mobile treated as an afterthought

## Responsive handoff (web × mobile)
When both platforms apply: design the content and hierarchy once, then define how it re-flows.
Touch targets and thumb-zone rules from `mobile.md` win on small viewports; hover affordances
from this file apply only on pointer devices (`@media (hover: hover)`).

## Route 2 prompt — must include
<!-- design-sketch가 프롬프트를 뽑을 때 이 플랫폼에 반드시 넣을 항목. -->
Responsive layout with breakpoints (re-flow, not just shrink); hover/focus states **with a
non-hover fallback**; capped text measure (max-width); fast LCP (light hero media).

<!-- Sources (2026): Figma web design trends; index.dev; UXPin (tokens); SaaS bento-grid adoption. -->
