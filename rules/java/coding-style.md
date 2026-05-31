---
paths:
  - "**/*.java"
---
# Java Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Java-specific content.

## Formatting Source

- **google-java-format** or **Checkstyle** (Google or Sun style) for enforcement
- Repository-local manual edits should still follow the rules in this file.
- Do not invent additional style rules from another guide unless the repository explicitly uses them.

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Package | `lowercase`, no underscores | `com.example.myapp.controller` |
| Class / Interface | `PascalCase` | `UserController`, `UserRepository` |
| Record | `PascalCase` | `UserResponse`, `CreateUserRequest` |
| Enum | `PascalCase` | `OrderStatus`, `UserRole` |
| Enum constant | `UPPER_SNAKE_CASE` | `PENDING`, `IN_PROGRESS` |
| Method | `camelCase` | `findById`, `calculateTotal` |
| Variable | `camelCase` | `userList`, `totalAmount` |
| Constant (`static final`) | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Type parameter | Single capital letter or descriptive `TName` | `T`, `R`, `E`, `TEntity` |
| Annotation | `PascalCase` | `@Valid`, `@NotNull` |
| Test method | Descriptive `camelCase` | `shouldReturn404WhenUserNotFound` |
| Boolean variable/method | `is` / `has` / `should` / `can` prefix | `isActive`, `hasPermission` |

Use intention-revealing names. Avoid vague names such as `d`, `ul`, `flag`, `data`, or `result` when the type or purpose is not obvious.

## Indentation and Line Length

- Indent with 2 spaces, no tabs.
- Use 2 spaces for continuation indentation.
- Treat tab width as 2, but do not insert tab characters.
- Keep lines at or below 120 columns when practical.
- Wrap comments to fit the 120-column margin.

## Blank Lines

- Max 1 blank line in code; do not use consecutive blank lines.
- Keep 1 blank line after a class header when the class body is not empty.
- Keep 1 blank line before the final class closing brace when the class body is not empty.
- Keep 1 blank line between methods.
- Keep 1 blank line between logical sections within a method.
- Avoid decorative vertical spacing; use blank lines to separate logical sections only.

```java
public class UserController {

  private final UserService userService;

  public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
    if (id == null) {
      return ResponseEntity.badRequest().build();
    }
    return ResponseEntity.ok(userService.findById(id));
  }

}
```

## Imports

- Use explicit imports; do not use wildcard imports.
- Import thresholds are effectively disabled.
- Import inner classes explicitly when needed.
- Order imports as:
  1. All static imports, sorted alphabetically
  2. One blank line
  3. All non-static imports, sorted alphabetically
- Do not leave unused imports.

```java
import static com.example.Flags.ENABLED;
import static java.util.Comparator.comparing;

import com.example.Service;
import java.util.List;
```

## Braces and Control Flow

- Always use braces for `if`, `else`, `while`, `for`, and `do-while`, even for single-line bodies.
- Do not keep control statements on one line.
- `else` and `catch` may stay on the same line as the previous closing brace if that is the local style, but their bodies must still use braces.

```java
if (user == null) {
  return ResponseEntity.notFound().build();
}

for (Job job : jobs) {
  execute(job);
}
```

## Parameters and Arguments

- Do not align multiline parameters or call arguments into columns.
- Use continuation indentation instead of vertical alignment.
- Wrap as needed for the 120-column margin.

```java
Result result = service.compute(
  accountId,
  requestContext,
  retryPolicy);
```

## Method Chains

- Wrap method call chains as needed before exceeding 120 columns.
- Use continuation indentation, not column alignment.
- Keep simple chains on one line when they fit.

```java
return users.stream()
  .filter(User::isActive)
  .sorted(comparing(User::createdAt))
  .toList();
```

## Wrapping Rules

| Construct | Wrap Rule |
|-----------|-----------|
| Method / call parameters | Wrap if long, prefer wrap |
| Method call chains | Wrap if long |
| Binary operations | Wrap if long, operator on next line |
| Ternary expressions | Wrap if long, `?` and `:` on next line |
| `extends` / `implements` list | Chop down if long |
| `throws` clause | Chop down if long |
| `for` statement | Chop down if long |
| Array initializer | Chop down if long |
| `try-with-resources` | Do not align |

```java
boolean allowed = hasPermission
  && account.isActive()
  && !account.isSuspended();

String label = enabled
  ? activeLabel
  : inactiveLabel;

int[] values = new int[] {1, 2, 3};
```

## One-Line Rules

- Simple methods and lambdas may stay on one line when they are genuinely short, readable, and under 120 columns.
- Do not force one-line code if line length, comments, or readability would suffer.

```java
public String getName() { return name; }

users.forEach(user -> log.info(user.getName()));
```

## Member Order

- Order class members as:
  1. `static final` constants
  2. `static` fields
  3. Instance fields, with injected dependencies before state
  4. Constructors
  5. Public methods, following request lifecycle order where relevant
  6. Protected / package-private methods
  7. Private methods
  8. `equals` / `hashCode` / `toString`
  9. Nested classes / enums

## Comments

- Add Javadoc on public APIs such as controller endpoints and service interfaces.
- Do not add Javadoc on private methods; prefer self-documenting code.
- Delete commented-out code.
- Use inline comments only for non-obvious why, not what.
- Do not add `@author` or `@since`; git tracks authorship and time.

```java
// ISO 8601 basic format required by the legacy payment gateway
private static final DateTimeFormatter GATEWAY_DATE_FORMAT =
  DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
```

## Javadoc Style

```java
/**
 * Finds a user by their unique identifier.
 *
 * @param id the user's unique identifier, must not be null
 * @return the user response
 * @throws ResourceNotFoundException if no user exists with the given id
 */
UserResponse findById(Long id);
```

- First sentence should describe behavior directly, for example "Finds", not "This method finds".
- Add `@param`, `@return`, and `@throws` only when they add information beyond the signature.

## Annotations

- Keep one or two simple annotations compact.
- Use one annotation per line when there are three or more annotations, or when annotations have parameters.

```java
@GetMapping("/{id}")
public ResponseEntity<UserResponse> getUser(@PathVariable Long id) { ... }

@Override
@Transactional(readOnly = true)
@Cacheable(value = "users", key = "#id")
public UserResponse findById(Long id) { ... }
```

## References

See skill: `java-patterns` for Java coding behavior and design guidance.
