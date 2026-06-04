from __future__ import annotations

import argparse
from pathlib import Path

from ene_minio import add_common_args, connect_from_args, ensure_ene_layout, upload_file


REQUIRED_APUREMENT_OUTPUTS = (
    "dataout/menage/qx_eec_vf.dta",
    "dataout/individu/membres.dta",
    "dataout/Activiteparent.dta",
    "dataout/r_activite_s.dta",
    "dataout/r_competence_quali.dta",
    "dataout/r_revenu_h_emp.dta",
    "dataout/Revenu.dta",
)


def validate_output_contract(base_dir: Path) -> None:
    invalid_paths = [
        relative_path
        for relative_path in REQUIRED_APUREMENT_OUTPUTS
        if not (base_dir / relative_path).is_file()
        or (base_dir / relative_path).stat().st_size == 0
    ]
    if invalid_paths:
        formatted_paths = "\n".join(f"  - {path}" for path in invalid_paths)
        raise RuntimeError(
            "Apurement output contract validation failed. "
            "Missing or empty local files:\n"
            f"{formatted_paths}"
        )
    print(f"apurement output contract validation: OK ({len(REQUIRED_APUREMENT_OUTPUTS)} files)")


def upload_output_file(client, base_dir: Path, relative_path: str, bucket: str, key: str, args) -> None:
    upload_file(
        client,
        base_dir / relative_path,
        bucket,
        key,
        dry_run=args.dry_run,
        overwrite=args.overwrite,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Upload ENE apurement final outputs to silver.")
    add_common_args(parser)
    parser.add_argument("--base-dir", type=Path, default=Path.cwd())
    args = parser.parse_args()

    base_dir = args.base_dir.resolve()
    validate_output_contract(base_dir)
    client = connect_from_args(args)
    ensure_ene_layout(client, args.quarter, dry_run=args.dry_run)

    upload_output_file(
        client,
        base_dir,
        "dataout/menage/qx_eec_vf.dta",
        "silver",
        f"enem/{args.quarter}/menage/qx_eec_vf.dta",
        args,
    )
    upload_output_file(
        client,
        base_dir,
        "dataout/individu/membres.dta",
        "silver",
        f"enem/{args.quarter}/individu/membres.dta",
        args,
    )
    for file_name in (
        "Activiteparent.dta",
        "r_activite_s.dta",
        "r_competence_quali.dta",
        "r_revenu_h_emp.dta",
        "Revenu.dta",
    ):
        upload_output_file(
            client,
            base_dir,
            f"dataout/{file_name}",
            "silver",
            f"enem/{args.quarter}/individu/rosters/{file_name}",
            args,
        )

    print("Skipped generated/intermediate outputs: dataout/standard sections, document Excel reports, Revenu_es.dta")


if __name__ == "__main__":
    main()
