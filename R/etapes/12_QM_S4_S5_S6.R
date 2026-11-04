# =============================================================================
# 12_QM_S4_S5_S6.R
#   01-QM_S4_immigration.do                -> etape_QM_S4()
#   01-QM_S5_emmigration.do                -> etape_QM_S5()
#   01-QM_S6_difficultes_fonctionnelles.do -> etape_QM_S6()
# =============================================================================

#' egen <v> = rownonmiss(<varlist>) : nombre de valeurs non manquantes par ligne
#' (texte non vide pour les variables chaîne).
rownonmiss <- function(d, spec) {
  vars <- resoudre_varlist(spec, names(d))
  n <- numeric(nrow(d))
  for (v in vars) n <- n + (1 - stf_missing(d[[v]]))
  n
}

etape_QM_S4 <- function(etat, regles) {
  f <- "01-QM_S4_immigration.do"
  seg <- segmenteur(regles, f, rbind(c(28, 239), c(242, 268)))
  # do: :15-25 ; QM_S1 standardisée (datain/standard), pas la sortie apurée
  d <- data.table::copy(etat$standard$QM_S4_immigration)
  supprimer_vars(d, "_merge")
  d <- fusionner_garder_apparies(d, etat$standard$QM_S0_identification, "interview__key",
                                 c("HH2", "HH3", "HH4", "HH12", "HH13", "HH3"))
  d <- fusionner_garder_apparies(d, etat$standard$QM_S1_composition_menage, c("interview__key", "membres__id"),
                                 c("AgeAnnee", "Statut_Res", "M6_A", "M1", "M2"))
  d[, commentaire := ""]                                               # do: :27
  seg(d, 28, 239)
  d[, nb_pas_manquant_IM8 := rownonmiss(d, "IM8__1-IM8__9")]          # do: :240
  d[, valeure_manquante1_IM8 := st_eq(nb_pas_manquant_IM8, 0)]        # do: :241
  seg(d, 242, 268)
  supprimer_vars(d, c("HH2", "HH3", "HH4", "HH12", "HH13", "M1", "M2", "Statut_Res", "M6_A", "AgeAnnee"))  # :269
  etat$sortie_menage$QM_S4_immigration <- d
  invisible(etat)
}

etape_QM_S5 <- function(etat, regles) {
  f <- "01-QM_S5_emmigration.do"
  seg <- segmenteur(regles, f, rbind(c(24, 62), c(70, 268)))
  # do: :20-23
  d <- data.table::copy(etat$standard$QM_S5_emmigration)
  s0 <- etat$standard$QM_S0_identification
  vars <- c("hha", "rgmen", "HH13", "ME1", "ME2A", resoudre_varlist("ME2B__0-ME2B__59", names(s0)))
  d <- fusionner_garder_apparies(d, s0, "interview__key", vars)
  seg(d, 24, 62)
  # do: :63-67  gen nb_pas_manquant = 0 ; foreach ME2B__0-ME2B__59 : += !missing()
  d[, nb_pas_manquant := rownonmiss(d, "ME2B__0-ME2B__59")]
  d[, valeure_manquante1 := st_eq(nb_pas_manquant, 0)]                # do: :69
  seg(d, 70, 268)
  # do: :269  liste explicite : les ME2B__<n>c compris dans la plage restent
  supprimer_vars(d, c("rgmen", "HH13", "hha", "ME1", "ME2A", paste0("ME2B__", 0:59)))
  etat$sortie_menage$QM_S5_emmigration <- d
  invisible(etat)
}

etape_QM_S6 <- function(etat, regles) {
  f <- "01-QM_S6_difficultes_fonctionnelles.do"
  seg <- segmenteur(regles, f, rbind(c(29, 81), c(84, 189)))
  # do: :15-26
  d <- data.table::copy(etat$standard$QM_S6_difficultes_fonctionnelles)
  supprimer_vars(d, "_merge")
  d <- fusionner_garder_apparies(d, etat$standard$QM_S0_identification, "interview__key",
                                 c("HH2", "HH3", "HH4", "HH12", "HH13", "HH3"))
  d <- fusionner_garder_apparies(d, etat$standard$QM_S1_composition_menage, c("interview__key", "membres__id"),
                                 c("AgeAnnee", "Statut_Res"))
  d[, commentaire := ""]                                               # do: :28
  seg(d, 29, 81)
  d[, nb_pas_manquant_DIF3 := rownonmiss(d, "DIF3__1-DIF3__9")]       # do: :82
  d[, valeure_manquante1 := st_eq(nb_pas_manquant_DIF3, 0)]           # do: :83
  seg(d, 84, 189)
  supprimer_vars(d, c("HH2", "HH3", "HH4", "HH12", "HH13", "Statut_Res", "AgeAnnee"))  # do: :190
  etat$sortie_menage$QM_S6_difficultes_fonctionnelles <- d
  invisible(etat)
}
