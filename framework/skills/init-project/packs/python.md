# Python Rules

## Language Conventions
- Python 3.10+ assumed. Use type hints on all function signatures.
- Naming: `snake_case` for functions/variables/modules, `PascalCase` for classes, `UPPER_SNAKE` for module-level constants.
- Use f-strings for string formatting. Never use `%` formatting or `.format()` for new code.
- Prefer `pathlib.Path` over `os.path` for file system operations.

## Error Handling
- Use specific exception types, never bare `except:` or `except Exception:` without re-raising.
- Use `contextlib.suppress()` for intentional exception swallowing instead of empty except blocks.
- Prefer EAFP (try/except) over LBYL (if checks) for operations that are usually successful.

## Patterns
- Use dataclasses or Pydantic models for structured data, not plain dicts.
- Prefer list/dict/set comprehensions over `map`/`filter` with lambdas.
- Use `enumerate()` instead of manual index tracking.
- Use `with` statements for all resource management (files, connections, locks).
- Prefer `collections.defaultdict` or `dict.setdefault` over manual key existence checks.

## Common Pitfalls
- Mutable default arguments: never use `def f(x=[])` — use `def f(x=None)` + `x = x or []`.
- `is` vs `==`: use `is` only for `None`, `True`, `False` singletons.
- Circular imports: restructure modules or use late imports.
- Global state: avoid module-level mutable globals; pass dependencies explicitly.

## Dependencies
- Always use a virtual environment (`venv` or `uv`).
- Pin exact versions in `requirements.txt` or use `pyproject.toml` with version ranges.
- Prefer standard library modules when they cover the use case.
