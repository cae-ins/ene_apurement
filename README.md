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

> **État au 4 juin 2026**
>
> Le pipeline est désormais opérationnel et stabilisé. Les points bloquants structurels
> identifiés en mai ont été corrigés. Les tests d'intégration montrent que la
> codification des métiers (CITP) et des activités (CIAP) est pleinement
> fonctionnelle pour l'ensemble des sections (Principal, Secondaire, Pluriactivité).
> La variable `CodeCIAPactivité` de l'emploi principal est alimentée par le fichier
> `Codif_activite_principales_T126.xlsx`.
>
> Les sections `S0_identification` et `S15_disponibilite` sont intentionnellement
> exclues de la fusion finale pour le T1 2026, conformément aux décisions métiers.

## Point d'entrée

Le point d'entrée courant est `program/apurement.do`.

L'ordre d'exécution automatisé est le suivant :
1. `00-initialisation_brute_depuis_staging.do` : Réinitialise la copie de travail.
2. `00-suppression_doublons.do` : Retire les entretiens dupliqués identifiés.
3. `00-suppression_non_residents.do` : Retire les non-résidents et synchronise les bases individus et ménages.
4. `00-nettoyage_individus_brute.do` : Retire les individus invalides.
5. `00-codification_brute.do` : Intègre les codes CITP/CIAP (toutes sections) et génère les branches d'activité.
6. `standard_db.do` : Découpe les sections en préservant les codes de nomenclature.
7. `01-INDIV_S...` / `00-QM_S...` : Apurement métier par section.

Avant la standardisation, `00-suppression_non_residents.do` retire les individus
non residents puis synchronise les deux bases : les individus sans menage et les
menages sans individu restant sont retires. Les menages mixtes sont conserves.

Ne pas utiliser les anciens orchestrateurs comme `program/pipeline_master.do` 
ou `program/archive/Fusion_ENE.do`.

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
- les paquets Python `pandas`, `openpyxl` et `xlrd` pour le contrôle des
  fichiers de codification Excel ;
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
$env:ENE_QUARTER = "T1_2026"
```

La convention utilisée dans MinIO est `T<NUMERO>_<ANNEE>`, par exemple
`T1_2026` ou `T2_2026`.

## Préparer un autre trimestre

Créer une copie du dossier d'apurement précédent, puis effectuer les opérations
suivantes avant le premier lancement.

### 1. Déposer ou télécharger le snapshot original

Le dossier `datain/staging` doit contenir l'export original Survey Solutions.

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
global brute_menage_source "$datain_brute/ENEM_T12026.dta"
global brute_menage_work "$datain_brute/QX_EEC_VF.dta"
```

Pour un autre trimestre :

- adapter `folderpath` au nouveau dossier ;
- remplacer `ENEM_T12026.dta` par le vrai nom de l'export ménage Survey
  Solutions du trimestre ;
- conserver `QX_EEC_VF.dta` si les do-files existants gardent ce nom de copie
  de travail.

### 3. Vérifier les scripts métier trimestriels

Examiner les do-files dont le nom contient explicitement un trimestre ou une
année, notamment :

```text
program/Codification_T1_2026.do
program/Suppression_doublon_T1_2026.do
```

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

### Étape 2. Lancer les validations statiques

```powershell
python tools\validate_stata_raw_saves.py
python tools\validate_stata_excel_exports.py
python tools\validate_codification_inputs.py
```

Résultat attendu :

```text
Stata raw-save guard validation: OK
Stata conditional Excel-export guard validation: OK
Codification input validation: OK
```

### Étape 3. Lancer l'apurement dans Stata

Ouvrir le projet Stata, puis exécuter :

```stata
do "C:\chemin\vers\apurement\program\parentfile.do"
do "$dofiles/apurement.do"
```

Les logs de chaque exécution sont sauvegardés dans le dossier `logs/` avec un horodatage. 
Un fichier `.ansi` est également généré, contenant les codes couleurs pour mettre en évidence les erreurs (visualisable dans un terminal compatible ANSI ou VS Code avec l'extension appropriée).

### Étape 4. Examiner les rapports qualité

Les do-files exportent les anomalies dans `document`. Certaines anomalies
nécessitent une correction métier (souvent dans `01-traitrement_autres.do`) 
avant de continuer.

### Étape 5. Contrôler les sorties par section

Avant de lancer la fusion, vérifier la présence des fichiers listés dans la
section [Contrat de sortie avant fusion](#contrat-de-sortie-avant-fusion).

### Étape 6. Lancer la fusion

La commande prévue est :

```stata
do "$dofiles/Fusion.do"
```

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

### Exports Excel conditionnels

Un export filtré doit être précédé d'un comptage :

```stata
count if <condition>
if r(N) > 0 {
    export excel ... if <condition>, firstrow(variables) replace
}
```

## Contrat de sortie avant fusion

`program/Fusion.do` attend les fichiers suivants dans `dataout/standard`.

### Sections ménage

```text
menage/QM_S1_composition_menage.dta
menage/QM_S2_education_formation.dta
menage/QM_S3_formation_professionnelle.dta
menage/QM_S4_immigration.dta
menage/QM_S6_difficultes_fonctionnelles.dta
menage/QM_S7_logement.dta
```

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
```

### Bases finales (fusionnées)

Ces fichiers constituent les sorties principales du pipeline, prêtes pour la pondération.

| Fichier | Localisation | Description | Clé primaire |
| --- | --- | --- | --- |
| `qx_eec_vf.dta` | `dataout/menage/` | Base ménage fusionnée (toutes sections QM) | `interview__key` |
| `membres.dta` | `dataout/individu/` | Base individuelle fusionnée (toutes sections INDIV) | `interview__key`, `membres__id` |

### Rosters annexes (bases complémentaires)

Certaines sections produisent des bases spécifiques qui ne peuvent pas être
fusionnées en `1:1` dans les bases principales car elles contiennent plusieurs
lignes par individu (structures de type "roster").

| Fichier | Section source | Description | Clé primaire |
| --- | --- | --- | --- |
| `Activiteparent.dta` | S14 | Caractéristiques des parents (père, mère, tuteur) | `interview__key`, `membres__id`, `Activiteparent__id` |
| `r_activite_s.dta` | S5 | Détails des activités de pluriactivité | `interview__key`, `membres__id`, `r_activite_s__id` |
| `r_competence_quali.dta` | S4 | Détails des compétences et qualifications | `interview__key`, `membres__id`, `r_competence_quali__id` |
| `r_revenu_h_emp.dta` | S13 | Détails des revenus hors emploi | `interview__key`, `membres__id`, `r_revenu_h_emp__id` |
| `Revenu.dta` | S3 | Détails des revenus de l'emploi principal | `interview__key`, `membres__id`, `Revenu__id` |

Les fichiers de revenus intermédiaires (ex: `Revenu_es.dta`) ne sont pas 
considérés comme des sorties définitives pour la diffusion.

## Historique des corrections récentes (Mai-Juin 2026)

| Point | Correction |
| --- | --- |
| **Codification CIAP** | Intégration du fichier `Codif_activite_principales_T126.xlsx` pour l'emploi principal. Suppression du stub vide. |
| **Section S14 (Parents)** | Séparation stricte entre le roster parental (`dataout/Activiteparent.dta`) et la section individuelle apurée. |
| **Section S6 (Secondaire)** | Refonte complète des filtres d'éligibilité et normalisation des variables `ES*`. |
| **Synchronisation** | `00-suppression_non_residents.do` synchronise désormais les bases ménages et individus avant toute section. |
| **Fusion.do** | Exclusion propre de `S0` et `S15` pour éviter les erreurs de fichiers manquants. |
| **Branches d'activité** | Génération automatique des variables `branche1` et `branche2` dans `00-codification_brute.do`. |

## Dépannage

| Erreur | Cause probable | Vérification ou action |
| --- | --- | --- |
| `r(601)` au démarrage | `datain/staging/membres.dta` absent | Télécharger le snapshot dans `datain/staging` |
| `r(603)` | Échec de `robocopy` ou fichier verrouillé | Lire `datatemp/robocopy_staging_to_brute.log` ou fermer Excel |
| `r(198)` sur `export excel` | Filtre sans observation | Ajouter `count if ...` |
| `r(199)` `violin` unrecognized | Dépendance Stata absente | Exécuter `ssc install violin` |
| `r(601)` dans `Fusion.do` | Section absente | Vérifier si le do-file de section a été exécuté dans `apurement.do` |
