# =============================================================================
# 22_INDIV_S4_S14.R : sections individuelles S4 à S14.
# Schéma commun : base de section + variables de contrôle (merges d'en-tête,
# portés ici), puis plage d'instructions exécutée par l'interpréteur
# (R/lib/interpreteur.R), puis sauvegarde. Les rosters (r_competence_quali,
# r_activite_s, Revenu_es, r_revenu_h_emp, Activiteparent) suivent le même
# schéma. Les numéros de ligne renvoient aux do-files.
# =============================================================================

K2 <- c("interview__key", "membres__id")

#' Applique une liste de merges d'en-tête : chaque élément = list(base, cles,
#' vars, tous = FALSE). `tous = TRUE` : merge sans filtre (nogen) ; on vérifie
#' alors qu'aucune ligne ne serait ajoutée ni perdue (mêmes individus).
entete <- function(d, merges) {
  for (mg in merges) {
    n0 <- nrow(d)
    d <- fusionner_garder_apparies(d, mg[[1]], mg[[2]], mg[[3]])
    if (isTRUE(mg$tous)) {
      cd <- do.call(paste, c(lapply(mg[[2]], function(k) as.character(mg[[1]][[k]])), sep = "\r"))
      cm <- do.call(paste, c(lapply(mg[[2]], function(k) as.character(d[[k]])), sep = "\r"))
      if (nrow(d) != n0 || (identical(mg[[2]], K2) && any(!cd %in% cm)))
        stop("merge sans filtre : individus différents entre les bases (cas non porté)")
    }
  }
  d
}

.sortie_ind <- function(etat, nom, d) {
  if (is.null(etat$sortie_individu)) etat$sortie_individu <- list()
  etat$sortie_individu[[nom]] <- d
}
.sortie_roster <- function(etat, nom, d) {
  if (is.null(etat$sortie_rosters)) etat$sortie_rosters <- list()
  etat$sortie_rosters[[nom]] <- d
}
.regles <- function(regles, f) regles[regles$fichier_do == f, ]

etape_INDIV_S4 <- function(etat, regles) {
  f <- "01-INDIV_S4_competences_qualifications.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S4_competences_qualifications), list(          # do: :16-45
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(etat$membres, K2, c("membre_id_v1_IND", "EF1", "EF2", "EF3", "EF4")),
    list(s$INDIV_S3_emploi_principal, K2, c("EN_EMP", "EP2ka", "EP2k")),
    list(s$QM_S0_identification, "interview__key", c("HH2", "HH3", "HH12", "HH13", "HH4", "HH6", "HH8B", "rgmen")),
    list(s$INDIV_S3_emploi_principal, K2, c("EP1b1", "EP1a1"))))
  d <- executer_plage(d, f, r, 44, 738)
  .sortie_ind(etat, "INDIV_S4_competences_qualifications", d)                      # do: :739
  v <- data.table::copy(etat$r_competence_quali); supprimer_vars(v, "_merge")       # do: :741-751
  v <- entete(v, list(list(etat$membres, K2, c(paste0("CQ6__", 1:12), "EN_EMP")),
                      list(etat$menage, "interview__key", c("MODINTR", "HH13"))))
  v <- executer_plage(v, f, r, 752, 884)
  .sortie_roster(etat, "r_competence_quali", v)                                    # do: :885
  invisible(etat)
}

etape_INDIV_S5 <- function(etat, regles) {
  f <- "01-INDIV_S5_pluriactivite.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S5_pluriactivite), list(                     # do: :9-29
    list(s$INDIV_S3_emploi_principal, K2, "EN_EMP"),
    list(s$QM_S0_identification, "interview__key", c("HH2", "HH13")),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(etat$membres, K2, c("membre_id_v1", "membre_id_v1_IND", "CodeCIAPactivité",
                             "code_citp_emp_principal", "code_citp_emp_secondaire"))))
  d <- executer_plage(d, f, r, 30, 165)
  .sortie_ind(etat, "INDIV_S5_pluriactivite", d)                                   # do: :166
  d <- executer_plage(d, f, r, 167, 172)
  d <- fusionner_1_m(d, etat$r_activite_s, K2)                                     # do: :173-174
  d <- executer_plage(d, f, r, 175, 335)
  .sortie_roster(etat, "r_activite_s", d)                                          # do: :336
  invisible(etat)
}

.entete_S6 <- function(etat, d) {
  entete(d, list(
    list(etat$menage, "interview__key", c("HH2", "HH3", "HH4", "HH12", "HH13", "HH3", "annee")),
    list(etat$standard$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(etat$membres, K2, c("membre_id_v1", "membre_id_v1_IND", "CodeCIAPactivité",
                             "code_citp_emp_principal", "code_citp_emp_secondaire")),
    list(etat$sortie_individu$INDIV_S5_pluriactivite, K2, "PL3")))
}

etape_INDIV_S6 <- function(etat, regles) {
  f <- "01-INDIV_S6_emploi_secondaire.do"; r <- .regles(regles, f)
  d <- .entete_S6(etat, data.table::copy(etat$standard$INDIV_S6_emploi_secondaire))   # do: :7-25
  d <- executer_plage(d, f, r, 26, 369)
  etat$standard$INDIV_S6_emploi_secondaire <- d                                     # do: :370 (datain/standard)
  v <- data.table::copy(etat$Revenu_es); supprimer_vars(v, "_merge")                # do: :373-385
  v <- entete(v, list(list(etat$membres, K2, c("ES4_2__7", "ES4_2__9", "ES4_2__10", "CodeCIAPactivité",
                                               "code_citp_emp_principal", "code_citp_emp_secondaire")),
                      list(etat$menage, "interview__key", c("HH13", "HH2"))))
  v <- executer_plage(v, f, r, 386, 552)
  .sortie_roster(etat, "Revenu_es", v)                                             # do: :553
  d <- .entete_S6(etat, data.table::copy(etat$standard$INDIV_S6_emploi_secondaire))   # do: :555-573
  d <- executer_plage(d, f, r, 574, 1086)
  .sortie_ind(etat, "INDIV_S6_emploi_secondaire", d)                               # do: :1087
  invisible(etat)
}

etape_INDIV_S7 <- function(etat, regles) {
  f <- "01-INDIV_S7_temps_travail.do"; r <- .regles(regles, f); s <- etat$standard; o <- etat$sortie_individu
  d <- entete(data.table::copy(s$INDIV_S7_temps_travail), list(                     # do: :6-44
    list(s$QM_S0_identification, "interview__key", c("HH13", "HH12")),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(s$INDIV_S3_emploi_principal, K2, c("EN_EMP", "EP11", "EP3")),
    list(etat$membres, K2, c("membre_id_v1", "membre_id_v1_IND", "CodeCIAPactivité",
                             "code_citp_emp_principal", "code_citp_emp_secondaire")),
    list(o$INDIV_S2_situation_emploi, K2, "SE8"),
    list(o$INDIV_S5_pluriactivite, K2, c("PL1", "PL2", "PL3"))))
  d <- executer_plage(d, f, r, 45, 788)
  .sortie_ind(etat, "INDIV_S7_temps_travail", d)
  invisible(etat)
}

etape_INDIV_S8 <- function(etat, regles) {
  f <- "01-INDIV_S8_emploi_inadequat.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S8_emploi_inadequat), list(                  # do: :12-33
    list(s$QM_S0_identification, "interview__key", c("HH1", "HH2", "HH3", "HH13")),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(s$INDIV_S3_emploi_principal, K2, "EN_EMP"),
    list(etat$membres, K2, "membre_id_v1_IND")))
  d <- executer_plage(d, f, r, 34, 301)
  .sortie_ind(etat, "INDIV_S8_emploi_inadequat", d)
  invisible(etat)
}

etape_INDIV_S9 <- function(etat, regles) {
  f <- "01-INDIV_S9_recherche_emploi.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S9_recherche_emploi), list(                  # do: :13-39
    list(s$QM_S0_identification, "interview__key", "HH13"),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(s$INDIV_S3_emploi_principal, K2, "EN_EMP"),
    list(etat$membres, K2, "membre_id_v1_IND"),
    list(s$INDIV_S8_emploi_inadequat, K2, "WKI3")))
  d <- executer_plage(d, f, r, 40, 197)
  .sortie_ind(etat, "INDIV_S9_recherche_emploi", d)
  invisible(etat)
}

etape_INDIV_S10 <- function(etat, regles) {
  f <- "01-INDIV_S10_recherche_emploi_disponibilite.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S10_recherche_emploi_disponibilite), list(   # do: :23-42
    list(s$QM_S0_identification, "interview__key", c("HH2", "HH3", "HH12", "HH13", "HH4", "HH6", "HH8B", "rgmen")),
    list(s$INDIV_S3_emploi_principal, K2, "EN_EMP"),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(etat$membres, K2, c("membre_id_v1_IND", "EP1a", "hhb", "HH14a"))))
  d <- executer_plage(d, f, r, 43, 546)
  .sortie_ind(etat, "INDIV_S10_recherche_emploi_disponibilite", d)
  invisible(etat)
}

etape_INDIV_S11 <- function(etat, regles) {
  f <- "01-INDIV_S11_chomage.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S11_chomage), list(                          # do: :18-44
    list(s$QM_S0_identification, "interview__key", c("HH2", "HH3", "HH12", "HH13", "HH4", "HH6", "HH8B")),
    list(s$INDIV_S3_emploi_principal, K2, "EN_EMP"),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(etat$sortie_individu$INDIV_S10_recherche_emploi_disponibilite, K2, c("SRH1", "SRH2", "SRH2A", "SRH11")),
    list(etat$membres, K2, "membre_id_v1_IND")))
  d <- executer_plage(d, f, r, 45, 568)
  .sortie_ind(etat, "INDIV_S11_chomage", d)
  invisible(etat)
}

etape_INDIV_S12 <- function(etat, regles) {
  f <- "01-INDIV_S12_emploi_anterieur.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S12_emploi_anterieur), list(                 # do: :9-36
    list(s$INDIV_S3_emploi_principal, K2, c("EN_EMP", "EP1a", "EP2ka"), tous = TRUE),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm", tous = TRUE),
    list(s$INDIV_S11_chomage, K2, "C2", tous = TRUE),
    list(etat$membres, K2, "membre_id_v1_IND", tous = TRUE),
    list(s$QM_S0_identification, "interview__key", "HH13"),
    list(s$INDIV_S4_competences_qualifications, K2, "CQ4")))
  # do: :34-36  le dernier merge laisse _merge (= 3 après keep), supprimé ligne 525
  d[, `_merge` := 3]
  d <- executer_plage(d, f, r, 37, 526)
  .sortie_ind(etat, "INDIV_S12_emploi_anterieur", d)
  invisible(etat)
}

etape_INDIV_S13 <- function(etat, regles) {
  f <- "01-INDIV_S13_revenu_hors_emploi.do"; r <- .regles(regles, f); s <- etat$standard
  d <- entete(data.table::copy(s$INDIV_S13_revenu_hors_emploi), list(               # do: :19-57
    list(s$INDIV_S3_emploi_principal, K2, c("EN_EMP", "EP1a")),
    list(s$INDIV_S1_autres_formes_travail, K2, "M4Confirm"),
    list(s$INDIV_S11_chomage, K2, "C2"),
    list(etat$membres, K2, c("membre_id_v1_IND", "CodeCIAPactivité", "code_citp_emp_principal", "branche1")),
    list(s$QM_S0_identification, "interview__key", "HH13"),
    list(etat$menage, "interview__key", c("HH2", "HH3", "HH4", "HH12", "HH13", "HH3"))))
  d <- executer_plage(d, f, r, 58, 145)
  .sortie_ind(etat, "INDIV_S13_revenu_hors_emploi", d)                             # do: :146
  d <- executer_plage(d, f, r, 147, 154)
  d <- fusionner_1_m(d, etat$r_revenu_h_emp, K2)                                   # do: :155-156
  d <- executer_plage(d, f, r, 157, 296)
  .sortie_roster(etat, "r_revenu_h_emp", d)                                        # do: :297
  invisible(etat)
}

etape_INDIV_S14 <- function(etat, regles) {
  f <- "01-INDIV_S14_activite_parents.do"; r <- .regles(regles, f)
  v <- data.table::copy(etat$Activiteparent); supprimer_vars(v, "_merge")          # do: :11-23
  v <- entete(v, list(
    list(etat$membres, K2, c("M4Confirm", "membre_id_v1_IND", "TP7", "TP1A", "TP2A", "TP3aA", "TP3aA_Aut",
                             "TP3A1", "TP3A1_Aut", "TP4A", "TP5A", "TP6AA")),
    list(etat$menage, "interview__key", c("rgmen", "MODINTR", "HH2", "HH3", "HH4", "HH12", "HH13"))))
  v <- executer_plage(v, f, r, 24, 348)
  .sortie_roster(etat, "Activiteparent", v)                                        # do: :349
  d <- fusionner_garder_maitre(data.table::copy(etat$standard$INDIV_S14_activite_parents), etat$membres,
                               K2, c("M4Confirm", "membre_id_v1_IND"))             # do: :352-357
  d <- executer_plage(d, f, r, 358, 362)
  .sortie_ind(etat, "INDIV_S14_activite_parents", d)                               # do: :363
  invisible(etat)
}
