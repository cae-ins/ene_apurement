#!/usr/bin/env python3
"""Lanceur MinIO de ENE_APUREMENT (Windows et Linux ; remplace les wrappers PowerShell).

    python scripts/medallion/medallion.py download        --quarter T1_2026 [--dry-run] [--overwrite]
    python scripts/medallion/medallion.py upload-raw      --quarter T1_2026 [--dry-run] [--skip-codification]
    python scripts/medallion/medallion.py upload-outputs  --quarter T1_2026 [--dry-run] [--with-quality-reports]
                                                          [--skip-quarter-check]

download        export Survey Solutions -> datain/staging, codification -> document/codification
upload-raw      publie ces entrées dans staging (objets existants conservés sans --overwrite)
upload-outputs  publie les bases apurées dans silver (liste explicite de produits), après
                contrôle du marqueur dataout/apurement_quarter.txt écrit par Stata

La logique commune (lecture des .env, NO_PROXY, appel des scripts d'E/S) est dans
ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/launcher.py, cherché à côté de ce dépôt
ou dans ENE_ORCHESTRATION_ROOT. Contrat de données : ene_medallion_io/apurement_contract.py.
Le trimestre vient de --quarter, sinon de ENE_QUARTER.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
_orch = Path(os.environ.get("ENE_ORCHESTRATION_ROOT", PROJECT_ROOT.parent / "ENE_MEDALLION_ORCHESTRATION"))
sys.path.insert(0, str(_orch / "ene_medallion_io"))
try:
    from launcher import Command, main  # noqa: E402
except ImportError:
    sys.exit(f"ENE_MEDALLION_ORCHESTRATION introuvable : {_orch} (définir ENE_ORCHESTRATION_ROOT)")

COMMANDS = {
    "download": Command(
        "01_download_apurement_inputs.py",
        "Télécharge les entrées de l'apurement (export Survey Solutions, codification)",
    ),
    "upload-raw": Command(
        "00_upload_raw_to_staging.py",
        "Publie l'export Survey Solutions et la codification du trimestre dans staging",
        flags=("skip-codification",),
    ),
    "upload-outputs": Command(
        "02_upload_apurement_outputs.py",
        "Publie les bases apurées et les rosters dans silver",
        flags=("with-quality-reports", "skip-quarter-check"),
    ),
}

if __name__ == "__main__":
    sys.exit(main(PROJECT_ROOT, COMMANDS, "Lanceur MinIO de ENE_APUREMENT"))
