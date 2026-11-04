# =============================================================================
# 03_standard_db.R : do: standard_db.do
#
# Découpe membres / QX_EEC_VF / emigration en bases de section
# (datain/standard/<section>.dta) par des plages de variables Stata
# (`drop a - b`, `keep interview__key - hhavf_X <nomenclatures>`).
# =============================================================================

#' Résout une varlist Stata (plages `a - b`, jokers `*`, noms abrégés) sur
#' `noms` ; renvoie les variables dans l'ordre de la base.
resoudre_varlist <- function(spec, noms) {
  spec <- gsub("\\s*-\\s*", " - ", trimws(spec))
  jet <- strsplit(spec, "\\s+")[[1]]
  garde <- logical(length(noms))
  i <- 1L
  while (i <= length(jet)) {
    t <- jet[[i]]
    if (i + 2L <= length(jet) && jet[[i + 1L]] == "-") {
      a <- match(resoudre_variable(t, noms), noms); b <- match(resoudre_variable(jet[[i + 2L]], noms), noms)
      if (b < a) stop("plage inversée ", t, " - ", jet[[i + 2L]])
      garde[a:b] <- TRUE; i <- i + 3L; next
    }
    if (grepl("\\*", t)) {
      re <- paste0("^", gsub("\\*", ".*", t), "$")
      k <- grepl(re, noms)
      if (!any(k)) stop("aucune variable ne correspond à ", t)
      garde <- garde | k
    } else {
      garde[match(resoudre_variable(t, noms), noms)] <- TRUE
    }
    i <- i + 1L
  }
  noms[garde]
}

# do: standard_db.do:20-22
VARS_NOMENCLATURE <- paste("CodeCIAPactivité CodeCIAPactivite_sec CodeCIAPactivite_pluri*",
                           "code_citp_emp_principal code_citp_emp_secondaire",
                           "pluriactivite1_codif pluriactivite2_codif pluriactivite3_codif branche1 branche2")

# do: standard_db.do — une ligne par `preserve ... save` (base, drop, keep)
SECTIONS_STANDARD <- data.frame(stringsAsFactors = FALSE, rbind(
  c("QM_S0_identification",                    "menage",     "hha_LOG - hhavf_LOG", "",                          "0"),
  c("QM_S7_logement",                          "menage",     "HH2A - hhavf_EM",     "interview__key - hhavf_LOG", "0"),
  c("QM_S1_composition_menage",                "membres",    "",                    "interview__key - hhavf_COMP", "1"),
  c("QM_S2_education_formation",               "membres",    "hha_COMP - M24B_Aut", "interview__key -hhavf_ED",   "1"),
  c("QM_S3_formation_professionnelle",         "membres",    "hha_COMP - EF18_aut", "interview__key -hhavf_FP",   "1"),
  c("QM_S4_immigration",                       "membres",    "hha_COMP - FP7",      "interview__key -hhavf_IM",   "1"),
  c("QM_S6_difficultes_fonctionnelles",        "membres",    "hha_COMP - IM8_Aut",  "interview__key -hhavf_HAND", "1"),
  c("QM_S5_emmigration",                       "emigration", "",                    "",                           "0"),
  c("INDIV_S1_autres_formes_travail",          "membres",    "hha_COMP - Q1_16b__4", "interview__key - hhavf_FT", "1"),
  c("INDIV_S2_situation_emploi",               "membres",    "hha_COMP - hhavf_FT", "interview__key - hhavf_SE",  "1"),
  c("INDIV_S3_emploi_principal",               "membres",    "hha_COMP -hhavf_SE",  "interview__key - hhavf_EMP", "1"),
  c("INDIV_S4_competences_qualifications",     "membres",    "hha_COMP - hhavf_EMP", "interview__key - hhavf_CQ", "1"),
  c("INDIV_S5_pluriactivite",                  "membres",    "hha_COMP - hhavf_CQ", "interview__key - hhavf_PL",  "1"),
  c("INDIV_S6_emploi_secondaire",              "membres",    "hha_COMP - hhavf_PL", "interview__key - hhavf_ES",  "1"),
  c("INDIV_S7_temps_travail",                  "membres",    "hha_COMP - hhavf_ES", "interview__key - hhavf_WKT", "1"),
  c("INDIV_S8_emploi_inadequat",               "membres",    "hha_COMP - hhavf_WKT", "interview__key - hhavf_WKI", "1"),
  c("INDIV_S9_recherche_emploi",               "membres",    "hha_COMP - hhavf_WKI", "interview__key - hhavf_R",  "1"),
  c("INDIV_S10_recherche_emploi_disponibilite", "membres",   "hha_COMP - hhavf_R",  "interview__key - hhavf_SRH", "1"),
  c("INDIV_S11_chomage",                       "membres",    "hha_COMP - hhavf_SRH", "interview__key - hhavf_C",  "1"),
  c("INDIV_S12_emploi_anterieur",              "membres",    "hha_COMP - hhavf_C",  "interview__key - hhavf_P",   "1"),
  c("INDIV_S13_revenu_hors_emploi",            "membres",    "hha_COMP - hhavf_P",  "interview__key - hhavf_RHE", "1"),
  c("INDIV_S14_activite_parents",              "membres",    "hha_COMP - hhavf_RHE", "interview__key - hhavf_TP", "1"),
  c("INDIV_S15_disponibilite",                 "membres",    "hha_COMP - hhavf_TP", "interview__key - st_ind",    "1")
))
names(SECTIONS_STANDARD) <- c("section", "base", "drop", "keep", "nomenclature")

etape_standard_db <- function(etat) {
  etat$standard <- list()
  for (k in seq_len(nrow(SECTIONS_STANDARD))) {
    s <- SECTIONS_STANDARD[k, ]
    d <- get(s$base, envir = etat)
    noms <- names(d)
    if (nzchar(s$drop)) noms <- setdiff(noms, resoudre_varlist(s$drop, noms))
    if (nzchar(s$keep)) {
      spec <- if (s$nomenclature == "1") paste(s$keep, VARS_NOMENCLATURE) else s$keep
      noms <- resoudre_varlist(spec, noms)
    }
    etat$standard[[s$section]] <- d[, noms, with = FALSE]
  }
  invisible(etat)
}
