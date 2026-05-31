# ENE_MEDALLION_ORCHESTRATION

Common orchestration layer for the ENE medallion pipeline.

This repository does not replace the business repositories:

- `ENE_APUREMENT`
- `ENE_SURVEY_WEIGHTS`
- `ENE_INDICATORS_TABULATIONS`

It only centralizes MinIO I/O scripts so the three repositories exchange data
through medallion buckets instead of direct Desktop-to-Desktop copies.

## Local MinIO

Current local test endpoints:

```text
API:     http://127.0.0.1:9000
Console: http://127.0.0.1:9001
```

Local test credentials are expected in:

```text
C:\tmp\minio-server\MINIO_LOCAL_CREDENTIALS.txt
```

Do not commit credentials.

## Buckets

```text
staging
bronze
silver
gold
```

## ENE object layout

```text
staging/enem/{quarter}/brutes/
staging/enem/{quarter}/codification/
staging/enem/references/

bronze/enem/{quarter}/menage/
bronze/enem/{quarter}/individu/

silver/enem/{quarter}/menage/
silver/enem/{quarter}/individu/
silver/enem/{quarter}/poids/

gold/enem/{quarter}/base_indicateurs/
gold/enem/{quarter}/indicateurs/
```

## Typical commands

From any project, prefer the wrappers in `scripts/medallion`.

Direct calls are also possible:

```powershell
python .\ene_medallion_io\00_upload_raw_to_staging.py --quarter T1_2026 --base-dir C:\path\to\ENE_APUREMENT --dry-run
python .\ene_medallion_io\02_upload_apurement_outputs.py --quarter T1_2026 --base-dir C:\path\to\ENE_APUREMENT --dry-run
```

Use `--overwrite` only when replacing existing MinIO objects is intentional.
