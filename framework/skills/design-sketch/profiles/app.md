# Purpose: App / Tool UI
<!-- 사용자가 반복적으로 작업을 수행하는 도구/앱(SaaS 포함). 효율과 일관성이 핵심. -->
<!-- design-sketch가 목적 축에서 app을 판별했을 때 로드. 공통 코어 + 해당 플랫폼 파일과 함께 적용. -->

An interface people use repeatedly to get work done — SaaS products, internal tools, utilities.
Success is task efficiency and low friction over many sessions, not a first impression. Layer
this on the universal core (`~/.claude/rules/design.md`) and the relevant platform file.

## Optimize for
- **Task efficiency.** Minimize steps and clicks for the frequent path. The best interface for a
  daily tool is the one that gets out of the way.
- **Component consistency.** One button, one input, one card — reused everywhere. Consistency is
  what makes a tool feel learnable and "premium" (coherence, per the core). Build on tokens.
- **The four states, always.** loading / empty / error / success — plus sensible defaults. Empty
  states should teach the next action, not show a blank void.
- **Progressive disclosure.** Don't remove features — *sequence* when users meet them. Surface
  the common 20% up front; keep the long tail one level deeper.
- **Command palette** for any product past ~10 features. Menus don't scale; a "type what you
  want" palette (⌘K) is a 2026 baseline expectation and removes navigation friction.
- **Onboarding by doing.** The strongest flows have the user create a real artifact within the
  first minute; guidance appears in context at the moment of need, not as an upfront tour.
- **Reversibility.** Undo, confirmations for destructive actions, and clear recovery — this is
  the core "transparent & reversible" principle, and it's what lets users work fearlessly.

## Resist
- **Marketing flair** — this is not a landing page; delight is earned through smoothness, not
  spectacle. (A little well-placed delight *does* aid retention — just not at the cost of speed.)
- **Deep nested menus** as the primary way to reach features.
- **Blocking, upfront tours** that gate the product behind a slideshow.

## Platform notes
- **Web:** keyboard-first (shortcuts, command palette, full Tab support); density is acceptable
  for power users; hover for secondary affordances (with non-hover fallbacks).
- **Mobile:** primary actions in the thumb zone; bottom nav / bottom sheets; respect iOS vs
  Android conventions; forms sized for touch (≥44pt, ≥16px inputs).

## Anti-patterns
- ❌ Missing empty/error/loading states (happy-path-only)
- ❌ Inconsistent components (three button styles for one meaning)
- ❌ Core features buried in nested menus with no command palette
- ❌ Destructive actions with no undo/confirmation
- ❌ Mandatory upfront tour instead of learn-by-doing

## Route 2 prompt — must include
<!-- design-sketch가 프롬프트를 뽑을 때 이 목적에 반드시 넣을 항목. -->
The **four states** (loading/empty/error/success) for the main surface; consistent, reused
components; a command palette if the product has >~10 features; undo/confirmation on destructive
actions; learn-by-doing (no blocking upfront tour).

<!-- Sources (2026): saasui.design (SaaS UI/onboarding); userpilot; theskinsfactory; designstudiouiux; LogRocket (reversible UX). -->
