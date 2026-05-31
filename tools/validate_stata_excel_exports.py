"""Reject conditional Stata Excel exports that can fail on zero observations."""

from __future__ import annotations

import re
import sys
from pathlib import Path


PROGRAM_DIR = Path(__file__).resolve().parents[1] / "program"
EXPORT_RE = re.compile(r"^\s*export\s+excel\b.*\sif\s", re.IGNORECASE)
GUARD_RE = re.compile(r"^if\s+r\(N\)\s*>\s*0\s*\{$", re.IGNORECASE)
DOUBLE_IF_RE = re.compile(r"\bif\s+if\b", re.IGNORECASE)


def iter_active_commands(path: Path) -> list[tuple[int, str]]:
    commands: list[tuple[int, str]] = []
    fragments: list[str] = []
    start_line = 0
    in_block_comment = False

    for line_number, line in enumerate(
        path.read_text(encoding="utf-8").splitlines(), start=1
    ):
        stripped = line.lstrip()

        if in_block_comment:
            if "*/" in line:
                in_block_comment = False
            continue
        if stripped.startswith("/*"):
            if "*/" not in stripped:
                in_block_comment = True
            continue
        if not stripped or stripped.startswith("*") or stripped.startswith("//"):
            continue

        if not fragments:
            start_line = line_number

        continued = line.rstrip().endswith("///")
        fragments.append(line.rstrip()[:-3] if continued else line)

        if not continued:
            commands.append((start_line, " ".join(fragments)))
            fragments = []

    if fragments:
        commands.append((start_line, " ".join(fragments)))

    return commands


def find_unguarded_exports(path: Path) -> list[tuple[int, str]]:
    issues: list[tuple[int, str]] = []
    previous_active = ""

    for line_number, command in iter_active_commands(path):
        if EXPORT_RE.match(command):
            if DOUBLE_IF_RE.search(command):
                issues.append((line_number, f"duplicate if: {command.strip()}"))
            elif not GUARD_RE.fullmatch(previous_active.strip()):
                issues.append((line_number, command.strip()))

        previous_active = command

    return issues


def main() -> int:
    issues: list[str] = []

    for path in sorted(PROGRAM_DIR.glob("*.do")):
        for line_number, line in find_unguarded_exports(path):
            issues.append(f"{path.name}:{line_number}: {line}")

    if issues:
        print("Conditional Stata Excel exports without an r(N)>0 guard:")
        print("\n".join(issues))
        return 1

    print("Stata conditional Excel-export guard validation: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
