from __future__ import annotations

import re
from pathlib import Path


PROGRAM_DIR = Path(__file__).resolve().parents[1] / "program"
GUARD_FILE = "00-protections_sauvegarde_brute.do"
RAW_SAVE = re.compile(r'^\s*save\s+"\$datain_brute[\\/]', re.IGNORECASE)


def active_lines(path: Path):
    in_block_comment = False
    for line_number, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        remaining = line
        while remaining:
            if in_block_comment:
                end = remaining.find("*/")
                if end == -1:
                    remaining = ""
                    continue
                in_block_comment = False
                remaining = remaining[end + 2 :]
                continue

            start = remaining.find("/*")
            if start == -1:
                if not remaining.lstrip().startswith("*"):
                    yield line_number, remaining
                remaining = ""
                continue

            before = remaining[:start]
            if before.strip() and not before.lstrip().startswith("*"):
                yield line_number, before
            in_block_comment = True
            remaining = remaining[start + 2 :]


def main() -> None:
    violations: list[str] = []
    for path in sorted(PROGRAM_DIR.glob("*.do")):
        if path.name == GUARD_FILE:
            continue
        for line_number, line in active_lines(path):
            if RAW_SAVE.search(line):
                violations.append(f"{path}:{line_number}: {line.strip()}")

    if violations:
        print("Direct datain/brute saves must use the guarded Stata helper programs:")
        for violation in violations:
            print(f"- {violation}")
        raise SystemExit(1)

    print("Stata raw-save guard validation: OK")


if __name__ == "__main__":
    main()
