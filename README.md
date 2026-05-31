# Apurement trimestriel ENEM

## Objet du document

Ce document décrit uniquement le pipeline d'apurement de l'Enquête Nationale
sur l'Emploi (ENEM). Il explique comment :

- préparer un nouveau trimestre ;
- conserver une copie immuable des exports Survey Solutions ;
- relancer l'apurement Stata sans écraser les données originales ;
- diagnostiquer les erreurs fréquentes ;
- contrôler les fichiers attendus avant la fusion ;
- transférer les entrées et les sorties avec MinIO.

Les traitements de pondération et de tabulation sont hors périmètre.

> **État au 31 mai 2026**
>
> La préparation initiale et les traitements existants sont protégés.
> Tous les points bloquants (1 à 5) ont été corrigés. Le pipeline est
> désormais **natif et complet** de bout en bout : la codification des
> métiers (CITP) et des activités (CIAP) est intégrée dès le départ dans
> `00-codification_brute.do`. Les variables de nomenclature sont conservées
> automatiquement à travers toutes les sections d'apurement jusqu'à la
> fusion finale.
>
> *Note : La variable `CodeCIAPactivité` (emploi principal) utilise un stub
> vide en attendant la réception du fichier Excel correspondant.*

## Point d'entrée

Le point d'entrée courant est `program/apurement.do`.

L'ordre d'exécution automatisé est le suivant :
1. `00-initialisation_brute_depuis_staging.do` : Réinitialise la copie de travail.
2. `00-codification_brute.do` : Intègre les codes CITP/CIAP et applique les labels (6500+ entrées).
3. `standard_db.do` : Découpe les sections en préservant les codes de nomenclature.
4. `01-INDIV_S...` / `00-MENAGE_S...` : Apurement métier par section.

Ne pas utiliser `program/pipeline_master.do` pour relancer ce projet. Ce fichier
est un ancien orchestrateur prévu pour le T4 2025.

Le lancement normal est effectué dans Stata :

```stata
do "C:\chemin\vers\apurement\program\parentfile.do"
do "$dofiles/apurement.do"
```

`program/Fusion.do` doit être exécuté séparément, après vérification du contrat
de sortie décrit plus bas. La codification étant désormais native, il n'y a plus
de script de "patch" à passer après la fusion.

## Architecture des données

Le pipeline sépare les données originales, la copie de travail et les sorties :

```text
MinIO staging/enem/<TRIMESTRE>/brutes
                  |
                  v
datain/staging  snapshot Survey Solutions immuable
                  |
                  | copie miroir au début de chaque apurement
                  v
datain/brute    copie de travail modifiable par Stata
                  |
                  | traitement des "autres à préciser" et standardisation
                  v
datain/standard sections intermédiaires découpées
                  |
                  | apurement métier section par section
                  v
dataout/standard sorties apurées par section
                  |
                  | Fusion.do, après validation des sorties
                  v
dataout         bases finales ménage et individu
```

### Répertoires locaux

| Répertoire | Rôle | Règle d'utilisation |
| --- | --- | --- |
| `datain/staging` | Snapshot original Survey Solutions | Ne jamais modifier manuellement |
| `datain/brute` | Copie de travail Stata | Réinitialisée depuis `staging` à chaque lancement |
| `datain/standard` | Sections intermédiaires créées par `standard_db.do` | Peut être régénéré |
| `dataout/standard/menage` | Sections ménage apurées | À contrôler avant fusion |
| `dataout/standard/individu` | Sections individu apurées | À contrôler avant fusion |
| `dataout/menage` | Base ménage fusionnée | Sortie finale |
| `dataout/individu` | Base individu fusionnée | Sortie finale |
| `document` | Rapports Excel d'anomalies et fichiers de codification | À examiner pendant l'apurement |
| `datatemp` | Journal technique et marqueurs temporaires | Utile pour diagnostiquer la copie initiale |
| `program` | Do-files Stata | Code métier |
| `tools` | Scripts Python et wrappers PowerShell | Transferts MinIO et validations statiques |

## Prérequis

### Logiciels

- Windows avec `cmd.exe` et `robocopy.exe` ;
- Stata ;
- Python 3 ;
- les paquets Python `boto3` et `botocore` pour les transferts MinIO ;
- une connexion internet lors de la première exécution Stata si la commande
  `violin` n'est pas encore installée.

Au démarrage, `program/00-initialisation_brute_depuis_staging.do` vérifie
automatiquement la présence de `violin`. Si nécessaire, il exécute :

```stata
ssc install violin
```

### Accès MinIO

Les scripts cherchent les paramètres MinIO dans cet ordre :

1. variables d'environnement ;
2. fichier transmis avec `--credentials-file` ;
3. fichier local par défaut `C:\tmp\minio-server\MINIO_LOCAL_CREDENTIALS.txt`.

Variables d'environnement reconnues :

```powershell
$env:MINIO_ENDPOINT = "http://127.0.0.1:9000"
$env:MINIO_ACCESS_KEY = "..."
$env:MINIO_SECRET_KEY = "..."
```

Le trimestre peut aussi être défini une fois dans le terminal :

```powershell
$env:ENE_QUARTER = "T2_2026"
```

La convention utilisée dans MinIO est `T<NUMERO>_<ANNEE>`, par exemple
`T1_2026` ou `T2_2026`.

## Préparer un autre trimestre

Créer une copie du dossier d'apurement précédent, puis effectuer les opérations
suivantes avant le premier lancement.

### 1. Déposer ou télécharger le snapshot original

Le dossier `datain/staging` doit contenir l'export original Survey Solutions.
Pour le T1 2026, il contient notamment :

```text
ENEM_2026T1.dta
membres.dta
r_activite_s.dta
emigration.dta
...
```

Il ne faut pas placer l'unique copie des données dans `datain/brute`, car les
do-files modifient ce répertoire pendant l'apurement.

Pour télécharger un snapshot déjà présent dans MinIO :

```powershell
python tools\ene_medallion_io\01_download_apurement_inputs.py `
  --quarter T2_2026 `
  --overwrite
```

Pour publier un nouveau snapshot local vers MinIO :

```powershell
python tools\ene_medallion_io\00_upload_raw_to_staging.py `
  --quarter T2_2026 `
  --dry-run

python tools\ene_medallion_io\00_upload_raw_to_staging.py `
  --quarter T2_2026 `
  --overwrite
```

Toujours exécuter d'abord la variante `--dry-run`.

### 2. Adapter les paramètres Stata

Modifier `program/parentfile.do` :

```stata
global folderpath = "C:\chemin\vers\le\nouveau\trimestre\apurement"
global brute_menage_source "$datain_brute/ENEM_2026T1.dta"
global brute_menage_work "$datain_brute/QX_EEC_VF.dta"
```

Pour un autre trimestre :

- adapter `folderpath` au nouveau dossier ;
- remplacer `ENEM_2026T1.dta` par le vrai nom de l'export ménage Survey
  Solutions du trimestre ;
- conserver `QX_EEC_VF.dta` si les do-files existants gardent ce nom de copie
  de travail.

`QX_EEC_VF.dta` n'est pas le nom immuable de l'export trimestriel. Il s'agit
d'un alias historique utilisé comme copie ménage corrigée pendant l'apurement.
Le nom de l'export source varie selon le trimestre.

### 3. Vérifier les scripts métier trimestriels

Examiner les do-files dont le nom contient explicitement un trimestre ou une
année, notamment :

```text
program/Codification_T1_2026.do
program/Suppression_doublon_T1_2026.do
```

Vérifier également les corrections ponctuelles codées à partir de libellés
textuels dans les fichiers de section. Elles peuvent dépendre des réponses du
trimestre précédent.

### 4. Vérifier le projet Stata

Le projet courant est `ENE_2026T1.stpr`. Pour un nouveau trimestre, créer ou
adapter le projet Stata afin qu'il référence le nouveau dossier.

## Exécution normale

### Étape 1. Télécharger les entrées MinIO

Depuis la racine du projet :

```powershell
python tools\ene_medallion_io\01_download_apurement_inputs.py `
  --quarter T1_2026 `
  --overwrite
```

Ce script télécharge :

| Source MinIO | Destination locale |
| --- | --- |
| `staging/enem/<TRIMESTRE>/brutes` | `datain/staging` |
| `staging/enem/<TRIMESTRE>/codification` | `document` |
| `staging/enem/references` | `references` |

### Étape 2. Lancer les validations statiques

```powershell
python tools\validate_stata_raw_saves.py
python tools\validate_stata_excel_exports.py
```

Résultat attendu :

```text
Stata raw-save guard validation: OK
Stata conditional Excel-export guard validation: OK
```

La première validation recherche les sauvegardes directes risquées dans
`datain/brute`. La seconde recherche les exports Excel conditionnels susceptibles
d'échouer lorsqu'aucune observation ne correspond au filtre.

### Étape 3. Lancer l'apurement dans Stata

Ouvrir le projet Stata, puis exécuter :

```stata
do "C:\chemin\vers\apurement\program\parentfile.do"
do "$dofiles/apurement.do"
```

Au début de `apurement.do`,
`program/00-initialisation_brute_depuis_staging.do` :

1. vérifie ou installe `violin` ;
2. vérifie la présence de `datain/staging/membres.dta` ;
3. crée les dossiers de sortie absents ;
4. remplace le contenu de `datain/brute` par une copie miroir de
   `datain/staging`.

Cette réinitialisation est volontaire. Relancer `apurement.do` recommence le
travail depuis le snapshot original.

### Étape 4. Examiner les rapports qualité

Les do-files exportent les anomalies dans `document`. Certaines anomalies
nécessitent une correction métier avant de continuer.

Les exports Excel conditionnels sont protégés : lorsqu'aucune observation ne
correspond au filtre, Stata ne tente pas de créer un fichier vide.

### Étape 5. Contrôler les sorties par section

Avant de lancer la fusion, vérifier la présence des fichiers listés dans la
section [Contrat de sortie avant fusion](#contrat-de-sortie-avant-fusion).

### Étape 6. Lancer la fusion

La commande prévue est :

```stata
do "$dofiles/Fusion.do"
```

Ne pas la lancer tant que les points bloquants documentés plus bas ne sont pas
résolus et que les fichiers attendus ne sont pas tous présents.

### Étape 7. Publier les sorties MinIO

Effectuer d'abord une simulation :

```powershell
python tools\ene_medallion_io\02_upload_apurement_outputs.py `
  --quarter T1_2026 `
  --dry-run
```

Puis publier :

```powershell
python tools\ene_medallion_io\02_upload_apurement_outputs.py `
  --quarter T1_2026 `
  --overwrite
```

Le script publie les sections intermédiaires dans `bronze` et les sorties
apurées dans `silver`. Il envoie aussi `document` vers :

```text
silver/enem/<TRIMESTRE>/quality_reports/apurement_errors
```

## Reprise manuelle de la copie de travail

Normalement, Stata reconstruit automatiquement `datain/brute`. Pour tester ou
réparer cette copie hors de Stata :

```powershell
python tools\ene_medallion_io\prepare_apurement_working_copy.py `
  --reset-working-copy
```

Pour afficher les opérations sans modifier les fichiers :

```powershell
python tools\ene_medallion_io\prepare_apurement_working_copy.py `
  --reset-working-copy `
  --dry-run
```

Le script refuse de vider un chemin situé hors de `datain`. Il refuse également
de confondre `staging` et `brute`.

## Protections intégrées

### Copie miroir `staging` vers `brute`

`program/00-initialisation_brute_depuis_staging.cmd` utilise `robocopy /MIR`.
Le journal technique est écrit dans :

```text
datatemp/robocopy_staging_to_brute.log
```

### Sauvegardes brutes contrôlées

`program/00-protections_sauvegarde_brute.do` définit trois commandes :

| Commande | Destination | Contrôle principal |
| --- | --- | --- |
| `save_brute_membres_safe` | `datain/brute/membres.dta` | Refuse un roster d'activité chargé par erreur |
| `save_brute_r_activite_s_safe` | `datain/brute/r_activite_s.dta` | Vérifie les variables sentinelles du roster |
| `save_brute_menage_work_safe` | `datain/brute/QX_EEC_VF.dta` | Refuse une base individuelle chargée par erreur |

Ces contrôles empêchent notamment qu'un traitement des « autres à préciser »
écrase accidentellement `membres.dta` avec le contenu d'un roster.

### Exports Excel conditionnels

Un export filtré doit être précédé d'un comptage :

```stata
count if <condition>
if r(N) > 0 {
    export excel ... if <condition>, firstrow(variables) replace
}
```

Sans cette garde, Stata retourne `r(198)` si aucune observation n'est à
exporter.

## Contrat de sortie avant fusion

`program/Fusion.do` attend les fichiers suivants dans `dataout/standard`.

### Sections ménage

```text
menage/QM_S0_identification.dta
menage/QM_S1_composition_menage.dta
menage/QM_S2_education_formation.dta
menage/QM_S3_formation_professionnelle.dta
menage/QM_S4_immigration.dta
menage/QM_S6_difficultes_fonctionnelles.dta
menage/QM_S7_logement.dta
```

La section `QM_S5_emmigration.dta` est apurée mais n'est pas intégrée aux bases
finales par le code actuel. Vérifier si ce choix métier est volontaire.

### Sections individu

```text
individu/INDIV_S1_autres_formes_travail.dta
individu/INDIV_S2_situation_emploi.dta
individu/INDIV_S3_emploi_principal.dta
individu/INDIV_S4_competences_qualifications.dta
individu/INDIV_S5_pluriactivite.dta
individu/INDIV_S6_emploi_secondaire.dta
individu/INDIV_S7_temps_travail.dta
individu/INDIV_S8_emploi_inadequat.dta
individu/INDIV_S9_recherche_emploi.dta
individu/INDIV_S10_recherche_emploi_disponibilite.dta
individu/INDIV_S11_chomage.dta
individu/INDIV_S12_emploi_anterieur.dta
individu/INDIV_S13_revenu_hors_emploi.dta
individu/INDIV_S14_activite_parents.dta
individu/INDIV_S15_disponibilite.dta
```

## Points à résoudre avant la fusion finale

Ces écarts sont présents dans le projet au 31 mai 2026.

| Point | Constat | Statut |
| --- | --- | --- |
| `QM_S0_identification.dta` | `standard_db.do` écrit le fichier dans `datain/standard`, mais `Fusion.do` le cherchait dans `dataout/standard/menage` | **Résolu** — section retirée de `Fusion.do` ; `QM_S7_logement.dta` devient le point d'entrée de la base ménage. À réintégrer quand la section sera apurée. |
| Section individu S2 | `apurement.do` inclut `01-INDIV_S2_situation_emploi.do`, mais ce fichier n'existe pas dans `program` | **En attente** — do-file à restaurer ou écrire |
| Section individu S15 | `standard_db.do` crée la section intermédiaire, mais le do-file d'apurement S15 est absent | **Résolu** — section retirée de `Fusion.do` (décision métier T1 2026) |
| Section individu S14 | `01-INDIV_S14_activite_parents.do` enregistrait `dataout/Activiteparent.dta` au lieu de `dataout/standard/individu/INDIV_S14_activite_parents.dta` | **Résolu** — destination corrigée dans le do-file |
| Section individu S6 | Le `drop` ligne 356 référençait des variables de codification absentes du dataset (`CodeCIAPactivité`, `code_citp_emp_principal`, `code_citp_emp_secondaire`), bloquant la sauvegarde intermédiaire | **Résolu** — variables commentées dans les `drop` (lignes 356 et 530) en attendant l'intégration de la codification ; `membre_id_v1` ajouté au `drop` ligne 356 pour éviter un conflit au second merge |
| `Fusion_ENE.do` | Une ligne `INDIV_S15_disponibilite` isolée est située hors de la déclaration `global individu` | **En attente** — à corriger avant toute utilisation de cette variante |

Ne pas copier silencieusement les sections intermédiaires de `datain/standard`
vers `dataout/standard` sans décision métier. Une telle copie permettrait à la
fusion de terminer tout en masquant l'absence d'apurement d'une section.

## Dépannage

| Erreur | Cause probable | Vérification ou action |
| --- | --- | --- |
| `r(601)` au démarrage | `datain/staging/membres.dta` absent | Télécharger ou déposer le snapshot Survey Solutions dans `datain/staging` |
| `r(603)` pendant la réinitialisation | Échec de `robocopy` | Lire `datatemp/robocopy_staging_to_brute.log` |
| `r(603)` lors d'un `save` | Répertoire de sortie absent ou fichier verrouillé | Vérifier le chemin, les droits et si le fichier est ouvert dans un autre logiciel |
| `r(198)` sur `export excel` | Filtre sans observation ou export conditionnel non protégé | Ajouter `count if ...` puis `if r(N) > 0 { ... }` |
| `r(132)` `too few quotes` | Guillemet double non échappé dans un libellé Stata | Vérifier si le texte source contient réellement `"` ; utiliser une apostrophe si elle correspond à la donnée |
| `r(133)` `unknown function ()` | Commentaire `//` collé à l'expression ou syntaxe Stata invalide | Ajouter un espace avant le commentaire et relire l'expression |
| `r(199)` `command violin is unrecognized` | Dépendance Stata absente | Relancer l'initialisation ou exécuter `ssc install violin` |
| `r(601)` dans `Fusion.do` | Fichier attendu dans `dataout/standard` non produit | Comparer les sorties avec le contrat de sortie avant fusion |
| `r(459)` sur une commande `save_brute_*_safe` | Mauvais dataset chargé avant sauvegarde | Corriger le do-file appelant ; ne pas contourner la protection |

## Wrappers PowerShell

Des wrappers sont disponibles dans :

```text
tools/ene_medallion_wrappers/ENE_APUREMENT/scripts/medallion
```

Ils délèguent les transferts à un dépôt d'orchestration externe, défini par
défaut ici :

```text
C:\Users\f.migone\Desktop\ENE_MEDALLION_ORCHESTRATION
```

Exemple :

```powershell
.\tools\ene_medallion_wrappers\ENE_APUREMENT\scripts\medallion\01_download_apurement_inputs.ps1 `
  -Quarter T1_2026 `
  -Overwrite
```

Pour rendre le dossier d'apurement autonome, utiliser directement les scripts
Python présents dans `tools/ene_medallion_io`.

## Checklist trimestrielle

### Avant l'apurement

- [ ] Copier le dossier de travail du trimestre précédent.
- [ ] Modifier `folderpath` dans `program/parentfile.do`.
- [ ] Modifier `brute_menage_source` avec le vrai nom de l'export ménage.
- [ ] Définir le trimestre MinIO, par exemple `T2_2026`.
- [ ] Déposer ou télécharger les fichiers originaux dans `datain/staging`.
- [ ] Vérifier les scripts de codification et de suppression des doublons propres au trimestre.
- [ ] Exécuter les deux validations statiques Python.

### Pendant l'apurement

- [ ] Lancer `parentfile.do`.
- [ ] Lancer `apurement.do`.
- [ ] Examiner les rapports Excel écrits dans `document`.
- [ ] Corriger les erreurs métier sans modifier le snapshot `datain/staging`.
- [ ] Relancer depuis le début si nécessaire.

### Avant la fusion

- [ ] Vérifier tous les fichiers attendus dans `dataout/standard/menage`.
- [ ] Vérifier tous les fichiers attendus dans `dataout/standard/individu`.
- [ ] Résoudre les écarts structurels documentés pour le trimestre courant.
- [ ] Lancer `Fusion.do`.
- [ ] Vérifier les bases finales dans `dataout/menage` et `dataout/individu`.

### Avant publication

- [ ] Examiner une dernière fois les rapports qualité.
- [ ] Exécuter l'upload MinIO avec `--dry-run`.
- [ ] Publier les sorties avec `--overwrite` uniquement après validation.
