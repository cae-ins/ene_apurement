# =============================================================================
# 30_fusion.R : do: Fusion.do (lancé à part dans la chaîne Stata)
#   dataout/menage/qx_eec_vf.dta   = QM_S0 (standard) + QM_S7 apurée
#   dataout/individu/membres.dta   = QM_S1 + sections ménage + sections INDIV
# =============================================================================

SECTIONS_FUSION_MENAGE <- c("QM_S2_education_formation", "QM_S3_formation_professionnelle",
                            "QM_S4_immigration", "QM_S6_difficultes_fonctionnelles")
SECTIONS_FUSION_INDIV <- c("INDIV_S1_autres_formes_travail", "INDIV_S2_situation_emploi",
  "INDIV_S3_emploi_principal", "INDIV_S4_competences_qualifications", "INDIV_S5_pluriactivite",
  "INDIV_S6_emploi_secondaire", "INDIV_S7_temps_travail", "INDIV_S8_emploi_inadequat",
  "INDIV_S9_recherche_emploi", "INDIV_S10_recherche_emploi_disponibilite", "INDIV_S11_chomage",
  "INDIV_S12_emploi_anterieur", "INDIV_S13_revenu_hors_emploi", "INDIV_S14_activite_parents")

etape_fusion <- function(etat) {
  sm <- etat$sortie_menage; si <- etat$sortie_individu
  manq <- c(setdiff(c("QM_S1_composition_menage", "QM_S7_logement", SECTIONS_FUSION_MENAGE), names(sm)),
            setdiff(SECTIONS_FUSION_INDIV, names(si)))
  if (length(manq)) stop("Sortie(s) absente(s) avant fusion : ", paste(manq, collapse = ", "))  # do: :26-45

  # do: :50-54  merge 1:1 sans keepus ni filtre ; _merge conservée
  s0 <- etat$standard$QM_S0_identification; s7 <- sm$QM_S7_logement
  cm <- s0$interview__key; cu <- s7$interview__key
  if (any(!cu %in% cm)) stop("Fusion ménage : ménages de QM_S7 absents de QM_S0 (cas non porté)")
  h <- fusionner_garder_maitre(s0, s7, "interview__key", names(s7))
  h[, `_merge` := haven::labelled(ifelse(cm[match(h$interview__key, cm)] %in% cu, 3, 1),
    c(`Master only (1)` = 1, `Using only (2)` = 2, `Matched (3)` = 3,
      `Missing updated (4)` = 4, `Nonmissing conflict (5)` = 5), label = "Matching result from merge")]
  etat$fusion_menage <- h

  # do: :58-76  merge 1:1 ..., keep(master match) nogen, toutes variables
  d <- data.table::copy(sm$QM_S1_composition_menage)
  for (s in SECTIONS_FUSION_MENAGE) d <- fusionner_garder_maitre(d, sm[[s]], K2, names(sm[[s]]))
  for (s in SECTIONS_FUSION_INDIV) d <- fusionner_garder_maitre(d, si[[s]], K2, names(si[[s]]))
  etat$fusion_individu <- d                                             # do: :86
  invisible(etat)
}
