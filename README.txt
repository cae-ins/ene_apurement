ENE_M - apurement Stata

Documentation operationnelle detaillee : README.md

Code, donnees et calcul sont separes :
  - le code est dans ce depot git, sans chemin propre au poste ;
  - les donnees viennent de MinIO et y retournent ;
  - le calcul tourne sur tout poste avec Stata et Python.

Organisation locale des donnees (ignoree par git) :

  datain/staging        : copie immuable de l'export Survey Solutions original
  datain/brute          : copie de travail modifiable par les do-files Stata
  datain/standard       : sections standardisees intermediaires
  document/codification : classeurs de codification CITP/CIAP du trimestre
  dataout               : sorties apurees

Ne jamais lancer l'apurement directement sur l'unique copie d'un export brut.
Les do-files existants modifient datain/brute pendant le traitement.

Procedure (depuis la racine du depot, ENE_MEDALLION_ORCHESTRATION clone a cote) :

  set ENE_QUARTER=T1_2026
  set STATA_EXE=C:\chemin\vers\StataMP-64.exe

  1. python scripts\medallion\medallion.py download --dry-run
     python scripts\medallion\medallion.py download --overwrite
  2. python tools\run_apurement.py check
  3. python tools\run_apurement.py apurement
  4. examiner les rapports Excel de document\
  5. python tools\run_apurement.py fusion
  6. python scripts\medallion\medallion.py upload-outputs --dry-run
     python scripts\medallion\medallion.py upload-outputs --overwrite

En interactif dans Stata, apres cd vers la racine du depot :

  do "program/parentfile.do"
  do "$dofiles/apurement.do"

program/parentfile.do prend la racine dans ENE_BASE_DIR, sinon dans le
repertoire courant (racine du depot ou program/), et le trimestre dans
ENE_QUARTER. L'export menage Survey Solutions est ENEM_<TX><ANNEE>.dta
(ENEM_T12026.dta pour T1_2026), ou le nom donne par ENE_MENAGE_EXPORT ;
QX_EEC_VF.dta est la copie menage corrigee par l'apurement.

program/apurement.do execute d'abord
program/00-initialisation_brute_depuis_staging.do, qui remplace le contenu de
datain/brute par le snapshot datain/staging, vide dataout et y ecrit le
trimestre traite (dataout/apurement_quarter.txt).

Pour reconstruire manuellement la copie de travail hors Stata :

   python tools\prepare_apurement_working_copy.py --reset-working-copy
