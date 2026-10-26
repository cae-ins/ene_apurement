# Apurement trimestriel ENEM

## Objet du document

Ce document décrit uniquement le pipeline d'apurement de l'Enquête Nationale
sur l'Emploi (ENEM). Il explique comment :

- refaire l'apurement d'un trimestre sur n'importe quel poste à partir du dépôt
  git et d'un accès à MinIO ;
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

## Code, données et calcul séparés

- **Code** : ce dépôt git. Aucun chemin propre à un poste n'y est écrit :
  `program/parentfile.do` prend la racine du dépôt dans `ENE_BASE_DIR` ou, à
  défaut, dans le répertoire courant de Stata (racine du dépôt ou `program/`).
- **Données** : MinIO. Les entrées sont téléchargées dans `datain/staging/` et
  `document/codification/`, les sorties sont publiées depuis `dataout/`. Les
  dossiers de données sont ignorés par git.
- **Calcul** : n'importe quel poste avec Stata et Python. Les échanges avec MinIO
  passent par `scripts/medallion/medallion.py`, Stata peut être lancé sans
  intervention par `tools/run_apurement.py`.

Les scripts d'échange avec MinIO sont ceux du dépôt
`ENE_MEDALLION_ORCHESTRATION` (source unique), cloné à côté de ce dépôt ou
désigné par `ENE_ORCHESTRATION_ROOT`. Le contrat de données de l'apurement
(chaque fichier lu ou publié, son emplacement MinIO et sa place locale) y est
décrit par `ene_medallion_io/apurement_contract.py` ; il est résumé
[plus bas](#contrat-de-données).

> **Intégration en cours.** Tant que `apurement_contract.py` et les nouvelles
> versions de `00/01/02` ne sont pas dans `ENE_MEDALLION_ORCHESTRATION`, la
> commande `download` appelle l'ancien `01_download_apurement_inputs.py`, qui
> écrit dans `datain/Base_brute/` et `document/` au lieu de `datain/staging/` et
> `document/codification/`. La copie transitoire `tools/ene_medallion_io/`
> (00, 01, 02, 03, `ene_minio.py`) reste en place jusque-là ; elle sera retirée
> après l'intégration.

## Point d'entrée

Le point d'entrée courant est `program/apurement.do`.

L'ordre d'exécution automatisé est le suivant :
1. `00-initialisation_brute_depuis_staging.do` : Réinitialise la copie de travail et écrit le trimestre traité dans `dataout/apurement_quarter.txt`.
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
ou `program/archive/Fusion_ENE.do` (archives restées dans le dossier OneDrive
du T1 2026, hors dépôt).

Lancement sans intervention, depuis la racine du dépôt :

```powershell
$env:STATA_EXE = "C:\chemin\vers\StataMP-64.exe"
python tools\run_apurement.py apurement --quarter T1_2026
```

Lancement interactif dans Stata, après `cd` vers la racine du dépôt (ou ouverture
du projet `ENE_2026T1.stpr`, dont les chemins sont relatifs) :

```stata
do "program/parentfile.do"
do "$dofiles/apurement.do"
```

`program/Fusion.do` doit être exécuté séparément, après vérification du contrat
de sortie décrit plus bas (`python tools\run_apurement.py fusion`, ou
`do "$dofiles/Fusion.do"`). La codification étant désormais native, il n'y a plus
de script de "patch" à passer après la fusion.

## Architecture des données

Le pipeline sépare les données originales, la copie de travail et les sorties :

```text
MinIO staging/enem/<TRIMESTRE>/brutes/<fichier>   staging/enem/<TRIMESTRE>/codification/
                  |                                          |
                  v                                          v
datain/staging  snapshot Survey Solutions immuable   document/codification
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
dataout         bases finales ménage et individu, rosters
                  |
                  v
MinIO silver/enem/<TRIMESTRE>/menage/menage_<TRIMESTRE>.dta, individu/...
```

### Répertoires locaux

| Répertoire | Rôle | Règle d'utilisation |
| --- | --- | --- |
| `datain/staging` | Snapshot original Survey Solutions | Téléchargé depuis MinIO ; ne jamais modifier manuellement |
| `datain/brute` | Copie de travail Stata | Réinitialisée depuis `staging` à chaque lancement |
| `datain/standard` | Sections intermédiaires créées par `standard_db.do` | Peut être régénéré |
| `dataout/standard/menage` | Sections ménage apurées | À contrôler avant fusion |
| `dataout/standard/individu` | Sections individu apurées | À contrôler avant fusion |
| `dataout/menage` | Base ménage fusionnée | Sortie finale |
| `dataout/individu` | Base individu fusionnée | Sortie finale |
| `document` | Rapports Excel d'anomalies | À examiner pendant l'apurement |
| `document/codification` | Fichiers de codification CITP/CIAP du trimestre | Téléchargés depuis MinIO |
| `datatemp` | Journal technique, marqueurs temporaires, journaux batch | Utile pour diagnostiquer la copie initiale |
| `logs` | Journaux de session Stata (`.log`, `.ansi`) | Un fichier horodaté par lancement |
| `program` | Do-files Stata | Code métier |
| `scripts/medallion` | Lanceur MinIO `medallion.py` | Échanges avec MinIO |
| `tools` | Lanceur Stata, contrôles statiques, utilitaires Python | Voir ci-dessous |

## Prérequis

### Logiciels

- Windows avec `cmd.exe` et `robocopy.exe` (copie `staging` vers `brute`) ;
- Stata (17 ou plus) ;
- Python 3.10 ou plus ;
- les paquets Python `boto3` et `botocore` pour les transferts MinIO ;
- les paquets Python `pandas`, `openpyxl` et `xlrd` pour le contrôle des
  fichiers de codification Excel ;
- le dépôt `ENE_MEDALLION_ORCHESTRATION` cloné à côté de ce dépôt ;
- une connexion internet lors de la première exécution Stata si la commande
  `violin` n'est pas encore installée.

Au démarrage, `program/00-initialisation_brute_depuis_staging.do` vérifie
automatiquement la présence de `violin`. Si nécessaire, il exécute :

```stata
ssc install violin
```

### Variables d'environnement

| Variable | Utilisée par | Rôle |
| --- | --- | --- |
| `ENE_QUARTER` | Stata, lanceurs | Trimestre traité, forme `T<NUMERO>_<ANNEE>` (ex. `T1_2026`) ; défaut `T1_2026` |
| `ENE_BASE_DIR` | Stata | Racine du dépôt (facultatif : par défaut le répertoire courant) |
| `ENE_MENAGE_EXPORT` | Stata, contrat | Nom de l'export ménage Survey Solutions s'il ne suit pas `ENEM_<TX><ANNEE>.dta` (T1_2026 donne `ENEM_T12026.dta`) |
| `STATA_EXE` | `tools/run_apurement.py` | Chemin de l'exécutable Stata |
| `ENE_ORCHESTRATION_ROOT` | `medallion.py` | Dépôt d'orchestration, par défaut `../ENE_MEDALLION_ORCHESTRATION` |
| `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY` | scripts MinIO | Accès MinIO |
| `ENE_CREDENTIALS_FILE`, `ENE_SECRETS_DIR` | scripts MinIO | Fichier d'identifiants à utiliser à la place des variables |

`medallion.py` lit aussi les fichiers `.env` du répertoire courant, de ce dépôt
et du dépôt d'orchestration, sans écraser une variable déjà définie. Le `.env`
est ignoré par git ; ne jamais écrire d'identifiant dans le code ni dans la
documentation. Exemple :

```text
MINIO_ENDPOINT=http://<serveur-minio>:9000
MINIO_ACCESS_KEY=...
MINIO_SECRET_KEY=...
ENE_QUARTER=T1_2026
STATA_EXE=C:\chemin\vers\StataMP-64.exe
```

## Contrat de données

Source : `ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/apurement_contract.py`.

### Entrées (téléchargées par `medallion.py download`)

| Fichier local | MinIO | Statut |
| --- | --- | --- |
| `datain/staging/ENEM_<TX><ANNEE>.dta` | `staging/enem/<T>/brutes/ENEM_<TX><ANNEE>.dta` | obligatoire (export ménage ; nom réglable par `ENE_MENAGE_EXPORT`) |
| `datain/staging/membres.dta` | `staging/enem/<T>/brutes/membres.dta` | obligatoire |
| `datain/staging/r_activite_s.dta`, `emigration.dta`, `r_revenu_h_emp.dta`, `r_competence_quali.dta`, `Activiteparent.dta`, `Revenu.dta`, `Revenu_es.dta` | `staging/enem/<T>/brutes/<fichier>` | obligatoires (lus par les do-files) |
| `datain/staging/assignment__actions.dta`, `couts_biens.dta`, `disponibilite.dta`, `interview__*.dta`, `VISITE_IND.dta`, `VISITE_ROOSTER.dta` | `staging/enem/<T>/brutes/<fichier>` | facultatifs (non lus ; gardés pour un snapshot complet) |
| `document/codification/*` | `staging/enem/<T>/codification/` | obligatoire (dossier non vide) |

Le préfixe `staging/enem/<T>/brutes/` contient aussi le dénombrement
(`denombrement/`, `denombrement_update/`), qui appartient à la pondération :
l'export Survey Solutions est donc listé fichier par fichier et le préfixe n'est
jamais téléchargé en entier.

Les noms des classeurs de codification attendus par `00-codification_brute.do`
et `tools/validate_codification_inputs.py` sont propres au trimestre (ex.
`codification_emploi_principal_T1_2026_cp.xlsx`, `Activite_secondaire_T126.xlsx`).

### Produits publiés (`medallion.py upload-outputs`)

Liste explicite ; rien d'autre n'est publié (ni les sections de
`dataout/standard`, ni `datain/standard`, ni `Revenu_es.dta`).

| Fichier local | MinIO |
| --- | --- |
| `dataout/menage/qx_eec_vf.dta` | `silver/enem/<T>/menage/menage_<T>.dta` |
| `dataout/individu/membres.dta` | `silver/enem/<T>/individu/individu_<T>.dta` |
| `dataout/Activiteparent.dta`, `r_activite_s.dta`, `r_competence_quali.dta`, `r_revenu_h_emp.dta`, `Revenu.dta` | `silver/enem/<T>/individu/rosters/<fichier>` |
| `document/*.xls`, `document/*.xlsx` (avec `--with-quality-reports`) | `silver/enem/<T>/quality_reports/apurement_errors/` |

Les deux bases fusionnées sont les entrées de la pondération
(`weights_contract.cleaned_survey`). Avant tout envoi, le script vérifie que les
sept produits existent et ne sont pas vides, et que `dataout/apurement_quarter.txt`
(écrit par Stata au début de l'apurement) indique le trimestre demandé. Un
manifeste (fichiers envoyés, commit git du code) est écrit dans
`silver/enem/<T>/_manifests/`.

### Entrées publiées par l'apurement (`medallion.py upload-raw`)

L'apurement est propriétaire de l'export Survey Solutions et des fichiers de
codification de son trimestre. `upload-raw` publie les fichiers du tableau des
entrées présents dans `datain/staging/` et `document/codification/` ; les
objets déjà présents sur MinIO sont conservés sauf `--overwrite`.

## Procédure pour un trimestre

### Sur un poste neuf

```powershell
git clone <url>/ENE_APUREMENT.git
git clone <url>/ENE_MEDALLION_ORCHESTRATION.git
python -m pip install boto3 pandas openpyxl xlrd
cd ENE_APUREMENT
# créer .env (voir plus haut), puis :
$env:ENE_QUARTER = "T1_2026"
```

### Étape 1. Télécharger les entrées MinIO

```powershell
python scripts\medallion\medallion.py download --dry-run
python scripts\medallion\medallion.py download --overwrite
```

L'essai à blanc liste ce qui serait téléchargé et les entrées obligatoires
absentes de MinIO (code de retour 1 dans ce cas).

### Étape 2. Lancer les validations statiques

```powershell
python tools\run_apurement.py check
```

Résultat attendu :

```text
Stata raw-save guard validation: OK
Stata conditional Excel-export guard validation: OK
Codification input validation: OK
```

### Étape 3. Lancer l'apurement

```powershell
python tools\run_apurement.py config      # vérifie la racine, le trimestre et les chemins
python tools\run_apurement.py apurement
```

Les logs de chaque exécution sont sauvegardés dans le dossier `logs/` avec un horodatage.
Un fichier `.ansi` est également généré, contenant les codes couleurs pour mettre en évidence les erreurs (visualisable dans un terminal compatible ANSI ou VS Code avec l'extension appropriée).
Le journal du lanceur est dans `datatemp/batch/`. Sous Windows, le lanceur ouvre Stata
en mode interactif (fenêtre réduite) et non en mode batch (`/e`) : en batch, Stata
ignore `shell`, donc la copie `datain/staging` vers `datain/brute` (robocopy) ne se
fait pas et l'initialisation s'arrête en `r(603)`. Stata se ferme seul à la fin et le
code retour est écrit dans `datatemp/batch/run_<étape>.rc`.

### Étape 4. Examiner les rapports qualité

Les do-files exportent les anomalies dans `document`. Certaines anomalies
nécessitent une correction métier (souvent dans `01-traitrement_autres.do`)
avant de continuer.

### Étape 5. Contrôler les sorties par section

Avant de lancer la fusion, vérifier la présence des fichiers listés dans la
section [Contrat de sortie avant fusion](#contrat-de-sortie-avant-fusion).

### Étape 6. Lancer la fusion

```powershell
python tools\run_apurement.py fusion
```

### Étape 7. Publier les sorties MinIO

```powershell
python scripts\medallion\medallion.py upload-outputs --dry-run
python scripts\medallion\medallion.py upload-outputs --overwrite
```

Toujours exécuter d'abord la variante `--dry-run`. `--skip-quarter-check` permet
de publier des sorties produites avant l'existence du marqueur de trimestre
(uniquement si elles sont bien celles du trimestre demandé).

### Préparer un nouveau trimestre

1. Publier l'export Survey Solutions original et la codification du trimestre :
   les placer dans `datain/staging/` et `document/codification/`, puis

   ```powershell
   python scripts\medallion\medallion.py upload-raw --quarter T2_2026 --dry-run
   python scripts\medallion\medallion.py upload-raw --quarter T2_2026
   ```

   Il ne faut pas placer l'unique copie des données dans `datain/brute`, car les
   do-files modifient ce répertoire pendant l'apurement.
2. Fixer `ENE_QUARTER` (et `ENE_MENAGE_EXPORT` si l'export ménage ne s'appelle
   pas `ENEM_<TX><ANNEE>.dta`). Garder `QX_EEC_VF.dta` comme nom de la copie de
   travail ménage (`brute_menage_work` dans `parentfile.do`).
3. Adapter les règles métier propres au trimestre, sur une branche dédiée :
   liste des entretiens doublons (`00-suppression_doublons.do`), noms des
   classeurs de codification (`00-codification_brute.do`,
   `tools/validate_codification_inputs.py`), bornes d'années (ex. `> 2026`)
   et sections fusionnées (`Fusion.do`). L'état du code d'un trimestre clos est
   conservé sur une branche d'archive (ex. `archive/2025T4`).
4. Suivre la procédure ci-dessus.

Pour reconstruire manuellement la copie de travail hors Stata :

```powershell
python tools\prepare_apurement_working_copy.py --reset-working-copy
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
| `ENE_MEDALLION_ORCHESTRATION introuvable` | Dépôt d'orchestration absent | Le cloner à côté de ce dépôt ou définir `ENE_ORCHESTRATION_ROOT` |
| `Racine du dépôt ENE_APUREMENT introuvable` | Stata lancé hors du dépôt | `cd` vers la racine du dépôt (ou `program/`), ou définir `ENE_BASE_DIR` |
| `Refus : dataout/apurement_quarter.txt indique ...` | Sorties d'un autre trimestre dans `dataout/` | Relancer l'apurement avec le bon `ENE_QUARTER` |
