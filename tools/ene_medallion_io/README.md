# ENE medallion I/O

Python scripts for moving ENE files between local Stata/R projects and the
MinIO medallion buckets.

The business pipelines remain in Stata/R. These scripts only handle I/O.

## Local apurement data flow

The apurement project uses two distinct local layers:

```text
datain/staging/  immutable Survey Solutions snapshot
datain/brute/    mutable Stata working copy
```

Stata do-files continue to read and modify `datain/brute/`. Never upload that
working directory as the source snapshot. Restore or download the original
export into `datain/staging/`.

At the start of `program/apurement.do`, Stata runs
`program/00-initialisation_brute_depuis_staging.do`. It mirrors
`datain/staging/` into `datain/brute/` before any business correction.

For manual recovery outside Stata, use
`prepare_apurement_working_copy.py --reset-working-copy`. Without that option,
the utility refuses to overwrite a non-empty `datain/brute/` directory.

Raw working-copy saves in the Stata pipeline must use the guarded helper
programs defined in `program/00-protections_sauvegarde_brute.do`. Validate this
rule without running Stata:

```powershell
python tools\validate_stata_raw_saves.py
python tools\validate_stata_excel_exports.py
```

## Buckets and prefixes

```text
staging/enem/T1_2026/brutes/
staging/enem/T1_2026/codification/
staging/enem/references/

bronze/enem/T1_2026/menage/
bronze/enem/T1_2026/individu/

silver/enem/T1_2026/menage/
silver/enem/T1_2026/individu/
silver/enem/T1_2026/poids/

gold/enem/T1_2026/base_indicateurs/
gold/enem/T1_2026/indicateurs/

silver/enem/annual/2025/poids/
gold/enem/annual/2025/base_indicateurs/
gold/enem/annual/2025/indicateurs/
```

## Credentials

No credentials are stored in this folder.

The scripts read credentials from environment variables:

```powershell
$env:MINIO_ENDPOINT = "http://127.0.0.1:9000"
$env:MINIO_ACCESS_KEY = "..."
$env:MINIO_SECRET_KEY = "..."
```

or from the local test file:

```text
C:\tmp\minio-server\MINIO_LOCAL_CREDENTIALS.txt
```

## Typical commands

From the apurement project root:

```powershell
python tools\ene_medallion_io\00_upload_raw_to_staging.py --quarter T1_2026 --dry-run
python tools\ene_medallion_io\00_upload_raw_to_staging.py --quarter T1_2026
python tools\ene_medallion_io\01_download_apurement_inputs.py --quarter T1_2026 --overwrite
python tools\ene_medallion_io\02_upload_apurement_outputs.py --quarter T1_2026 --dry-run
```

`02_upload_apurement_outputs.py` validates the local apurement output contract
before connecting to MinIO. Missing or empty section files and missing final
household or individual bases stop the upload.

`00_upload_raw_to_staging.py` uploads `datain/staging/` by default.
`01_download_apurement_inputs.py` downloads MinIO staging inputs into
`datain/staging/`. The Stata apurement entry point then resets `datain/brute/`
from this immutable snapshot.

`document/` is not uploaded to `staging/codification` by default. In the ENE
apurement projects it contains Excel observation/error reports produced by
Stata error-identification dofiles. Those files are uploaded by
`02_upload_apurement_outputs.py` to:

```text
silver/enem/{quarter}/quality_reports/apurement_errors/
```

True raw codification or "autres a preciser" files must be passed explicitly
to `00_upload_raw_to_staging.py` with `--codification-dir` or
`--other-raw-file`.

From the weights project root:

```powershell
python path\to\tools\ene_medallion_io\03_download_weights_inputs.py --quarter T1_2026 --base-dir C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS --dry-run
python path\to\tools\ene_medallion_io\04_upload_weights_outputs.py --quarter T1_2026 --base-dir C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS --dry-run
python path\to\tools\ene_medallion_io\04_upload_weights_outputs.py --period annual --year 2025 --base-dir C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS --dry-run
```

For annual weights, the script looks for `LFS_WEIGHTS_{year}.dta` under
`data\04_weights\{year}` or `data\04_weights\{year}\calibrated_weights` and
uploads only that annual LFS file:

```text
silver/enem/annual/{year}/poids/
gold/enem/annual/{year}/base_indicateurs/
```

Household weight helper files under `household_weights\` are not uploaded as
annual gold/silver outputs by this script.

From the tabulation project root:

```powershell
python path\to\tools\ene_medallion_io\05_download_tabulation_inputs.py --quarter T1_2026 --base-dir C:\Users\f.migone\Desktop\ENE_INDICATORS_TABULATIONS --dry-run
python path\to\tools\ene_medallion_io\06_upload_indicator_outputs.py --quarter T1_2026 --base-dir C:\Users\f.migone\Desktop\ENE_INDICATORS_TABULATIONS --dry-run
python path\to\tools\ene_medallion_io\05_download_tabulation_inputs.py --period annual --year 2025 --base-dir C:\Users\f.migone\Desktop\ENE_INDICATORS_TABULATIONS --dry-run
python path\to\tools\ene_medallion_io\06_upload_indicator_outputs.py --period annual --year 2025 --results-dir C:\path\to\annual\outputs --base-dir C:\Users\f.migone\Desktop\ENE_INDICATORS_TABULATIONS --dry-run
```

`06_upload_indicator_outputs.py` excludes `Archive`, `Templates`, `graphs`,
template files, copies, tests, and `2024` files by default. Use
`--include-archives`, `--include-templates`, `--include-graphs`, or
`--include-drafts` only when those files are part of the intended delivery.

For annual tabulations, `05_download_tabulation_inputs.py` downloads from
`gold/enem/annual/{year}/base_indicateurs/`. If no `--target-dir` is supplied,
it writes into `Bulletin_Trimestriel\Base\Base_brute\annual\{year}` so annual
inputs do not overwrite quarterly bases.

For annual indicators, `--results-dir` is required because the annual
publication folder is not yet standardized in the tabulation repository. Without
it, the script only ensures the MinIO prefixes and skips the upload.

Use `--overwrite` only when you intentionally want to replace existing objects.
