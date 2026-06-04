ENE_M T1 2026 - apurement Stata

Documentation operationnelle detaillee:

  README.md

Organisation locale des donnees:

  datain/staging : copie immuable de l'export Survey Solutions original
  datain/brute   : copie de travail modifiable par les do-files Stata
  datain/standard: sections standardisees intermediaires
  dataout        : sorties apurees

Ne jamais lancer l'apurement directement sur l'unique copie d'un export brut.
Les do-files existants modifient datain/brute pendant le traitement.

Preparation recommandee:

1. Telecharger l'export Survey Solutions original depuis MinIO vers datain/staging:

   python tools\ene_medallion_io\01_download_apurement_inputs.py --quarter T1_2026 --overwrite

2. Ouvrir ENE_2026T1.stpr dans Stata.
3. Executer program/parentfile.do.
4. Executer program/apurement.do.
5. Executer program/Fusion.do.

program/apurement.do execute automatiquement
program/00-initialisation_brute_depuis_staging.do avant les traitements. Ce
do-file remplace le contenu de datain/brute par le snapshot datain/staging.

Avant la standardisation, program/00-suppression_non_residents.do retire les
individus non residents puis synchronise les bases: aucun individu sans menage
et aucun menage sans individu restant.

Les sauvegardes modifiant les fichiers bruts passent ensuite par
program/00-protections_sauvegarde_brute.do. Ces protections arretent le
pipeline si un roster est sur le point d'ecraser membres.dta, ou inversement.

Les exports Excel conditionnels sont proteges contre l'absence d'observations.
Pour verifier statiquement les protections Stata:

   python tools\validate_stata_raw_saves.py
   python tools\validate_stata_excel_exports.py

Le nom de l'export menage trimestriel est centralise dans program/parentfile.do:

  brute_menage_source : ENEM_T12026.dta, export Survey Solutions restaure
  brute_menage_work   : QX_EEC_VF.dta, copie menage corrigee par l'apurement

Pour reconstruire manuellement la copie de travail hors Stata:

   python tools\ene_medallion_io\prepare_apurement_working_copy.py --reset-working-copy
