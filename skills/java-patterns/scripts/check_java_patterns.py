#!/usr/bin/env python3
"""Heuristic Java style checker for the java-patterns skill.

Checks a small, dependency-free subset of the MarlinL Java style:
- no tabs
- no lines over 120 columns
- no trailing whitespace
- no wildcard imports
- static imports before non-static imports with one blank line between groups
- alphabetic import ordering within static and non-static groups
- common single-line control statements without braces

This script intentionally avoids parsing Java. Treat findings as review hints.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

MAX_COLUMNS = 120
CONTROL_WITHOUT_BRACES = re.compile(
    r"^\s*(if|for|while)\s*\([^;]*\)\s*(?!\s*(?:\{|;|$))(?:[^/].*)$"
)
ELSE_WITHOUT_BRACES = re.compile(r"^\s*else\s+(?!if\b|\s*(?:\{|$)).+")
DO_WITHOUT_BRACES = re.compile(r"^\s*do\s+(?!\s*(?:\{|$)).+")
IMPORT_RE = re.compile(r"^import\s+(static\s+)?([^;]+);\s*$")


def iter_java_files(paths: list[Path]) -> list[Path]:
    files: list[Path] = []
    ignored_dirs = {".git", ".gradle", "build", "target", "out", ".idea"}
    for path in paths:
        if path.is_file() and path.suffix == ".java":
            files.append(path)
        elif path.is_dir():
            for child in path.rglob("*.java"):
                if not any(part in ignored_dirs for part in child.parts):
                    files.append(child)
    return sorted(set(files))


def report(findings: list[str], path: Path, line_no: int | None, message: str) -> None:
    location = f"{path}:{line_no}" if line_no is not None else str(path)
    findings.append(f"{location}: {message}")


def check_imports(path: Path, lines: list[str], findings: list[str]) -> None:
    import_entries: list[tuple[int, bool, str]] = []
    for idx, line in enumerate(lines, start=1):
        match = IMPORT_RE.match(line)
        if match:
            is_static = bool(match.group(1))
            imported = match.group(2).strip()
            import_entries.append((idx, is_static, imported))
            if imported.endswith(".*"):
                report(findings, path, idx, "wildcard import; use explicit imports")

    if not import_entries:
        return

    seen_non_static = False
    for line_no, is_static, _ in import_entries:
        if not is_static:
            seen_non_static = True
        elif seen_non_static:
            report(findings, path, line_no, "static imports must appear before non-static imports")

    static_imports = [(line_no, name) for line_no, is_static, name in import_entries if is_static]
    normal_imports = [(line_no, name) for line_no, is_static, name in import_entries if not is_static]

    for group_name, entries in (("static imports", static_imports), ("imports", normal_imports)):
        names = [name for _, name in entries]
        if names != sorted(names):
            first_line = entries[0][0]
            report(findings, path, first_line, f"{group_name} should be sorted alphabetically")

    if static_imports and normal_imports:
        last_static_line = static_imports[-1][0]
        first_normal_line = normal_imports[0][0]
        between = lines[last_static_line:first_normal_line - 1]
        if between != [""]:
            report(
                findings,
                path,
                first_normal_line,
                "use exactly one blank line between static imports and non-static imports",
            )


def check_file(path: Path) -> list[str]:
    findings: list[str] = []
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()

    blank_run = 0
    in_block_comment = False
    for idx, line in enumerate(lines, start=1):
        if "\t" in line:
            report(findings, path, idx, "tab character; use 2 spaces")
        if len(line) > MAX_COLUMNS:
            report(findings, path, idx, f"line exceeds {MAX_COLUMNS} columns")
        if line.rstrip() != line:
            report(findings, path, idx, "trailing whitespace")

        if line.strip() == "":
            blank_run += 1
            if blank_run > 1:
                report(findings, path, idx, "more than 1 consecutive blank line")
        else:
            blank_run = 0

        stripped = line.strip()
        if "/*" in stripped and "*/" not in stripped:
            in_block_comment = True
        if not in_block_comment and not stripped.startswith("//"):
            if CONTROL_WITHOUT_BRACES.match(line):
                report(findings, path, idx, "control statement appears to omit required braces")
            if ELSE_WITHOUT_BRACES.match(line):
                report(findings, path, idx, "else branch appears to omit required braces")
            if DO_WITHOUT_BRACES.match(line):
                report(findings, path, idx, "do-while body appears to omit required braces")
        if "*/" in stripped:
            in_block_comment = False

    check_imports(path, lines, findings)
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description="Check Java files for java-patterns style hints.")
    parser.add_argument("paths", nargs="+", type=Path, help="Java files or directories to scan")
    args = parser.parse_args()

    files = iter_java_files(args.paths)
    if not files:
        print("No Java files found.")
        return 0

    findings: list[str] = []
    for path in files:
        findings.extend(check_file(path))

    if findings:
        print("Java style findings:")
        for finding in findings:
            print(f"- {finding}")
        return 1

    print(f"No java-patterns findings in {len(files)} Java file(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
