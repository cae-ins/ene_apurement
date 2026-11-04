#!/usr/bin/env Rscript
# =============================================================================
# run_apurement.R : lance la chaîne d'apurement ENE-M portée en R.
#
#   Rscript --vanilla R/run_apurement.R --quarter T1_2026 [--jusqua <etape>]
#           [--parite] [--ecrire]
#
# --quarter  trimestre traité (obligatoire, forme TX_YYYY)
# --jusqua   dernière étape exécutée (défaut : toutes les étapes portées)
# --parite   compare chaque base produite à sa référence Stata et écrit les
#            rapports dans <ENE_OUT_DIR>/parite/
# --ecrire   écrit les bases produites (.dta) dans <ENE_OUT_DIR>/
# Variables d'environnement : voir R/lib/io.R (ENE_DATA_DIR, ENE_OUT_DIR,
# ENE_REF_DIR).
# =============================================================================

local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  racine <- if (length(f)) normalizePath(file.path(dirname(f), ".."), winslash = "/") else getwd()
  assign("RACINE_DEPOT", racine, envir = globalenv())
})
suppressPackageStartupMessages(library(data.table))
for (f in c("do_parser.R", "stata_expr.R", "regles.R", "io.R", "anomalies.R"))
  source(file.path(RACINE_DEPOT, "R", "lib", f), encoding = "UTF-8")
source(file.path(RACINE_DEPOT, "R", "parite.R"), encoding = "UTF-8")
for (f in sort(list.files(file.path(RACINE_DEPOT, "R", "etapes"), "\\.R$", full.names = TRUE)))
  source(f, encoding = "UTF-8")

a <- commandArgs(trailingOnly = TRUE)
arg <- function(n, d = NULL) { i <- match(paste0("--", n), a); if (is.na(i)) d else a[[i + 1L]] }
drapeau <- function(n) paste0("--", n) %in% a

trimestre <- verifier_trimestre(arg("quarter", Sys.getenv("ENE_QUARTER", "")))
ch <- chemins_apurement(trimestre, RACINE_DEPOT)
jusqua <- arg("jusqua", "QM_S1")
parite <- drapeau("parite"); ecrire <- drapeau("ecrire")
dossier_ref <- file.path(RACINE_DEPOT, "referentiels")
regles <- charger_regles(dossier_ref)
doublons <- utils::read.csv(file.path(dossier_ref, "doublons_a_supprimer.csv"),
                            colClasses = "character", encoding = "UTF-8")

cat(sprintf("Apurement ENE-M en R | trimestre %s | jusqu'à %s\n", trimestre, jusqua))
if (parite) {
  mq <- verifier_marqueur_reference(ch)
  cat("Référence Stata :", mq$message, "\n")
  if (!mq$ok) stop("Les sorties Stata de référence ne correspondent pas au trimestre demandé.")
}

synth <- list()
controler <- function(etape, nom, base_r, chemin_ref, cles) {
  if (!parite) return(invisible())
  if (!nzchar(chemin_ref) || !file.exists(chemin_ref)) {
    cat(sprintf("  [parité] %s/%s : référence absente (%s)\n", etape, nom, chemin_ref)); return(invisible())
  }
  res <- comparer_bases(base_r, haven::read_dta(chemin_ref), cles, paste0(etape, "__", nom))
  ecrire_rapport_parite(res, file.path(ch$sortie, "parite"))
  s <- synthese_parite(res); synth[[length(synth) + 1L]] <<- s
  cat(sprintf("  [parité] %-38s %-8s lignes %d/%d, vars en écart %d, cellules %d, ordre identique %s\n",
              s$base, s$statut, s$lignes_r, s$lignes_ref, s$vars_en_ecart, s$cellules_en_ecart, s$ordre_lignes_identique))
}
ref_inter <- function(etape, fichier) if (nzchar(ch$ref_inter)) file.path(ch$ref_inter, etape, fichier) else ""
controler_brute <- function(etape) {
  controler(etape, "membres", etat$membres, ref_inter(etape, "membres.dta"), c("interview__key", "membres__id"))
  controler(etape, "QX_EEC_VF", etat$menage, ref_inter(etape, "QX_EEC_VF.dta"), "interview__key")
  controler(etape, "r_activite_s", etat$r_activite_s, ref_inter(etape, "r_activite_s.dta"),
            c("interview__key", "membres__id", "r_activite_s__id"))
  controler(etape, "emigration", etat$emigration, ref_inter(etape, "emigration.dta"),
            c("interview__key", "emigration__id"))
}

ETAPES <- c("initialisation", "doublons", "non_residents", "nettoyage", "traitement_autres",
            "rename_label", "codification", "standard_db", "QM_S1")
if (!jusqua %in% ETAPES) stop("Étape inconnue : ", jusqua, " (", paste(ETAPES, collapse = ", "), ")")
faire <- function(e) match(e, ETAPES) <= match(jusqua, ETAPES)
chrono <- function(e, expr) { t0 <- Sys.time(); force(expr)
  cat(sprintf("- %-18s %6.1f s\n", e, as.numeric(difftime(Sys.time(), t0, units = "secs")))) }

chrono("initialisation", etat <- etape_initialisation(ch))
if (faire("doublons")) { chrono("doublons", etape_doublons(etat, doublons)); controler_brute("01_doublons") }
if (faire("non_residents")) { chrono("non_residents", etape_non_residents(etat)); controler_brute("02_non_residents") }
if (faire("nettoyage")) { chrono("nettoyage", etape_nettoyage(etat, regles)); controler_brute("03_nettoyage") }
if (faire("traitement_autres")) { chrono("traitement_autres", etape_traitement_autres(etat, regles, dossier_ref)); controler_brute("04_autres") }
if (faire("rename_label")) chrono("rename_label", etape_rename_label(etat))
if (faire("codification")) {
  chrono("codification", etape_codification(etat, ch, regles))
  controler_brute("05_codification")
  controler("brute_final", "membres", etat$membres, file.path(ch$ref_brute, "membres.dta"), c("interview__key", "membres__id"))
  controler("brute_final", "QX_EEC_VF", etat$menage, file.path(ch$ref_brute, "QX_EEC_VF.dta"), "interview__key")
}
if (faire("standard_db")) {
  chrono("standard_db", etape_standard_db(etat))
  for (s in names(etat$standard)) {
    cles <- if (s %in% c("QM_S0_identification", "QM_S7_logement")) "interview__key" else
      if (s == "QM_S5_emmigration") c("interview__key", "emigration__id") else c("interview__key", "membres__id")
    controler("standard_db", s, etat$standard[[s]], file.path(ch$ref_standard_in, paste0(s, ".dta")), cles)
  }
}
if (faire("QM_S1")) {
  chrono("QM_S1", etape_QM_S1(etat, regles, ch))
  controler("QM_S1", "QM_S1_composition_menage", etat$sortie_menage$QM_S1_composition_menage,
            file.path(ch$ref_standard_menage, "QM_S1_composition_menage.dta"), c("interview__key", "membres__id"))
}

if (ecrire) {
  ecrire_dta(etat$membres, file.path(ch$sortie, "brute", "membres.dta"))
  ecrire_dta(etat$menage, file.path(ch$sortie, "brute", "QX_EEC_VF.dta"))
  for (s in names(etat$sortie_menage)) ecrire_dta(etat$sortie_menage[[s]], file.path(ch$sortie, "standard", "menage", paste0(s, ".dta")))
}
if (length(synth)) {
  s <- do.call(rbind, synth)
  dir.create(file.path(ch$sortie, "parite"), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(s, file.path(ch$sortie, "parite", "synthese_parite.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  cat("\nSynthèse de parité :\n"); print(s[, c("base", "statut", "lignes_r", "lignes_ref", "vars_en_ecart", "cellules_en_ecart", "ordre_lignes_identique", "libelles_conformes")], row.names = FALSE)
}
