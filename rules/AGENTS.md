# Rules Authoring Guide

Rules are reusable constraints that agents should apply consistently across matching files. Keep them narrow, mechanical, and easy to verify.

## Rule vs Skill Boundary

Put content in a rule when it is:

- A stable constraint that should apply every time matching files are edited
- Mostly mechanical or checkable by review, formatter, linter, script, or simple inspection
- Independent of product context, architecture tradeoffs, or user intent
- Specific enough that two agents should usually make the same edit

Keep content in a skill when it is:

- Design guidance, architecture judgment, or tradeoff analysis
- A workflow that depends on goals, context, risk, or project conventions
- A collection of examples meant to teach a pattern rather than enforce a constraint
- Advice that may be valid in one service, framework, or domain but not another

## Migration Rule

When extracting content from a skill into `rules/`, migrate only the enforceable constraints. Do not copy a whole skill section into a rule just because it is related to the language or domain.

Use this split:

- `rules/*/coding-style.md`: formatting, indentation, blank lines, import order, naming shape, braces, wrapping, member order, comment/Javadoc/annotation style
- `rules/*/testing.md`: test file layout, test naming, assertion style, required test categories, coverage expectations
- `rules/*/security.md`: prohibited secrets, injection prevention, validation requirements, safe error output, dependency audit requirements
- `rules/*/patterns.md`: narrow implementation patterns that are expected locally and can be recognized in code
- Skills: class boundaries, method shape, package architecture, DTO/entity design, immutability tradeoffs, Optional/null modeling, exception hierarchy, serialization strategy, framework architecture

## What Not To Put In Rules

Avoid putting these in rules unless the repository has an explicit, stable, local standard:

- "Prefer records", "prefer sealed types", or other design choices that depend on model semantics
- "Keep services below N lines" or "max N parameters" as hard constraints
- Package layout as a universal requirement across all Java projects
- Framework-specific architecture unless the rule file is framework-specific
- Broad clean-code advice such as DRY/KISS/YAGNI without a concrete enforcement point
- Large tutorial examples that duplicate skill content

## Rule Writing Checklist

Before committing a rule, check:

1. Can this be applied without knowing the feature goal?
2. Can an agent verify it with simple inspection or a tool?
3. Is it stable across most files matched by the frontmatter `paths`?
4. Is it phrased as a constraint, not a lesson?
5. Is the example short and only present to clarify the constraint?
6. Would moving it to a skill preserve useful design judgment?

If the answer to any of the first three questions is "no", keep the content in a skill instead of a rule.

