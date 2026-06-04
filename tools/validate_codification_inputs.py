"""Validate quarterly CITP/CIAP spreadsheets before running the Stata pipeline."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import unicodedata

import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[1]
CODIFICATION_DIR = BASE_DIR / "document" / "codification"
STAGING_DIR = BASE_DIR / "datain" / "staging"


@dataclass(frozen=True)
class SpreadsheetSpec:
    name: str
    sheet: str
    keys: dict[str, str]
    code_column: str
    staging_file: str


SPECS = (
    SpreadsheetSpec(
        "codification_emploi_principal_T1_2026_cp.xlsx",
        "Sheet1",
        {
            "Interview key (identifier in XX-XX-XX-XX format)": "interview__key",
            "Id in membres": "membres__id",
        },
        "code_citp_emp_principal",
        "membres.dta",
    ),
    SpreadsheetSpec(
        "codification_emploi_secondaire_T1_2026_cp.xlsx",
        "Sheet1",
        {
            "Interview key (identifier in XX-XX-XX-XX format)": "interview__key",
            "Id in membres": "membres__id",
        },
        "code_citp_emp_secondaire",
        "membres.dta",
    ),
    SpreadsheetSpec(
        "codification_autre_emploi_T1_2026_cp.xlsx",
        "Sheet1",
        {
            "Interview key (identifier in XX-XX-XX-XX format)": "interview__key",
            'Id in "membres"': "membres__id",
            "Id in r_activite_s": "r_activite_s__id",
        },
        "code_citp_autre_emploi",
        "r_activite_s.dta",
    ),
    SpreadsheetSpec(
        "Activite_secondaire_T126.xlsx",
        "Feuil1",
        {
            "interview__key": "interview__key",
            "membres__id": "membres__id",
        },
        "Code activite",
        "membres.dta",
    ),
    SpreadsheetSpec(
        "Codif_activite_principales_T126.xlsx",
        "Feuil1",
        {
            "interview__key": "interview__key",
            "membres__id": "membres__id",
        },
        "Code activite",
        "membres.dta",
    ),
    SpreadsheetSpec(
        "Pluriactivite_AllT126.xls",
        "Sheet1",
        {
            "interview__key": "interview__key",
            "membres__id": "membres__id",
            "r_activite_s__id": "r_activite_s__id",
        },
        "Code",
        "r_activite_s.dta",
    ),
)


def normalized_column(name: object) -> str:
    without_marks = "".join(
        char
        for char in unicodedata.normalize("NFKD", str(name))
        if not unicodedata.combining(char)
    )
    return (
        without_marks
        .replace("é", "e")
        .replace("è", "e")
        .replace("ê", "e")
        .replace("à", "a")
        .replace("ù", "u")
        .replace("ï", "i")
    )


def find_column(columns: list[object], expected: str) -> object:
    matches = [column for column in columns if normalized_column(column) == expected]
    if len(matches) != 1:
        raise RuntimeError(f"Expected one column matching {expected!r}, found: {matches!r}")
    return matches[0]


def validate_spec(spec: SpreadsheetSpec, staging_keys: pd.DataFrame) -> None:
    path = CODIFICATION_DIR / spec.name
    if not path.is_file():
        raise RuntimeError(f"Missing codification spreadsheet: {path}")

    frame = pd.read_excel(path, sheet_name=spec.sheet)
    frame = frame.rename(columns=spec.keys)
    keys = list(spec.keys.values())
    missing_keys = [key for key in keys if key not in frame.columns]
    if missing_keys:
        raise RuntimeError(f"{spec.name}: missing key columns after import: {missing_keys}")

    if frame[keys].isna().any(axis=1).any():
        raise RuntimeError(f"{spec.name}: at least one row has an empty key")
    if frame.duplicated(keys).any():
        raise RuntimeError(f"{spec.name}: duplicate key rows detected for {keys}")

    code_column = find_column(list(frame.columns), spec.code_column)
    unmatched = frame[keys].merge(staging_keys, on=keys, how="left", indicator=True)
    unmatched_count = int((unmatched["_merge"] != "both").sum())
    if unmatched_count:
        print(
            f"{spec.name}: WARN ({unmatched_count} key(s) "
            f"do not exist in staging/{spec.staging_file}; Stata drops _merge == 2)"
        )

    missing_codes = int(frame[code_column].isna().sum())
    print(
        f"{spec.name}: OK ({len(frame)} rows, "
        f"{missing_codes} empty value(s) in {code_column!r})"
    )


def main() -> None:
    staging_keys: dict[str, pd.DataFrame] = {}
    for staging_file in {spec.staging_file for spec in SPECS}:
        keys = sorted(
            {
                target
                for spec in SPECS
                if spec.staging_file == staging_file
                for target in spec.keys.values()
            }
        )
        path = STAGING_DIR / staging_file
        if not path.is_file():
            raise RuntimeError(f"Missing staging dataset: {path}")
        staging_keys[staging_file] = pd.read_stata(
            path,
            columns=keys,
            convert_categoricals=False,
        ).drop_duplicates()

    for spec in SPECS:
        validate_spec(spec, staging_keys[spec.staging_file])

    print("Codification input validation: OK")


if __name__ == "__main__":
    main()
