# Purpose: Document / Report
<!-- 길게 읽는 산출물: 리포트, 문서, 아티클, 프린트/PDF. 가독성이 전부. -->
<!-- design-sketch가 목적 축에서 document를 판별했을 때 로드. 공통 코어 + 해당 플랫폼 파일과 함께 적용. -->

Long-form content meant to be read and understood: reports, documentation, articles, printable
PDFs. Success is reading comfort and comprehension. Layer this on the universal core
(`~/.claude/rules/design.md`) and the relevant platform file.

## Optimize for
- **Readability of long passages.** This is the whole game. Legibility (can I tell the letters
  apart) plus readability (can I read paragraphs without fatigue).
- **Reading rhythm.** Line length **45–75 characters**; **line-height ~1.5–1.6** — raising
  spacing from tight to ~120% measurably improves reading accuracy and cuts eye strain over
  long passages. Body ≥16px, comfortably larger for primary reading.
- **Typographic hierarchy.** Clear, consistent heading scale; a body face built for sustained
  reading. Editorial serifs (e.g. Lora-class) suit long-form; a well-set humanist sans is fine
  too. Consistency beats variety.
- **Scannability.** Descriptive headings, a table of contents for anything long, pull quotes,
  and generous section spacing so readers can find and re-find their place.
- **Print / PDF fidelity.** If it may be printed or exported, design for paper too: page
  breaks that don't orphan headings, high text contrast, no reliance on background color, and
  units that survive export.

## Resist
- **Interaction and motion.** A document is not an app. Scroll-jacking, entrance animations,
  and hover-dependent content get in the way of reading.
- **Hero visuals and decoration** that push the actual content down.
- **Cramped, wide, low-contrast text** — the cardinal sins of long-form.

## Platform notes
- **Web:** cap measure with a max-width column even on wide screens; comfortable margins; a
  sticky mini-TOC helps for long pages.
- **Mobile:** single column, larger type, generous vertical spacing; avoid multi-column that
  forces horizontal effort.

## Anti-patterns
- ❌ Full-viewport-width paragraphs (measure far over 75 chars)
- ❌ Tight line-height on long text
- ❌ Low-contrast "elegant" grey body text
- ❌ Motion / scroll effects that interrupt reading
- ❌ Color-only meaning that vanishes when printed in grayscale

## Route 2 prompt — must include
<!-- design-sketch가 프롬프트를 뽑을 때 이 목적에 반드시 넣을 항목. -->
Line length 45–75 characters; line-height ~1.5–1.6; a clear heading hierarchy + reading-optimized
body face; a table of contents for long pieces; print/PDF-safe (high contrast, no color-only
meaning); minimal interaction/motion.

<!-- Sources (2026): IxDF readability; adoc-studio typography guide; inkbot hierarchy; Toptal web typography; LaunchNow fonts. -->
