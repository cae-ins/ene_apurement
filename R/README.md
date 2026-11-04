# Apurement ENE-M en R (portage de la chaîne Stata)

Portage progressif de `program/apurement.do` (30 do-files inclus, ~30 800 lignes)
en R, avec contrôle de parité chiffré contre les sorties Stata.

## Principe

Les ~13 800 `replace` des do-files ne sont pas recopiés à la main. Le script
`R/extraction/extraire_regles.R` lit les do-files, les découpe en instructions
(commentaires, `///`, blocs, `preserve`) et range chaque `replace` de premier
niveau dans une table versionnée de `referentiels/` :

| Table | Contenu |
|---|---|
| `recodages_texte.csv` | `replace` génériques : variable, valeur cible (expression Stata), variable/valeur source si la condition est `X == "texte"`, condition complète, fichier, ligne, base, statut |
| `corrections_cas.csv` | `replace` ciblant un `interview__key` (et `membres__id`) précis |
| `doublons_a_supprimer.csv` | 525 `interview__key` des boucles de `00-suppression_doublons.do` |
| `regles_non_traduites.csv` | `replace` que le parseur ne traduit pas (boucles `foreach`, macros) : portés à la main dans l'étape R |
| `positions_in_resolues.csv` | les 4 `replace … in <n>` traduits en clés, d'après l'ordre Stata (voir plus bas) |
| `inventaire_instructions.csv` | toutes les instructions modifiant les données (gen, egen, merge, drop…) |
| `comptage_replace.csv` | contrôle : `replace` actifs = extraits + non traduits, par fichier |

Le code R (`R/lib/regles.R`) applique ces tables de façon générique : chaque
expression Stata est traduite en R par `R/lib/stata_expr.R`, qui reproduit la
sémantique Stata (manquants `.`/`.a` plus grands que tout nombre, condition
manquante = vraie, `regexm` sur les octets, `lower` ASCII, `round(-2.5) = -2`,
`||` accepté, littéraux accolés…). Ces points ont été vérifiés sous Stata 17
(`tests/testthat/test_stata_expr.R`). Les instructions non génériques (merge,
egen par ménage…) sont portées à la main et annotées `# do: <fichier>:<ligne>`.

## Correspondance do-file → R (ordre d'exécution)

| # | Do-file Stata | Fonction R (fichier) | Entrées | Sorties | État |
|---|---|---|---|---|---|
| 0 | `00-initialisation_brute_depuis_staging.do` | `etape_initialisation` (`etapes/00_brute.R`) | `datain/staging/*.dta` | bases en mémoire | porté |
| 1 | `00-protections_sauvegarde_brute.do` | sans objet (pas de fichiers intermédiaires) | | | — |
| 2 | `00-suppression_doublons.do` | `etape_doublons` | membres, ENEM_TxAAAA, r_activite_s, emigration + `doublons_a_supprimer.csv` | idem, ménage → QX_EEC_VF | porté, conforme |
| 3 | `00-suppression_non_residents.do` | `etape_non_residents` | membres, QX_EEC_VF | idem | porté, conforme |
| 4 | `00-nettoyage_individus_brute.do` | `etape_nettoyage` | membres | membres | porté, conforme |
| 5 | `01-traitrement_autres.do` | `etape_traitement_autres` (`etapes/01_traitement_autres.R`) | membres, QX_EEC_VF, r_activite_s + `recodages_texte.csv` | idem | porté, conforme |
| 6 | `Rename_label_var.do` | `etape_rename_label` (`etapes/02_rename_codification.R`) | membres | membres (libellés) | porté, conforme |
| 7 | `00-codification_brute.do` | `etape_codification` | membres + classeurs `document/codification/` | membres (codes CITP/CIAP) | porté, conforme (= `datain/brute` du run Stata) |
| 8 | `standard_db.do` | `etape_standard_db` (`etapes/03_standard_db.R`) | membres, QX_EEC_VF, emigration | `datain/standard/QM_*`, `INDIV_*` (23 bases) | porté, conforme |
| 9 | `01-QM_S1_composition_menage.do` | `etape_QM_S1` (`etapes/10_QM_S1.R`) | standard QM_S1, QM_S0, INDIV_S1, membres + `corrections_cas.csv` | `dataout/standard/menage/QM_S1_composition_menage.dta` | porté, conforme (ordre des lignes : voir plus bas) |
| 10–15 | `01-QM_S2` … `01-QM_S7` | `etape_QM_S2` … `etape_QM_S7` (`etapes/11_QM_S2_S3.R`, `12_QM_S4_S5_S6.R`, `13_QM_S7.R`) | sections standard, QX_EEC_VF, membres | `dataout/standard/menage/` | portés, conformes |
| 16–29 | `01-INDIV_S1` … `01-INDIV_S14` | à porter | | `dataout/standard/individu/` + rosters `dataout/*.dta` | à faire |
| — | `Fusion.do` (lancé à part) | à porter | sorties standard | `dataout/menage/qx_eec_vf.dta`, `dataout/individu/membres.dta` | à faire |

Les ~250 `export excel` de listes d'anomalies (jamais relus par la chaîne)
passent par une seule fonction, `exporter_anomalies()` (`R/lib/anomalies.R`),
désactivée par défaut (`ENE_EXPORT_ANOMALIES=1` pour écrire les classeurs).

## Lancer

```sh
export ENE_DATA_DIR=/chemin/ENE_APUREMENT      # datain/staging, document/codification, sorties Stata
export ENE_REF_DIR=/chemin/apur_ref/snap       # références intermédiaires Stata (facultatif)
export ENE_OUT_DIR=/chemin/sortie_r            # défaut : ./sortie_r/<trimestre>
Rscript --vanilla R/extraction/extraire_regles.R --quarter T1_2026   # régénère referentiels/
Rscript --vanilla R/run_apurement.R --quarter T1_2026 --parite [--jusqua QM_S7] [--cache] [--ecrire]
Rscript --vanilla R/run_apurement.R --quarter T1_2026 --cache --parite-sections   # itérations rapides
Rscript --vanilla -e "testthat::test_dir('tests/testthat')"
```

Rapports de parité : `<ENE_OUT_DIR>/parite/` (un `.txt` et deux `.csv` par base,
plus `synthese_parite.csv`). `R/parite.R` s'utilise aussi seul :
`Rscript R/parite.R --r a.dta --ref b.dta --cles interview__key,membres__id --nom X`.

## Références Stata

- Finales : `$ENE_DATA_DIR/datain/brute`, `datain/standard`, `dataout/standard/*`
  (run complet T1_2026 du 26 oct. 2026, marqueur `dataout/apurement_quarter.txt`).
  NB : `datain/brute` est modifié en place par Stata ; l'entrée brute réelle est
  `datain/staging`.
- Intermédiaires : `R/reference/ref_brute.do`, lancé dans un dossier jetable qui
  contient une copie de `staging` dans `datain/brute`, écrit l'état des bases
  après chaque étape dans `snap/<étape>/`.

## Parité T1_2026 (état au 4 nov. 2026)

Toutes les bases produites par R jusqu'à QM_S7 sont identiques cellule par
cellule à Stata (valeurs, manquants étendus, libellés de variables et de
valeurs, ordre des variables) : 4 rosters × 5 états bruts, membres et
QX_EEC_VF finaux, 23 bases `standard_db`, 7 sections ménage. Pour mesurer ce
que ces contrôles couvrent : Stata modifie 11 241 cellules de membres dans
`traitement_autres`, 1 479 dans QM_S1, 3 073 dans QM_S2, 132 dans QM_S7.

## Ordre des lignes et tri instable

Le `merge m:1 interview__key` de `00-suppression_non_residents.do` trie la base
membres par ménage sans tri stable : l'ordre des individus dans un ménage
dépend de l'algorithme interne de Stata (reproductible d'un run à l'autre, mais
non documenté). R trie de façon stable (ordre d'origine dans le ménage). Les
valeurs sont identiques ; seul l'ordre des lignes diffère (rapporté par la
parité). Conséquence : les 4 `replace … in <n>` de `01-traitrement_autres.do`
(lignes 6728, 6739, 6742, 6955) sont résolus en clés à partir de l'ordre Stata
(`R/extraction/resoudre_positions.R`). Ces règles sont fragiles : la position
1100 et la position 8456 visent des individus dont `EP6_Aut` est vide.

Le `merge 1:1` de la codification retrie membres par (ménage, individu) : à
partir de là l'ordre redevient identique à Stata. Les `bysort interview__key`
de QM_S1 le défont de nouveau : dans la sortie Stata, 5 460 ménages sur 6 174
à plusieurs membres n'ont pas leurs individus par `membres__id` croissant
(24 035 lignes sur 31 955 à une autre position qu'en R). Le `sort` sans
`stable` de QM_S1 (lignes 36-39, `interview__id membres__id M0`) n'a pas
d'ex aequo (clé unique) : il est déterministe. Aucune règle portée en aval
n'utilise `_n`/`in`, donc les valeurs ne dépendent pas de cet ordre.
