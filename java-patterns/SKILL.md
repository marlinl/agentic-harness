---
name: java-patterns
description: java style, formatting, and review guidance translated from the marlinl intellij code style configuration. use when editing, generating, reviewing, or refactoring java code in codex, claude code, chatgpt, or another coding agent, especially when the user asks for java patterns, repository code style, formatting consistency, import ordering, wrapping, indentation, or style-preserving changes based on marlinlcodestyle.xml.
---

# Java Patterns

Apply this skill whenever working on Java source files that should follow the MarlinL IntelliJ code style. Treat these rules as the local repository style unless the repository has a more specific instruction.

## Primary behavior

- Preserve existing behavior first; style cleanup must not change semantics.
- Prefer minimal diffs. Do not reformat unrelated code unless the user asks for broad formatting.
- When generating new Java, write it in this style from the start.
- When modifying existing Java, keep surrounding local patterns when they are consistent with these rules.
- When style rules conflict, prefer the Java-specific rules below over global or non-Java settings.
- Do not invent additional style rules from Google Java Format, Checkstyle, or another guide unless the repository explicitly uses them.

## Core Java style rules

### Indentation and line length

- Use 2 spaces for indentation.
- Use 2 spaces for continuation indentation.
- Use a tab width of 2, but do not insert tab characters.
- Keep lines at or below 120 columns when practical.
- Wrap comments to fit the 120-column margin.

### Blank lines

- Keep at most 1 blank line inside Java code.
- Keep 1 blank line after a class header when the class body is not empty.
- Keep 1 blank line before the final class closing brace when the class body is not empty.
- Do not add extra blank lines before ordinary closing braces.
- Avoid decorative vertical spacing; use blank lines to separate logical sections only.

### Imports

- Use explicit imports. Do not use wildcard imports such as `java.util.*` or `import static org.junit.Assert.*`.
- Import thresholds are effectively disabled: never switch to on-demand imports because of many classes or static names.
- Import inner classes explicitly when needed.
- Order imports as:
  1. all static imports,
  2. one blank line,
  3. all non-static imports.
- Sort imports alphabetically within each group.
- Do not leave unused imports.

Example import layout:

```java
import static com.example.Flags.ENABLED;
import static java.util.Comparator.comparing;

import com.example.Service;
import java.util.List;
```

### Braces and control flow

- Always use braces for `if`, `else`, `for`, `while`, and `do-while` bodies, even when the body is a single statement.
- Do not keep control statements on one line.
- Prefer this:

```java
if (enabled) {
  start();
}
```

- Avoid this:

```java
if (enabled) start();
```

- `else` and `catch` may stay on the same line as the previous closing brace if that is the local style, but their bodies must still use braces.

### Parameters and arguments

- Do not align multiline method parameters or call arguments into columns.
- Use continuation indentation instead of vertical alignment.
- Wrap method declaration parameters as needed, preferring a compact form until the 120-column margin would be exceeded.
- Wrap call arguments as needed, preferring a compact form until the 120-column margin would be exceeded.

Preferred wrapping shape:

```java
Result result = service.compute(
  accountId,
  requestContext,
  retryPolicy);
```

Avoid alignment-only formatting:

```java
Result result = service.compute(accountId,
                                requestContext,
                                retryPolicy);
```

### Method chains

- Wrap method call chains as needed before exceeding 120 columns.
- Use continuation indentation, not column alignment.
- Keep simple chains on one line when they fit.

Example:

```java
return users.stream()
  .filter(User::isActive)
  .sorted(comparing(User::createdAt))
  .toList();
```

### Binary and ternary expressions

- Wrap binary operations as needed.
- When a binary operation wraps, put the operator at the start of the next line.
- Do not vertically align wrapped binary expressions.

Example:

```java
boolean allowed = hasPermission
  && account.isActive()
  && !account.isSuspended();
```

- Wrap ternary expressions as needed.
- When a ternary expression wraps, put `?` and `:` at the start of the continuation lines.

Example:

```java
String label = enabled
  ? activeLabel
  : inactiveLabel;
```

### `for`, `extends`, `throws`, and arrays

- Wrap `for` statements as needed, using continuation indentation rather than alignment.
- Wrap `extends` and `implements` lists as needed, especially when long.
- Wrap `throws` clauses as needed, especially when long.
- Wrap array initializers as needed.
- Put a space before an array initializer left brace when applicable.

Example:

```java
int[] values = new int[] {1, 2, 3};
```

### Simple methods and lambdas

- Simple methods may remain on one line when they are genuinely short and readable.
- Simple lambdas may remain on one line when they are genuinely short and readable.
- Do not force one-line methods or lambdas if line length, comments, or readability would suffer.

## Editing workflow

1. Before editing, identify whether the target is Java source. If not, do not apply these Java-specific rules unless the user asks for equivalent style guidance.
2. Make the requested code change with minimal scope.
3. Normalize only the touched Java code to this style.
4. Check imports after edits: remove unused imports, keep explicit imports, static imports first, blank line, then non-static imports.
5. Check touched control flow for mandatory braces.
6. Check touched wrapping: 120 columns, 2-space continuation indent, no alignment columns, operators on continuation lines for binary and ternary expressions.
7. Mention any intentional style tradeoff if exact formatting is unsafe without running the repository formatter.

## Optional local check script

This skill may include `scripts/check_java_patterns.py`, a lightweight heuristic checker. Use it only when file-system access is available and the user asks to review style or verify a patch.

Run from a repository root or pass paths explicitly:

```bash
python scripts/check_java_patterns.py .
python scripts/check_java_patterns.py src/main/java src/test/java
```

The script is not a formatter and is not a replacement for repository tests or IntelliJ formatting. Treat its output as review hints.
