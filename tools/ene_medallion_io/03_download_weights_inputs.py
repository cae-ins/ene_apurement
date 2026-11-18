from __future__ import annotations

import argparse
from pathlib import Path

from ene_minio import add_common_args, connect_from_args, download_prefix


def download_object(
    client,
    bucket: str,
    key: str,
    target: Path,
    *,
    dry_run: bool = False,
    overwrite: bool = False,
) -> None:
    if dry_run:
        print(f"DRY-RUN download s3://{bucket}/{key} -> {target}")
        return
    if target.exists() and not overwrite:
        print(f"skip existing {target}")
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    client.download_file(bucket, key, str(target))
    print(f"downloaded s3://{bucket}/{key} -> {target}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Download ENE weights inputs from silver/staging.")
    add_common_args(parser)
    parser.add_argument("--base-dir", type=Path, default=Path.cwd())
    args = parser.parse_args()

    base_dir = args.base_dir.resolve()
    client = connect_from_args(args)

    download_object(
        client,
        "silver",
        f"enem/{args.quarter}/menage/menage_{args.quarter}.dta",
        base_dir / "data" / "02_cleaned" / "Menage" / args.quarter / f"menage_{args.quarter}.dta",
        dry_run=args.dry_run,
        overwrite=args.overwrite,
    )
    download_object(
        client,
        "silver",
        f"enem/{args.quarter}/individu/membres.dta",
        base_dir / "data" / "02_cleaned" / "Individu" / args.quarter / f"individu_{args.quarter}.dta",
        dry_run=args.dry_run,
        overwrite=args.overwrite,
    )
    download_prefix(
        client,
        "staging",
        f"enem/{args.quarter}/brutes/denombrement",
        base_dir / "data" / "01_raw" / "denombrement" / args.quarter,
        dry_run=args.dry_run,
        overwrite=args.overwrite,
    )
    download_prefix(
        client,
        "staging",
        "enem/references",
        base_dir / "data" / "00_reference",
        dry_run=args.dry_run,
        overwrite=args.overwrite,
    )


if __name__ == "__main__":
    main()
