# =============================================================================
# 20_INDIV_S1_S2.R
#   01-INDIV_S1_autres_formes_travail.do -> etape_INDIV_S1()
#   01-INDIV_S2_situation_emploi.do      -> etape_INDIV_S2()
# NB : la section S3 (lignes 1291-1294) met ensuite à jour INDIV_S2 par
# `merge ..., update replace` ; la sortie de etape_INDIV_S2 est l'état avant
# cette mise à jour.
# =============================================================================

etape_INDIV_S1 <- function(etat, regles) {
  f <- "01-INDIV_S1_autres_formes_travail.do"
  seg <- segmenteur(regles, f, rbind(c(42, 137), c(139, 139), c(141, 202), c(204, 204), c(206, 831)))
  std <- etat$standard
  cles <- c("interview__key", "membres__id")
  # do: :13-41
  d <- data.table::copy(std$INDIV_S1_autres_formes_travail)
  d <- fusionner_garder_apparies(d, std$QM_S1_composition_menage, cles, c("AgeAnnee", "Statut_Res"))
  d <- fusionner_garder_apparies(d, std$QM_S0_identification, "interview__key", c("HH13", "MODINTR"))
  d <- fusionner_garder_apparies(d, std$INDIV_S3_emploi_principal, cles, "EN_EMP")
  d <- fusionner_garder_apparies(d, etat$membres, cles, c("membre_id_v1", "membre_id_v1_IND"))
  d <- fusionner_garder_apparies(d, etat$membres, cles, "hhaa")
  seg(d, 42, 137)
  d[, FT1M_ := copie_num(FT1M)]; seg(d, 139, 139)                      # do: :138
  supprimer_vars(d, "FT1M_")                                           # do: :140
  seg(d, 141, 202)
  d[, FT1BM_ := copie_num(FT1BM)]; seg(d, 204, 204)                    # do: :203
  supprimer_vars(d, "FT1BM_")                                          # do: :205
  seg(d, 206, 831)
  supprimer_vars(d, c("Statut_Res", "AgeAnnee", "HH13", "MODINTR", "EN_EMP", "membre_id_v1_IND", "hhaa"))  # :832
  if (is.null(etat$sortie_individu)) etat$sortie_individu <- list()
  etat$sortie_individu$INDIV_S1_autres_formes_travail <- d
  invisible(etat)
}

etape_INDIV_S2 <- function(etat, regles) {
  f <- "01-INDIV_S2_situation_emploi.do"
  seg <- segmenteur(regles, f, rbind(c(33, 232)))
  std <- etat$standard
  cles <- c("interview__key", "membres__id")
  # do: :10-32 ; INDIV_S1 lu dans datain/standard (version standard_db)
  d <- data.table::copy(std$INDIV_S2_situation_emploi)
  d <- fusionner_garder_apparies(d, std$QM_S1_composition_menage, cles, c("AgeAnnee", "Statut_Res"))
  d <- fusionner_garder_apparies(d, std$QM_S0_identification, "interview__key", c("HH13", "HH12", "MODINTR"))
  d <- fusionner_garder_apparies(d, std$INDIV_S1_autres_formes_travail, cles, "M4Confirm")
  d <- fusionner_garder_apparies(d, std$INDIV_S3_emploi_principal, cles, "EN_EMP")
  seg(d, 33, 232)
  supprimer_vars(d, c("Statut_Res", "AgeAnnee", "HH12", "HH13", "MODINTR", "M4Confirm", "EN_EMP"))  # :233
  if (is.null(etat$sortie_individu)) etat$sortie_individu <- list()
  etat$sortie_individu$INDIV_S2_situation_emploi <- d
  invisible(etat)
}
