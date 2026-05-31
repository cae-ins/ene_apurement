from __future__ import annotations

import argparse
import shutil
import stat
from pathlib import Path


def relative_or_absolute(base_dir: Path, path: Path | None, default: Path) -> Path:
    candidate = path or default
    if not candidate.is_absolute():
        candidate = base_dir / candidate
    return candidate.resolve()


def assert_safe_layout(base_dir: Path, staging_dir: Path, raw_dir: Path) -> None:
    datain_dir = (base_dir / "datain").resolve()
    if staging_dir == raw_dir:
        raise RuntimeError("The staging and raw working directories must be different.")
    if not raw_dir.is_relative_to(datain_dir):
        raise RuntimeError(f"Refusing to manage a raw directory outside {datain_dir}: {raw_dir}")
    if raw_dir == datain_dir:
        raise RuntimeError(f"Refusing to reset the datain directory itself: {raw_dir}")
    if staging_dir.is_relative_to(raw_dir) or raw_dir.is_relative_to(staging_dir):
        raise RuntimeError("The staging and raw working directories must not contain each other.")


def list_files(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*") if path.is_file())


def make_writable(path: Path) -> None:
    path.chmod(path.stat().st_mode | stat.S_IWRITE)


def remove_working_copy_contents(raw_dir: Path) -> None:
    for path in reversed(list_files(raw_dir)):
        make_writable(path)
        path.unlink()
    directories = sorted(
        (path for path in raw_dir.rglob("*") if path.is_dir()),
        key=lambda path: len(path.parts),
        reverse=True,
    )
    for path in directories:
        make_writable(path)
        path.rmdir()


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Prepare the mutable datain/brute Stata working copy from the immutable "
            "datain/staging Survey Solutions snapshot."
        )
    )
    parser.add_argument("--base-dir", type=Path, default=Path.cwd())
    parser.add_argument("--staging-dir", type=Path, default=None)
    parser.add_argument("--raw-dir", type=Path, default=None)
    parser.add_argument(
        "--reset-working-copy",
        action="store_true",
        help="Delete the existing raw working copy before copying staging files.",
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    base_dir = args.base_dir.resolve()
    staging_dir = relative_or_absolute(base_dir, args.staging_dir, Path("datain") / "staging")
    raw_dir = relative_or_absolute(base_dir, args.raw_dir, Path("datain") / "brute")
    assert_safe_layout(base_dir, staging_dir, raw_dir)

    if not staging_dir.exists() or not staging_dir.is_dir():
        raise RuntimeError(
            f"Missing immutable staging directory: {staging_dir}. "
            "Restore or download the original Survey Solutions export first."
        )

    staging_files = list_files(staging_dir)
    if not staging_files:
        raise RuntimeError(f"The immutable staging directory is empty: {staging_dir}")

    existing_files = list_files(raw_dir) if raw_dir.exists() else []
    if existing_files and not args.reset_working_copy:
        raise RuntimeError(
            f"Raw working copy is not empty: {raw_dir}. "
            "Pass --reset-working-copy to intentionally rebuild it from staging."
        )

    if raw_dir.exists() and args.reset_working_copy:
        if args.dry_run:
            print(f"DRY-RUN clear mutable working copy {raw_dir}")
        else:
            remove_working_copy_contents(raw_dir)

    if not args.dry_run:
        raw_dir.mkdir(parents=True, exist_ok=True)

    for source in staging_files:
        relative_path = source.relative_to(staging_dir)
        target = raw_dir / relative_path
        if args.dry_run:
            print(f"DRY-RUN copy {source} -> {target}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        print(f"copied {relative_path}")

    verb = "would copy" if args.dry_run else "copied"
    print(f"{verb} {len(staging_files)} file(s) from {staging_dir} to {raw_dir}")


if __name__ == "__main__":
    main()
