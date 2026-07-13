# Purpose: Dashboard / Data
<!-- 데이터를 보고 결정을 내리게 하는 화면. 장식이 아니라 판단을 돕는 게 목적. -->
<!-- design-sketch가 목적 축에서 dashboard를 판별했을 때 로드. 공통 코어 + 해당 플랫폼 파일과 함께 적용. -->

A screen that helps someone read data and make a decision. Success is *time-to-insight*, not
visual impressiveness. Layer this on the universal core (`~/.claude/rules/design.md`) and the
relevant platform file.

## Optimize for
- **A hierarchy that answers questions in order:**
  - **Top (above the fold):** status + key KPIs — "are we OK or not?"
  - **Middle:** trends and comparisons — "what's changing, and where?"
  - **Bottom / drill-down:** breakdowns, details, filters — "why is this happening?"
- **One chart, one question.** Match the chart type to the specific question; put the answer
  where the eye lands first; remove anything that doesn't help that decision.
- **A trusted number.** Each metric should trace to a certified/defined source — a pretty chart
  on a wrong number is worse than no chart.
- **Restraint in count.** Working memory holds ~5–9 elements; dashboards past ~12 KPIs show a
  sharp engagement drop. Split into focused views rather than one dense wall.

## Resist
- **Decoration.** No 3D/rotating pie charts, animated backgrounds, gifs, flashing elements.
  Motion here should only reflect data changes, not entertain.
- **Over-interactivity.** For frequently-viewed dashboards, excess filters/drill-downs raise
  time-to-insight. Default to the answer; make interaction optional, not required.
- **Storytelling flourish** that belongs on a landing page, not a working instrument.

## Color & accessibility (critical for data)
- 1–2 primary colors + 1 accent; avoid bright fills over large areas.
- **Never encode a series by color alone** — add labels, direct annotation, patterns, or icons
  (color-blind readers, print, projectors).
- Maintain WCAG contrast for text and for chart-to-background.

## Platform notes
- **Web:** density is allowed — use the wide canvas for side-by-side comparison, but still lead
  with the KPI row.
- **Mobile:** fewer cards per view; KPIs stacked; filters in a bottom sheet; charts simplified
  (a sparkline may beat a full axis grid on a phone).

## Anti-patterns
- ❌ 3D/animated/rotating charts; decorative motion
- ❌ Pie chart with many slices (unreadable); wrong chart for the question
- ❌ >12 KPIs on one screen; inconsistent, unstructured layout
- ❌ Meaning by color alone
- ❌ Interactivity required to reach the basic answer

## Route 2 prompt — must include
<!-- design-sketch가 프롬프트를 뽑을 때 이 목적에 반드시 넣을 항목. -->
KPI hierarchy (top status → mid trends/comparisons → drill-down); chart types matched to the
question; **≤ ~9 visible elements**; **no color-only encoding** (labels/patterns too); no
decorative/animated charts.

<!-- Sources (2026): UXPin dashboard principles; think.design do/don'ts; techment; Reddit-crowdsourced "worst dashboard". -->
