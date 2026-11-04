# =============================================================================
# 21_INDIV_S3.R : do: 01-INDIV_S3_emploi_principal.do (3 543 lignes)
#   Partie A (9-1303)    : contrôles emploi principal ; met à jour INDIV_S2
#                          (update replace) et réécrit datain/standard/INDIV_S3
#   Partie B (1311-1639) : roster Revenu -> dataout/Revenu.dta
#   Partie C (1643-3542) : suite des contrôles ; nouvelle mise à jour d'INDIV_S2 ;
#                          sortie dataout/standard/individu/INDIV_S3
# Les plages d'instructions simples (replace, gen, egen, drop, order) passent
# par l'interpréteur (R/lib/interpreteur.R) ; merges et preserve sont ici.
# =============================================================================

VARS_SE <- paste0("SE", 1:9)

#' do: :1284-1291 / :3526-3533 — preserve ; keep clés SE1-SE9 ; mise à jour
#' d'INDIV_S2 (standard_individu) par merge update replace ; restore.
.maj_S2_depuis_S3 <- function(etat, d) {
  cles <- c("interview__key", "membres__id")
  etat$sortie_individu$INDIV_S2_situation_emploi <-
    fusion_update_replace(etat$sortie_individu$INDIV_S2_situation_emploi, d, cles, VARS_SE)
}

etape_INDIV_S3 <- function(etat, regles) {
  f <- "01-INDIV_S3_emploi_principal.do"
  r <- regles[regles$fichier_do == f, ]
  cles <- c("interview__key", "membres__id")
  std <- etat$standard
  if (is.null(etat$sortie_individu$INDIV_S2_situation_emploi)) stop("INDIV_S3 requiert la sortie INDIV_S2")

  # ---- Partie A. do: :9-25 (merges sans filtre sauf ménage : mêmes individus)
  d <- data.table::copy(std$INDIV_S3_emploi_principal)
  d <- fusionner_garder_apparies(d, std$INDIV_S1_autres_formes_travail, cles, "M4Confirm")
  d <- fusionner_garder_apparies(d, etat$sortie_individu$INDIV_S2_situation_emploi, cles, VARS_SE)
  d <- fusionner_garder_apparies(d, etat$membres, cles, c("membre_id_v1", "membre_id_v1_IND", "CodeCIAPactivité",
                                                          "code_citp_emp_principal", "code_citp_emp_secondaire"))
  d <- fusionner_garder_apparies(d, etat$menage, "interview__key", c("annee", "HH13"))
  stopifnot(nrow(d) == nrow(std$INDIV_S3_emploi_principal))
  d <- executer_plage(d, f, r, 26, 1287)
  .maj_S2_depuis_S3(etat, d)                                           # do: :1288-1295
  d <- executer_plage(d, f, r, 1296, 1302)                             # do: :1297-1299
  etat$standard$INDIV_S3_emploi_principal <- d                         # do: :1303 (datain/standard)

  # ---- Partie B. Roster Revenu (do: :1311-1639)
  v <- data.table::copy(etat$Revenu)
  supprimer_vars(v, "_merge")
  v <- fusionner_garder_apparies(v, etat$menage, "interview__key", c("annee", "HH13"))
  v <- fusionner_garder_apparies(v, etat$membres, cles, c("EP6__10", "EP6__7", "EP1a", "EP1b", "EP3", "EP6a", "EP6__9"))
  v <- executer_plage(v, f, r, 1322, 1638)
  if (is.null(etat$sortie_rosters)) etat$sortie_rosters <- list()
  etat$sortie_rosters$Revenu <- v                                      # do: :1639 (dataout/Revenu.dta)

  # ---- Partie C. do: :1643-1668
  d <- data.table::copy(etat$standard$INDIV_S3_emploi_principal)
  d <- fusionner_garder_apparies(d, std$INDIV_S1_autres_formes_travail, cles, "M4Confirm")
  d <- fusionner_garder_apparies(d, etat$sortie_individu$INDIV_S2_situation_emploi, cles, VARS_SE)
  d <- fusionner_garder_apparies(d, etat$membres, cles, c("membre_id_v1", "membre_id_v1_IND"))
  d <- fusionner_garder_apparies(d, etat$menage, "interview__key", c("annee", "HH13"))
  d <- fusionner_garder_apparies(d, etat$menage, "interview__key", "V1interviewkey")
  d <- executer_plage(d, f, r, 1669, 3529)
  .maj_S2_depuis_S3(etat, d)                                           # do: :3530-3537
  d <- executer_plage(d, f, r, 3538, 3541)                             # do: :3539-3540
  etat$sortie_individu$INDIV_S3_emploi_principal <- d
  invisible(etat)
}
