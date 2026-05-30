---
name: java-patterns
description: Java coding patterns, style, and conventions for Java 21+ / 25 based on the MarlinL IntelliJ code style configuration. Use when writing, editing, generating, reviewing, or refactoring Java code, defining classes, naming elements, organizing packages, formatting, imports, wrapping, or when user asks about Java style, idiomatic Java, or repository code style.
---

# Java Patterns

Apply this skill whenever working on Java source files. Treat these rules as the local repository style unless the repository has a more specific instruction.

## Primary Behavior

- **Preserve existing behavior first;** style cleanup must not change semantics.
- **Prefer minimal diffs.** Do not reformat unrelated code unless the user asks for broad formatting.
- **When generating new Java,** write it in this style from the start.
- **When modifying existing Java,** keep surrounding local patterns when they are consistent with these rules.
- **When style rules conflict,** prefer the Java-specific rules below over global or non-Java settings.
- **Do not invent additional style rules** from Google Java Format, Checkstyle, or another guide unless the repository explicitly uses them.

## When to Use

- **Always active during Java code generation:** Apply these conventions whenever writing `.java` files.
- **When creating new classes, interfaces, or enums:** Follow naming and structure rules.
- **When organizing packages:** Follow the package layout conventions.
- **When specifically requested:** User asks "Java style", "formatting", "naming conventions", or "idiomatic Java".

---

## Java Version

Target **Java 21+** (minimum). Use modern language features by default:

| Feature | Since | Prefer Over |
|---------|-------|-------------|
| Sealed classes | 17 | Open inheritance with visitor patterns |
| Pattern matching for switch | 21 | Cascading if-else / instanceof chains |
| Record classes | 16 | Lombok `@Value` / manual immutable DTOs |
| Text blocks | 15 | String concatenation for multi-line |
| Virtual threads | 21 | Platform thread pools for I/O-bound work |
| Unnamed patterns & variables | 22 | Unused catch variables |
| String templates (preview) | 21+ | String.format / StringBuilder |
| Structured concurrency (preview) | 21+ | Manual thread orchestration |

---

## Naming Conventions

### General Rule

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
| Type parameter | Single capital letter | `T`, `R`, `E` or descriptive `TEntity` |
| Annotation | `PascalCase` | `@Valid`, `@NotNull` |
| Test method | `camelCase` descriptive | `shouldReturn404WhenUserNotFound` |
| Boolean variable/method | `is`/`has`/`should`/`can` prefix | `isActive`, `hasPermission` |

### Naming Anti-patterns

```java
// Bad — abbreviation, unclear
int d; // elapsed time in days
List<User> ul = new ArrayList<>();
boolean flag = true;

// Good — intention-revealing
int elapsedTimeInDays;
List<User> activeUsers = new ArrayList<>();
boolean hasValidLicense = true;
```

---

## Formatting

Based on `MarlinLCodeStyle` IntelliJ code style scheme.

### Indentation and Line Length

- **Indent:** 2 spaces, no tabs
- **Continuation indent:** 2 spaces (same as regular indent — method chains and wrapped params align at same level)
- **Right margin:** 120 characters
- **Comments wrap** at right margin

### Braces and Control Flow

- **Always require braces** for `if`, `else`, `while`, `for`, `do-while` — even single-line bodies
- **Control statements never on one line**
- `else` and `catch` may stay on the same line as the previous closing brace if that is the local style, but their bodies must still use braces

```java
// Good
if (user == null) {
  return ResponseEntity.notFound().build();
}

for (Job job : jobs) {
  execute(job);
}

// Bad
if (user == null) return ResponseEntity.notFound().build();
for (Job job : jobs) execute(job);
```

### Blank Lines

- **Max 1 blank line** in code (no consecutive blank lines)
- **1 blank line** after class header
- **1 blank line** before class end
- **1 blank line** between methods
- **1 blank line** between logical sections within a method
- Avoid decorative vertical spacing; use blank lines to separate logical sections only

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

### Imports

- **No wildcard imports** (threshold set to 99999)
- **Layout:**
  1. All `static` imports, sorted alphabetically
  2. One blank line
  3. All non-static imports, sorted alphabetically (no further grouping by package)
- Import inner classes explicitly when needed
- Remove unused imports

```java
// Good
import static com.example.Flags.ENABLED;
import static java.util.Comparator.comparing;

import com.example.Service;
import java.util.List;

// Bad
import java.util.*;
import com.example.*;
import static org.junit.jupiter.api.Assertions.*;
```

### Parameters and Arguments

- **Do NOT align** multiline parameters or call arguments into columns
- Use continuation indentation instead of vertical alignment
- Wrap as needed for the 120-column margin

```java
// Good — continuation indent, no alignment
Result result = service.compute(
  accountId,
  requestContext,
  retryPolicy);

// Bad — column alignment
Result result = service.compute(accountId,
        requestContext,
        retryPolicy);
```

### Method Chains

- Wrap method call chains as needed before exceeding 120 columns
- Use continuation indentation, not column alignment
- Keep simple chains on one line when they fit

```java
return users.stream()
  .filter(User::isActive)
  .sorted(comparing(User::createdAt))
  .toList();
```

### Wrapping Rules

| Construct | Wrap Rule |
|-----------|-----------|
| Method / call parameters | Wrap if long, prefer wrap |
| Method call chains | Wrap if long |
| Binary operations | Wrap if long, **operator on next line** |
| Ternary expressions | Wrap if long, **`?` and `:` on next line** |
| `extends` / `implements` list | Chop down if long |
| `throws` clause | Chop down if long |
| `for` statement | Chop down if long |
| Array initializer | Chop down if long |
| `try-with-resources` | Do NOT align |

```java
// Binary operation — operator on next line
boolean allowed = hasPermission
  && account.isActive()
  && !account.isSuspended();

// Ternary — signs on next line
String label = enabled
  ? activeLabel
  : inactiveLabel;

// Array initializer — chop down, space before brace
int[] values = new int[] {1, 2, 3};
```

### One-line Rules

- Simple methods and lambdas may stay on one line when they are genuinely short, readable, and under 120 columns
- Do not force one-line if line length, comments, or readability would suffer

```java
// OK — simple one-liner
public String getName() { return name; }

// OK — simple lambda
users.forEach(user -> log.info(user.getName()));
```

---

## Class Design

### Single Class Per File

One top-level public class per `.java` file. Nested classes are fine when cohesive.

### Class Member Order

1. `static final` constants
2. `static` fields
3. Instance fields (injected dependencies first, then state)
4. Constructors
5. Public methods (following request lifecycle order)
6. Protected / package-private methods
7. Private methods
8. `equals` / `hashCode` / `toString`
9. Nested classes / enums

### Class Size Guideline

- **Controller:** thin — delegation only, no business logic
- **Service:** focused on one domain aggregate; consider splitting when exceeding ~300 lines
- **Utility:** cohesive utility group; split if methods serve unrelated concerns

---

## Method Design

### Signature

```java
// Good — descriptive name, minimal parameters, returns specific type
UserResponse findById(Long id);

// Bad — vague name, too many params, returns raw entity
User get(long id, String name, boolean active, int page, int size);
```

### Rules

- **Max 3 parameters.** Use a request record for more:
  ```java
  record SearchRequest(String keyword, LocalDate from, LocalDate to, int page, int size) {}
  ```
- **Max 20 lines** body. Extract helper methods for complex logic.
- **Early return / guard clauses** to reduce nesting:
  ```java
  public UserResponse getUser(Long id) {
  if (id == null) throw new IllegalArgumentException("id must not be null");
  User user = userRepository.findById(id)
   .orElseThrow(() -> new ResourceNotFoundException("User", id));
  return UserMapper.toResponse(user);
  }
  ```

---

## Records for DTOs

Prefer `record` over Lombok `@Data` or manual DTOs for immutable data carriers:

```java
public record CreateUserRequest(
  @NotBlank String name,
  @Email String email,
  @Min(0) int age
) {}

public record UserResponse(
  Long id,
  String name,
  String email,
  LocalDate createdAt
) {}
```

### When NOT to use record

- When you need mutable state (builder pattern with JPA entities)
- When you need inheritance (records are implicitly final)
- When JPA entity — use plain class with `@Entity`

---

## Exception Handling

### Hierarchy

```
ResourceNotFoundException    → 404
ValidationException          → 400
BusinessRuleException       → 409 / 422
UnauthorizedException       → 401
ForbiddenException          → 403
```

### Rules

- **Never catch `Exception`** broadly — catch specific exceptions
- **Never swallow exceptions** with empty catch blocks
- **Use `Optional`** instead of returning null or throwing for absent values
- **Wrap checked exceptions** in domain-specific unchecked exceptions when crossing layer boundaries

```java
// Good
public UserResponse findById(Long id) {
  return repository.findById(id)
  .map(UserMapper::toResponse)
  .orElseThrow(() -> new ResourceNotFoundException("User", id));
}

// Bad
public UserResponse findById(Long id) {
  try {
  return UserMapper.toResponse(repository.findById(id).get());
  } catch (Exception e) {
  return null;
  }
}
```

---

## Null Handling

- **Never return null** for collections — return `Collections.emptyList()` or `List.of()`
- **Never pass null** as method arguments — use `Optional` or overloads
- **Use `@Nullable` / `@NonNull`** annotations on API boundaries
- **Prefer `Optional`** as return type for single-value queries that may be absent
- **Do NOT use `Optional`** as method parameter or field type

---

## Modern Java Patterns

### Sealed Classes for Domain Modeling

```java
public sealed interface PaymentResult {
  record Success(String transactionId, BigDecimal amount) implements PaymentResult {}
  record Failed(String errorCode, String message) implements PaymentResult {}
  record Pending(String transactionId) implements PaymentResult {}
}
```

### Pattern Matching for Switch

```java
String describe(Object obj) {
  return switch (obj) {
  case Integer i -> "int: " + i;
  case String s  -> "string: " + s;
  case int[] arr -> "int[" + arr.length + "]";
  case null      -> "null";
  default        -> "unknown";
  };
}
```

### Text Blocks for SQL / JSON

```java
String query = """
  SELECT u.id, u.name, u.email
  FROM users u
  WHERE u.active = true
  AND u.created_at > ?
  ORDER BY u.name
  """;
```

---

## Comments

- **Javadoc on public API** (controller endpoints, service interfaces)
- **No Javadoc on private methods** — the code should be self-documenting
- **No commented-out code** — delete it, git has history
- **Inline comments only for non-obvious WHY**, never WHAT

```java
// Good — explains why, not what
// ISO 8601 basic format required by the legacy payment gateway
private static final DateTimeFormatter GATEWAY_DATE_FORMAT =
  DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

// Bad — restates what the code already says
// Set the name to the provided name
user.setName(name);
```

---

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

- First sentence: imperative mood ("Finds", not "Find" or "This method finds")
- `@param` / `@return` / `@throws` only when they add information beyond the method name
- No `@author` or `@since` tags — git tracks this

---

## Annotations

- **Keep annotations on one line** when there's only one or two
- **One annotation per line** when there are three or more, or when they have parameters

```java
// Compact
@GetMapping("/{id}")
public ResponseEntity<UserResponse> getUser(@PathVariable Long id) { ... }

// Multi-line
@Override
@Transactional(readOnly = true)
@Cacheable(value = "users", key = "#id")
public UserResponse findById(Long id) { ... }
```

---

## Package Organization

```
com.example.myapp/
├── controller/        # @RestController — thin, delegates to service
├── service/           # Business logic interfaces
│   └── impl/          # @Service implementations
├── repository/        # @Repository — Spring Data JPA interfaces
├── model/             # @Entity classes
├── dto/               # Shared DTOs
├── request/           # Inbound request records
├── response/          # Outbound response records
├── handler/           # Global handlers (@RestControllerAdvice)
├── exception/         # Custom exception classes
├── config/            # @Configuration classes
├── mapper/            # MapStruct / manual mappers
└── util/              # Static utility classes (prefer method references first)
```

---

## Prefer Standard Library

| Prefer | Over |
|--------|------|
| `List.of()` / `Map.of()` | `Collections.unmodifiableList()` wrapper |
| `String.isBlank()` | `String.trim().isEmpty()` |
| `Optional.map` / `filter` / `flatMap` | `if (value != null)` chains |
| `Stream` API | `for` loops for transformations |
| `record` | Lombok `@Data`, `@Value` |
| `sealed interface` | Visitor pattern |
| `var` | Explicit type when right-hand side is obvious |
| `interface` default methods | Utility class with static methods |

### Use `var` Judiciously

```java
// Good — type is obvious from right-hand side
var users = userRepository.findAll();
var response = UserMapper.toResponse(user);

// Bad — type is not obvious
var result = process(data);           // what type?
var value = service.compute(thing);   // unclear
```

---

## Serialization

- **Jackson annotations on DTOs/records**, never on JPA entities
- Use `@JsonProperty` for field name mapping, `@JsonInclude` to omit nulls
- Use `@JsonIgnore` to exclude sensitive fields from serialization
- Prefer Java time types (`Instant`, `LocalDateTime`) over `java.util.Date`

---

## Editing Workflow

1. Before editing, identify whether the target is Java source. If not, do not apply these Java-specific rules unless the user asks.
2. Make the requested code change with minimal scope.
3. Normalize only the touched Java code to this style.
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

---

## Related Skills

- `clean-code` — DRY, KISS, YAGNI principles
- `spring-boot-patterns` — Controller / Service / Repository patterns
- `test-quality` — JUnit 5 + AssertJ testing conventions
