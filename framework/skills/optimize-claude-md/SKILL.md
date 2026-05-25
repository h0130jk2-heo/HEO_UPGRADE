---
name: optimize-claude-md
description: Use when the user calls /optimize-claude-md, or says things like "CLAUDE.md 정리", "CLAUDE.md 최적화", "규칙 정리", "컨텍스트 정리", "clean up CLAUDE.md", "optimize instructions", "refactor rules", or wants to audit/improve their CLAUDE.md after the codebase has stabilized. Use this skill whenever CLAUDE.md structure, quality, or relevance is in question — even if the user doesn't say "optimize" explicitly. DO NOT diagnose or edit CLAUDE.md without following this skill's 3-step sequence.
---

# optimize-claude-md

## Overview

This skill diagnoses, plans, and improves CLAUDE.md files after a project's major features are complete. It is designed for the **post-stabilization phase** — not project start. The goal is a lean, accurate CLAUDE.md that helps Claude navigate and act confidently without wasted tokens or stale rules.

**Three-stage gate:** Diagnose → Plan (user approval) → Execute. Never skip stages or merge them.

---

## Step 1: Diagnose

> Before running diagnosis, print this reminder:
> **"For deepest analysis, switch to a model with extended thinking (e.g., /model opus with thinking). Proceed with current model otherwise."**

Read the project's CLAUDE.md (and `~/.claude/CLAUDE.md` if it exists). Then evaluate against four roles:

### Role 1: Project Map
- Does the described folder structure match what actually exists on disk?
- Can Claude find key files without searching?
- Are entry points, config files, and output directories identified?

### Role 2: Rules & Preferences
- Are coding style, language, and library choices stated?
- Are any rules now obsolete (e.g., referencing removed features)?
- Are rules that apply only to one folder incorrectly written as global rules?

### Role 3: Capability Boundaries
- Are available external APIs, tools, and scripts listed?
- Are there capabilities Claude has but CLAUDE.md implies it doesn't?
- Are restrictions clearly explained (why, not just what)?

### Role 4: Lessons Learned
- Are past failure patterns recorded?
- Are library/version issues documented?
- Is the "past mistakes" section empty when it shouldn't be?

### Structural Checks
- **Line count** — is CLAUDE.md under 200 lines? (200-line recommended limit)
- **Duplication** — are any rules or facts repeated?
- **Scope creep** — are folder-specific rules written as if global?
- **`.claude/rules/` usage** — are large rule sets split into scoped files?

### Diagnosis Output Format

Print a table with each item rated `[OK / PARTIAL / MISSING]`:

```
| Area                  | Status  | Finding                          |
|-----------------------|---------|----------------------------------|
| Project Map           | PARTIAL | Output folder not documented     |
| Rules & Preferences   | OK      | Language and style clearly stated|
| Capability Boundaries | MISSING | No mention of available APIs     |
| Lessons Learned       | MISSING | Mistakes section is empty        |
| Line count            | OK      | 87 lines (under 200)             |
| Duplication           | PARTIAL | Session routine repeated twice   |
| Scope rules           | OK      | No global/local confusion found  |
| .claude/rules/ usage  | MISSING | 8 rules could be split out       |
```

End Step 1 with:
> **"Diagnosis complete. Review the findings above. When ready, say 'plan it' to proceed to Step 2."**

---

## Step 2: Plan

> Print this before proceeding:
> **"Switch to Plan mode (Shift+Tab) to review the proposed changes before anything is written."**

For each issue found in Step 1, produce an improvement entry:

```
Change #N
- Location:    <file path, e.g. CLAUDE.md line 42 or .claude/rules/api.md (new)>
- Type:        [ADD / MODIFY / DELETE / SPLIT]
- Current:     <brief quote or summary of current state>
- After:       <what it will look like after the change>
- Reason:      <why this improves Claude's performance>
- Priority:    [HIGH / MEDIUM / LOW]
```

### Planning Principles
- Keep CLAUDE.md under 200 lines after changes
- If 5+ rules address a single topic, move them to `.claude/rules/<topic>.md`
- Apply `paths:` scoping to rules that apply only within one directory
- Do not touch sections that are accurate and working well
- For DELETE items: quote the exact content being removed and explain why it's no longer needed

End Step 2 with:
> **"WARNING: Items marked DELETE will be permanently removed. Review each carefully.**
> **When you're satisfied with the plan, say 'execute' to proceed to Step 3."**

---

## Step 3: Execute

> Only begin after the user explicitly says "execute" or equivalent confirmation.

Apply changes in priority order (HIGH first). Before executing any DELETE:

> **"About to delete: [quoted content]. Confirm? (yes to proceed)"**

After all changes are applied, print a completion checklist:

```
Post-execution checklist:
[ ] CLAUDE.md is under 200 lines
[ ] No obsolete rules remain
[ ] Folder-specific rules are in .claude/rules/ with paths: scoping
[ ] Actual project structure matches CLAUDE.md documentation
[ ] No duplicate content
```

---

## Hard Rules

- **Never diagnose and edit in the same step.** Diagnosis is read-only.
- **Never skip Step 1 to go straight to edits**, even if the user asks.
- **Never delete content without quoting it and getting explicit confirmation.**
- **Do not "improve" sections that aren't in the diagnosis findings** — scope your changes to what was found.
