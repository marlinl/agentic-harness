---
name: java-patterns
description: java style, formatting, and review guidance translated from the marlinl intellij code style configuration. use when editing, generating, reviewing, or refactoring java code in codex, claude code, chatgpt, or another coding agent, especially when the user asks for java patterns, repository code style, formatting consistency, import ordering, wrapping, indentation, or style-preserving changes based on marlinlcodestyle.xml.
---

# Java Patterns

Apply this skill whenever working on Java source files. Treat the Java rules under `rules/java/` as the source of truth unless the repository has a more specific instruction.

## Primary Behavior

- Preserve existing behavior first; style cleanup must not change semantics.
- Prefer minimal diffs. Do not reformat unrelated code unless the user asks for broad formatting.
- When generating new Java, write it in the repository Java style from the start.
- When modifying existing Java, keep surrounding local patterns when they are consistent with the Java rules.
- When Java rules conflict with global rules, prefer the Java-specific rules.

## When to Use

- **Always active during Java code generation:** Apply these conventions whenever writing `.java` files.
- **When creating new classes, interfaces, or enums:** Follow naming and structure rules.
- **When organizing packages:** Follow the package layout conventions.
- **When specifically requested:** User asks "Java style", "formatting", "naming conventions", or "idiomatic Java".

## Rule Sources

- `rules/java/coding-style.md` — naming, formatting, blank lines, imports, wrapping, member order, comments, Javadocs, annotations.
- `rules/java/patterns.md` — repository/service layering, constructor injection, DTO mapping, builder pattern, sealed domain results, response envelopes.
- `rules/java/testing.md` — JUnit 5, AssertJ, Mockito, Testcontainers, test naming, coverage.
- `rules/java/security.md` — secrets, SQL injection prevention, validation, auth, dependency security, safe errors.
- `rules/java/hooks.md` — Java-related hook recommendations.

## Design Guidance

Design choices are not part of `rules/java/coding-style.md`. For class boundaries, method shape, immutability, records, `Optional`, null handling, package layout, and framework architecture, use this skill together with `clean-code`, `spring-boot-patterns`, and `jpa-patterns`.

## Editing Workflow

1. Before editing, identify whether the target is Java source. If not, do not apply Java-specific rules unless the user asks.
2. Make the requested code change with minimal scope.
3. Normalize only touched Java code to `rules/java/coding-style.md`.
4. Check imports after edits: remove unused imports, keep explicit imports, static imports first, blank line, then non-static imports, each group sorted alphabetically.
5. Check touched control flow for mandatory braces.
6. Check touched wrapping: 120 columns, 2-space continuation indent, no alignment columns, operators on continuation lines for binary and ternary expressions.
7. Mention any intentional style tradeoff if exact formatting is unsafe without running the repository formatter.

## Optional Style Check

This skill includes `scripts/check_java_patterns.py`, a lightweight heuristic checker. Use it when file-system access is available and the user asks to review style or verify a patch.

```bash
python scripts/check_java_patterns.py .
python scripts/check_java_patterns.py src/main/java src/test/java
```

The script checks tabs, line length, trailing whitespace, wildcard imports, import ordering, blank lines, and control flow braces. It is not a formatter and is not a replacement for repository tests or IntelliJ formatting. Treat its output as review hints.

## Related Skills

- `clean-code` — DRY, KISS, YAGNI principles
- `spring-boot-patterns` — Controller / Service / Repository patterns
- `test-quality` — JUnit 5 + AssertJ testing conventions
