# TypeScript / JavaScript Rules

## Language Conventions
- Strict TypeScript: enable `strict` in tsconfig. Never use `any` — use `unknown` + type narrowing.
- ESM imports (`import/export`) over CommonJS (`require`). Use `.js` extension in import paths when targeting Node ESM.
- Naming: `camelCase` for functions/variables, `PascalCase` for types/interfaces/classes/components, `UPPER_SNAKE` for constants.
- Prefer `const` over `let`. Never use `var`.
- Prefer `===` / `!==` over `==` / `!=`.

## Error Handling
- Use typed errors or error codes, not bare string throws.
- Always handle Promise rejections — no floating promises. Use `void` prefix if intentionally fire-and-forget.
- Prefer early returns over deep nesting.

## Patterns
- Prefer `async/await` over `.then()` chains.
- Use nullish coalescing (`??`) and optional chaining (`?.`) instead of manual null checks.
- Destructure function parameters when there are 3+ related arguments — use an options object.
- Prefer `Array.map/filter/reduce` for transformations; use `for...of` when side effects or early exit are needed.

## Common Pitfalls
- `typeof null === 'object'` — always check `null` explicitly before `typeof`.
- Array `.sort()` mutates in place and sorts lexicographically by default — pass a comparator.
- `JSON.parse` can throw — always wrap in try/catch at system boundaries.
- Template literals over string concatenation.

## Dependencies
- Prefer well-maintained packages with TypeScript type definitions (`@types/*` or built-in).
- Check bundle size impact before adding a dependency — prefer native APIs when available.
