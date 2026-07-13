# Platform: Mobile
<!-- 모바일(네이티브 앱 또는 모바일 웹)에서 실행되는 산출물의 디자인 가이드. -->
<!-- design-sketch가 플랫폼 축에서 mobile을 판별했을 때만 로드. 공통 코어(rules/design.md)에 더해서 적용. -->

Guidance for artifacts used on a phone (native app or mobile web). Layer this on the universal
core in `~/.claude/rules/design.md`. Mobile is not "web, smaller" — the ergonomics and
conventions differ enough to change the design.

## The constraints that reshape everything
- **One-thumb reality.** ~75% of phone interaction is a single thumb. The comfortable **thumb
  zone** is the bottom third of the screen plus a curve up the dominant-hand side. Put primary
  actions and navigation there; the top is for glanceable info, not frequent taps.
- **Touch targets.** Minimum **44pt (iOS HIG)** / **48dp (Material)**. Space them so fingers
  don't hit neighbors. Fingers are far less precise than a cursor.
- **No hover.** Every affordance must be visible without pointer-over. Don't hide actions behind
  states that touch can't reach.
- **Safe areas.** Respect notches, dynamic islands, rounded corners, and the home indicator —
  keep content and controls out of the inset regions.

## Concrete rules
- **Bottom-centric navigation.** Tab bars, and increasingly **bottom sheets** and pull-down
  gestures (Apple Maps, Telegram) — the primary surface is anchored low, within thumb reach.
- **Gestures supplement, never replace, visible controls.** Swipe-to-delete is a delight *when*
  a visible delete also exists; it's a trap when it's the only way. Pair each gesture with
  **haptic feedback** so the user feels the trigger before their eyes confirm it.
- **Respect native conventions per OS.** iOS = Human Interface Guidelines (HIG-native gestures,
  bottom tabs, Liquid Glass materials); Android = Material 3 / Material You (dynamic color).
  **Keeping each platform's native patterns beats forcing one uniform look across both.**
- **Performance & battery.** Mobile networks and thermals are tighter — keep payloads and
  animation cost low.
- **Type & tap.** Body ≥16px (also prevents iOS auto-zoom on inputs); generous vertical spacing.

## Anti-patterns
- ❌ Primary action stranded at the top of a tall screen
- ❌ Touch targets under 44pt / crammed together
- ❌ Gesture as the *only* way to do something
- ❌ Content clipped by notch / home indicator (no safe-area handling)
- ❌ Forcing an identical UI on iOS and Android against both conventions
- ❌ Desktop density crammed onto a phone

## Composition (mobile × purpose)
Apply the purpose profile's priorities, then re-fit for the thumb: fewer visible elements at
once, primary action low, progressive disclosure for the rest. E.g. *mobile × dashboard* keeps
KPI hierarchy but shows fewer cards per view and moves filters into a bottom sheet.

## Route 2 prompt — must include
<!-- design-sketch가 프롬프트를 뽑을 때 이 플랫폼에 반드시 넣을 항목. -->
Touch targets ≥44pt/48dp; primary action in the thumb zone (bottom); no hover-only affordances;
safe-area handling (notch/home indicator); the platform's native conventions (iOS HIG / Material 3).

<!-- Sources (2026): Muzli mobile patterns; Parachute (thumb zone); asappstudio (iOS); Material 3; DeventiaTech. -->
