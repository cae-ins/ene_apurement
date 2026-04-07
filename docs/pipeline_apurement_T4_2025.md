# Pipeline d'Apurement — ENEM Ménages T4 2025

**Institut National de la Statistique — Côte d'Ivoire**  
Enquête Nationale sur l'Emploi auprès des Ménages  
Documentation technique · Version 1.1 · Avril 2026  
Outil : Stata 17 · Collecte : Survey Solutions · Contrôle de version : Git

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Architecture médaillon](#2-architecture-médaillon)
3. [Séquence d'exécution](#3-séquence-dexécution)
4. [Flux de données détaillé](#4-flux-de-données-détaillé)
5. [Méthodologie d'apurement par variable](#5-méthodologie-dapurement-par-variable)
6. [Imputation par médiane stratifiée](#6-imputation-par-médiane-stratifiée)
7. [Gestion de la qualité](#7-gestion-de-la-qualité)
8. [Variables construites](#8-variables-construites)
9. [Points d'attention pour la prochaine vague](#9-points-dattention-pour-la-prochaine-vague)

---

## 1. Vue d'ensemble

Le pipeline d'apurement de l'ENEM-Ménages T4 2025 couvre la **Phase 5 du GSBPM** (traitement statistique). Il s'insère dans une chaîne de production en quatre projets distincts :

```mermaid
flowchart LR
    COL["**Collecte**
    ENE_SUIVI_COLLECTE"]

    APU["**Apurement**
    T4_2025_v"]

    PON["**Pondération**
    ENE_SURVEY_WEIGHTS"]

    IND["**Indicateurs**
    ENE_INDICATORS"]

    COL -->|"exports Survey Solutions"| APU
    APU -->|"bases apurées (.dta)"| PON
    PON -->|"bases pondérées"| IND

    style COL fill:#b46418,color:#fff,stroke:#b46418
    style APU fill:#5a78a0,color:#fff,stroke:#5a78a0
    style PON fill:#5a78a0,color:#fff,stroke:#5a78a0
    style IND fill:#b49614,color:#fff,stroke:#b49614
```

---

## 2. Architecture médaillon

Le projet suit une **architecture médaillon Bronze / Silver / Gold** garantissant l'immuabilité des données brutes et la reproductibilité complète du pipeline.

```mermaid
flowchart TD
    subgraph B["🥉  BRONZE — Immuable"]
        SRC["datain/source/
        18 fichiers .dta
        Export Survey Solutions brut
        ⚠️ Ne jamais modifier"]
    end

    subgraph S1["🥈  SILVER — Entrée"]
        BRUTE["datain/brute/
        18 fichiers filtrés
        (138 entretiens supprimés)"]
        STD["datain/standard/
        24 fichiers par section
        QM_S0…S7 · INDIV_S1…S15"]
    end

    subgraph S2["🥈  SILVER — Sortie apurée"]
        STDOUT["dataout/standard/
        menage/ · individu/
        24 sections apurées"]
    end

    subgraph G["🥇  GOLD — Bases fusionnées"]
        MEN["dataout/menage/
        menage.dta"]
        INDV["dataout/individu/
        membres.dta"]
    end

    subgraph W["📦  ENE_SURVEY_WEIGHTS"]
        CLM["data/02_cleaned/Menage/T4_2025/
        menage_T4_2025.dta"]
        CLI["data/02_cleaned/Individu/T4_2025/
        individu_T4_2025.dta"]
    end

    SRC -->|"Suppression_entretiens.do"| BRUTE
    BRUTE -->|"standard_db.do"| STD
    STD -->|"01-QM_S*.do
    01-INDIV_S*.do"| STDOUT
    STDOUT -->|"Fusion_ENE.do"| MEN
    STDOUT -->|"Fusion_ENE.do"| INDV
    MEN -->|"copy_to_cleaned.do
    (PowerShell)"| CLM
    INDV -->|"copy_to_cleaned.do
    (PowerShell)"| CLI

    style B fill:#f5e6d0,stroke:#b46418
    style S1 fill:#e0e8f0,stroke:#5a78a0
    style S2 fill:#d0dcea,stroke:#5a78a0
    style G fill:#f5f0d0,stroke:#b49614
    style W fill:#e8f0e8,stroke:#4a8a4a
```

---

## 3. Séquence d'exécution

Le point d'entrée est `parentfile.do` qui déclare tous les globals, puis appelle les scripts dans l'ordre suivant :

```mermaid
flowchart TD
    PF["parentfile.do
    Déclaration des globals
    datain_source · datain_brute · datain_standard
    standard_menage · standard_individu
    dataout_menage · dataout_individu"]

    SUPP["Suppression_entretiens_T4-2025.do
    Lecture : datain/source/
    138 clés supprimées
    Écriture : datain/brute/"]

    AUTRES["01-traitrement_autres.do
    Recodage des champs texte libres
    (statut · ethnie · religion · assurance)"]

    CODIF["Codification_T4_2025.do
    Import Excel codifications
    branche1 · branche2
    code_citp3_emp_principal/secondaire"]

    RENAME["Rename_label_var.do
    Labellisation variables binaires
    (0 = Non · 1 = Oui)"]

    STDDB["standard_db.do
    Découpage brute → sections
    24 fichiers .dta"]

    subgraph QM["Sections ménage — 01-QM_S*.do"]
        direction LR
        S0["S0 identification"]
        S1M["S1 composition"]
        S2M["S2 éducation"]
        S3M["S3 formation prof."]
        S4M["S4 immigration"]
        S5M["S5 émigration"]
        S6M["S6 difficultés fonct."]
        S7M["S7 logement"]
    end

    subgraph INDIV["Sections individu — 01-INDIV_S*.do"]
        direction LR
        S1I["S1 autres formes travail"]
        S2I["S2 situation emploi"]
        S3I["S3 emploi principal"]
        S4I["S4 compétences"]
        S5I["S5 pluriactivité"]
        S6I["S6 emploi secondaire"]
        S7I["S7 temps travail"]
        S8I["S8 emploi inadéquat"]
        S9I["S9 recherche emploi"]
        S10I["S10 recherche/dispo."]
        S11I["S11 chômage"]
        S12I["S12 emploi antérieur"]
        S13I["S13 revenu hors emploi"]
        S14I["S14 activité parents"]
    end

    FUS["Fusion_ENE.do
    QM_S0 + S7 → menage.dta
    QM_S1 + S2/S3/S4/S6 + INDIV_S1…S14 → membres.dta"]

    CPY["copy_to_cleaned.do
    PowerShell Copy-Item
    → ENE_SURVEY_WEIGHTS/data/02_cleaned/"]

    PF --> SUPP --> AUTRES --> CODIF --> RENAME --> STDDB
    STDDB --> QM
    STDDB --> INDIV
    QM --> FUS
    INDIV --> FUS
    FUS --> CPY
```

---

## 4. Flux de données détaillé

Chaque fichier produit par Survey Solutions traverse l'ensemble des couches :

```mermaid
flowchart LR
    subgraph SS["Survey Solutions"]
        EXP["Export .dta
        QX_EEC_VF · membres
        Revenu · Activiteparent
        VISITE_IND · etc.
        (18 fichiers)"]
    end

    subgraph SRC["datain/source/"]
        S1F["QX_EEC_VF.dta"]
        S2F["membres.dta"]
        S3F["Revenu.dta"]
        SDOT["... (15 autres)"]
    end

    subgraph BRU["datain/brute/"]
        B1F["QX_EEC_VF.dta
        − 138 entretiens"]
        B2F["membres.dta
        − lignes associées"]
        BDOT["... (15 autres)"]
    end

    subgraph STD["datain/standard/"]
        T1["QM_S0_identification"]
        T2["QM_S1_composition_menage"]
        T3["INDIV_S2_situation_emploi"]
        TDOT["... (21 autres)"]
    end

    subgraph OUT["dataout/"]
        MF["menage/menage.dta
        (ménage × logement)"]
        IF["individu/membres.dta
        (individu × 14 sections)"]
    end

    EXP -->|"copie manuelle"| SRC
    SRC -->|"Suppression_entretiens.do
    merge m:1 keep(master)"| BRU
    BRU -->|"standard_db.do"| STD
    STD -->|"01-QM_S*.do
    01-INDIV_S*.do
    apurement + recodage"| OUT
```

---

## 5. Méthodologie d'apurement par variable

Chaque variable est traitée selon une séquence standard en quatre étapes :

```mermaid
flowchart TD
    VAR(["Variable à apurer"])

    E1["① Valeurs manquantes
    Identifier les individus éligibles
    sans réponse
    → Export Excel pour retour enquêteur"]

    E2["② Cohérence des sauts
    Vérifier que seuls les éligibles
    ont répondu
    → Mise à manquant si hors cible"]

    E3["③ Valeurs permises
    Contrôle des plages attendues
    ex : heures ≤ 168
    ex : âge cohérent avec éducation"]

    E4["④ Vraisemblance
    Incohérences inter-variables
    ex : heures effectives > heures habituelles
    ex : statut emploi ↔ revenu"]

    OK(["Variable apurée
    → dataout/standard/"])

    VAR --> E1 --> E2 --> E3 --> E4 --> OK
```

---

## 6. Imputation par médiane stratifiée

Pour les variables continues à valeurs manquantes résiduelles (heures WKT, loyer L6), une imputation par **médiane stratifiée** est appliquée en trois passes successives, du plus fin au plus grossier :

```mermaid
flowchart TD
    START(["Valeur manquante résiduelle"])

    P1["Passe 1 — Strate fine
    EP3 × branche1 × code_citp3 × HH12 × HH6"]
    C1{"Cellule
    non vide ?"}
    IMP1(["✓ Imputation médiane"])

    P2["Passe 2 — Strate intermédiaire
    EP3 × branche1 × HH12 × HH6"]
    C2{"Cellule
    non vide ?"}
    IMP2(["✓ Imputation médiane"])

    P3["Passe 3 — Strate large
    EP3 × branche1"]
    IMP3(["✓ Imputation médiane"])

    START --> P1 --> C1
    C1 -->|"Oui"| IMP1
    C1 -->|"Non — repli"| P2 --> C2
    C2 -->|"Oui"| IMP2
    C2 -->|"Non — repli"| P3 --> IMP3
```

| Variable | Signification |
|---|---|
| `EP3` | Statut dans l'emploi (salarié, indépendant, patron…) |
| `branche1` | Branche CIAP agrégée (Agriculture / Industrie / Commerce / Autre service) |
| `code_citp3` | Code CITP-08 à 3 positions (groupe de base) |
| `HH12` | Région administrative |
| `HH6` | Milieu de résidence (1 = Urbain, 2 = Rural) |

---

## 7. Gestion de la qualité

### Entretiens supprimés

| Motif | Nombre | Critère |
|---|---|---|
| Entretiens problématiques | 6 | Identifiés manuellement |
| Entretiens vides | 131 | `HH14 == .` |
| Entretien en surnombre | 1 | Excédent selon région/ZD `69-78-22-41` |
| **Total** | **138** | |

### Traçabilité des erreurs

Chaque problème est exporté dans un fichier Excel explicitement nommé dans `document/` **avant** correction (ex : `E_WKT1_0.xlsx`, `SRH4_Manquants.xlsx`, `Erreur_L6_coh.xls`). Cela permet de justifier chaque décision et de retracer les anomalies jusqu'à l'enquêteur responsable.

---

## 8. Variables construites

| Variable | Description |
|---|---|
| `EN_EMP` | Statut d'emploi agrégé (1 = en emploi, 0 = hors emploi) |
| `branche1` | Branche CIAP agrégée, 4 modalités |
| `branche2` | Secteur économique, 3 modalités (Primaire / Secondaire / Tertiaire) |
| `code_citp3_emp_principal` | Code CITP-08 emploi principal, 3 positions |
| `code_citp3_emp_secondaire` | Code CITP-08 emploi secondaire, 3 positions |
| `code_citp3_pluriactivite1–4` | Codes CITP-08 autres emplois, 3 positions |
| `NB_HEURE_TRAVAIL_TOTAL` | Heures totales travaillées toutes activités confondues |

---

## 9. Points d'attention pour la prochaine vague

> **Résolu en T4 2025** — les points ~~barrés~~ ont été corrigés dans cette vague.

1. ~~**Interface avec la pondération manuelle**~~ — `copy_to_cleaned.do` automatise le transfert vers `ENE_SURVEY_WEIGHTS` via PowerShell (contourne les locks OneDrive).

2. ~~**Bronze inviolable**~~ — `datain/source/` est désormais la couche Bronze immuable. `Suppression_entretiens.do` lit depuis `source/` et écrit dans `brute/` sans jamais modifier la source.

3. **Fichiers volumineux** — `01-traitrement_autres.do` (562 Ko) et `Codification_T4_2025.do` (542 Ko) contiennent des centaines de `replace` manuels. Une approche par table de correspondance Excel réduirait la maintenance lors des prochaines vagues.

4. **`01-INDIV_S15_disponibilite.do`** — fichier stub, à implémenter ou à retirer définitivement.

5. **`assignment__actions.dta`** — ne contient pas de variable `interview__key`. La boucle de suppression détecte ce cas via `cap confirm variable` et copie le fichier tel quel.

---

*Document généré depuis l'inspection du code source — Avril 2026*  
*Pipeline : `parentfile.do` → `Suppression_entretiens.do` → `apurement.do` → 26 do-files → `Fusion_ENE.do` → `copy_to_cleaned.do`*
