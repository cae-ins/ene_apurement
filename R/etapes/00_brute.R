# =============================================================================
# 00_brute.R : étapes appliquées aux copies de travail brutes.
#   00-initialisation_brute_depuis_staging.do -> etape_initialisation()
#   00-suppression_doublons.do                -> etape_doublons()
#   00-suppression_non_residents.do           -> etape_non_residents()
#   00-nettoyage_individus_brute.do           -> etape_nettoyage()
#
# L'état de la chaîne est un environnement `etat` contenant les bases en
# mémoire (data.table) : membres, menage (= QX_EEC_VF.dta), r_activite_s,
# emigration, et les autres rosters. Les commentaires "do: fichier:ligne"
# renvoient à l'instruction Stata portée à la main.
# =============================================================================

# Bases chargées depuis datain/staging (copie brute de Survey Solutions)
ROSTERS_BRUTS <- c("membres", "r_activite_s", "emigration", "Revenu", "Revenu_es",
                   "Activiteparent", "r_competence_quali", "r_revenu_h_emp")

#' do: 00-initialisation_brute_depuis_staging.do (robocopy staging -> brute).
#' En R, rien n'est copié : les bases sont lues depuis staging, qui reste
#' immuable, et la copie de travail vit en mémoire.
etape_initialisation <- function(ch) {
  etat <- new.env()
  etat$trimestre <- ch$trimestre
  for (b in ROSTERS_BRUTS) {
    f <- file.path(ch$staging, paste0(b, ".dta"))
    if (file.exists(f)) assign(b, lire_dta(f), envir = etat)
  }
  # Export ménage du trimestre (ENEM_<TX><YYYY>.dta), copie de travail QX_EEC_VF
  etat$menage_source <- lire_dta(file.path(ch$staging, ch$menage_source))
  etat
}

#' do: 00-suppression_doublons.do — supprime les interview__key listés dans
#' referentiels/doublons_a_supprimer.csv des 4 bases. Le ménage source devient
#' la copie de travail QX_EEC_VF (save_brute_menage_work_safe).
etape_doublons <- function(etat, doublons) {
  ids <- unique(doublons$interview__key)
  etat$n_doublons <- list()
  for (b in c("menage_source", "membres", "r_activite_s", "emigration")) {
    if (!exists(b, envir = etat, inherits = FALSE)) next
    d <- get(b, envir = etat)
    # do: 00-suppression_doublons.do:17  cap drop todrop (l'export ménage
    # T1_2026 contient déjà une variable todrop, supprimée par Stata)
    if ("todrop" %in% names(d)) d[, todrop := NULL]
    garde <- !(d$interview__key %in% ids)
    etat$n_doublons[[b]] <- sum(!garde)
    assign(b, d[garde], envir = etat)
  }
  etat$menage <- etat$menage_source
  rm("menage_source", envir = etat)
  invisible(etat)
}

#' Emule `merge ... using` de Stata pour l'ordre des lignes : la base maître
#' est triée par la clé de fusion (tri stable, ordre des octets).
.trier_comme_merge <- function(d, cles) {
  data.table::setorderv(d, cles)
  d
}

#' do: 00-suppression_non_residents.do
etape_non_residents <- function(etat) {
  m <- etat$membres
  # do: 00-suppression_non_residents.do:14  drop if Statut_Res == 0
  m <- m[st_eq(Statut_Res, 0) == 0]
  # do: :21-28  merge m:1 interview__key (clés ménage), keep(1 3) ; :33 drop if _merge==1
  m <- .trier_comme_merge(m, "interview__key")
  m <- m[interview__key %in% etat$menage$interview__key]
  etat$membres <- m
  # do: :45-53  merge 1:1 sur les clés ménage ayant des individus ; drop _merge==1
  h <- .trier_comme_merge(etat$menage, "interview__key")
  etat$menage <- h[interview__key %in% m$interview__key]
  invisible(etat)
}

#' do: 00-nettoyage_individus_brute.do
etape_nettoyage <- function(etat, regles) {
  m <- etat$membres
  # do: 00-nettoyage_individus_brute.do:15  gen tag_invalid = 0
  m[, tag_invalid := 0]
  # do: :18-19  règles extraites (replace tag_invalid = 1 if ...)
  appliquer_regles(m, regles, "00-nettoyage_individus_brute.do")
  # do: :22  drop if tag_invalid == 1 ; :24 drop tag_invalid
  m <- m[tag_invalid != 1]
  m[, tag_invalid := NULL]
  # do: :31  drop if missing(M4Confirm) & AgeAnnee >= 15 & !missing(AgeAnnee)
  sel <- st_vrai(st_and(st_and(stf_missing(m$M4Confirm), st_ge(m$AgeAnnee, 15)),
                        st_not(stf_missing(m$AgeAnnee))))
  etat$membres <- m[!sel]
  invisible(etat)
}
