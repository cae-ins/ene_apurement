#!/usr/bin/env Rscript
# =============================================================================
# run_apurement.R : lance la chaîne d'apurement ENE-M portée en R.
#
#   Rscript --vanilla R/run_apurement.R --quarter T1_2026 [--jusqua <etape>]
#           [--parite | --parite-sections] [--cache] [--ecrire]
#
# --quarter  trimestre traité (obligatoire, forme TX_YYYY)
# --jusqua   dernière étape exécutée (défaut : dernière section portée)
# --parite   compare chaque base produite à sa référence Stata et écrit les
#            rapports dans <ENE_OUT_DIR>/parite/
# --parite-sections  idem, mais seulement pour les sections QM_*/INDIV_*
# --cache    réutilise l'état après standard_db (<ENE_OUT_DIR>/cache/)
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
for (f in c("do_parser.R", "stata_expr.R", "regles.R", "io.R", "anomalies.R", "stata_ops.R"))
  source(file.path(RACINE_DEPOT, "R", "lib", f), encoding = "UTF-8")
source(file.path(RACINE_DEPOT, "R", "parite.R"), encoding = "UTF-8")
for (f in sort(list.files(file.path(RACINE_DEPOT, "R", "etapes"), "\\.R$", full.names = TRUE)))
  source(f, encoding = "UTF-8")

a <- commandArgs(trailingOnly = TRUE)
arg <- function(n, d = NULL) { i <- match(paste0("--", n), a); if (is.na(i)) d else a[[i + 1L]] }
drapeau <- function(n) paste0("--", n) %in% a

trimestre <- verifier_trimestre(arg("quarter", Sys.getenv("ENE_QUARTER", "")))
ch <- chemins_apurement(trimestre, RACINE_DEPOT)
jusqua <- arg("jusqua", "QM_S6")
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
# --parite-sections : ne contrôle que les sections (étapes brutes et
# standard_db supposées déjà validées ; gain d'environ 10 minutes)
parite_sections_seules <- drapeau("parite-sections")
if (parite_sections_seules) parite <- TRUE
controler <- function(etape, nom, base_r, chemin_ref, cles, section = FALSE) {
  if (!parite || (parite_sections_seules && !section)) return(invisible())
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
            "rename_label", "codification", "standard_db", "QM_S1", "QM_S2", "QM_S3",
            "QM_S4", "QM_S5", "QM_S6")
if (!jusqua %in% ETAPES) stop("Étape inconnue : ", jusqua, " (", paste(ETAPES, collapse = ", "), ")")
faire <- function(e) match(e, ETAPES) <= match(jusqua, ETAPES)
chrono <- function(e, expr) { t0 <- Sys.time(); force(expr)
  cat(sprintf("- %-18s %6.1f s\n", e, as.numeric(difftime(Sys.time(), t0, units = "secs")))) }

# Cache de l'état après standard_db (--cache) : évite de rejouer les étapes
# brutes quand on travaille sur les sections. Invalidé si les règles changent.
cache_f <- file.path(ch$sortie, "cache", "etat_standard_db.rds")
empreinte <- unname(tools::md5sum(file.path(dossier_ref, c("recodages_texte.csv", "corrections_cas.csv",
                                                            "positions_in_resolues.csv"))))
depuis_cache <- drapeau("cache") && file.exists(cache_f) &&
  match(jusqua, ETAPES) > match("standard_db", ETAPES) && identical(readRDS(cache_f)$empreinte, empreinte)
if (depuis_cache) {
  etat <- list2env(readRDS(cache_f)$etat); cat("- état après standard_db lu depuis le cache\n")
  faire_brut <- function(e) FALSE
} else {
  faire_brut <- faire
  chrono("initialisation", etat <- etape_initialisation(ch))
}
if (faire_brut("doublons")) { chrono("doublons", etape_doublons(etat, doublons)); controler_brute("01_doublons") }
if (faire_brut("non_residents")) { chrono("non_residents", etape_non_residents(etat)); controler_brute("02_non_residents") }
if (faire_brut("nettoyage")) { chrono("nettoyage", etape_nettoyage(etat, regles)); controler_brute("03_nettoyage") }
if (faire_brut("traitement_autres")) { chrono("traitement_autres", etape_traitement_autres(etat, regles, dossier_ref)); controler_brute("04_autres") }
if (faire_brut("rename_label")) chrono("rename_label", etape_rename_label(etat))
if (faire_brut("codification")) {
  chrono("codification", etape_codification(etat, ch, regles))
  controler_brute("05_codification")
  controler("brute_final", "membres", etat$membres, file.path(ch$ref_brute, "membres.dta"), c("interview__key", "membres__id"))
  controler("brute_final", "QX_EEC_VF", etat$menage, file.path(ch$ref_brute, "QX_EEC_VF.dta"), "interview__key")
}
if (faire_brut("standard_db")) {
  chrono("standard_db", etape_standard_db(etat))
  for (s in names(etat$standard)) {
    cles <- if (s %in% c("QM_S0_identification", "QM_S7_logement")) "interview__key" else
      if (s == "QM_S5_emmigration") c("interview__key", "emigration__id") else c("interview__key", "membres__id")
    # Référence intermédiaire (état exact après standard_db.do) si disponible ;
    # sinon datain/standard du run complet, que les sections S3 et S6
    # réécrivent ensuite (écarts attendus pour ces deux bases).
    ref <- ref_inter("06_standard_db", paste0(s, ".dta"))
    if (!nzchar(ref) || !file.exists(ref)) ref <- file.path(ch$ref_standard_in, paste0(s, ".dta"))
    controler("standard_db", s, etat$standard[[s]], ref, cles)
  }
}
if (drapeau("cache") && !depuis_cache && faire("standard_db")) {
  dir.create(dirname(cache_f), recursive = TRUE, showWarnings = FALSE)
  saveRDS(list(empreinte = empreinte, etat = as.list(etat)), cache_f)
}
if (is.null(etat$sortie_menage)) etat$sortie_menage <- list()

# Sections : fonction R, base de sortie (dataout/standard/menage), clés
SECTIONS <- list(
  QM_S1 = list(f = function() etape_QM_S1(etat, regles, ch), sortie = "QM_S1_composition_menage"),
  QM_S2 = list(f = function() etape_QM_S2(etat, regles), sortie = "QM_S2_education_formation"),
  QM_S3 = list(f = function() etape_QM_S3(etat, regles), sortie = "QM_S3_formation_professionnelle"),
  QM_S4 = list(f = function() etape_QM_S4(etat, regles), sortie = "QM_S4_immigration"),
  QM_S5 = list(f = function() etape_QM_S5(etat, regles), sortie = "QM_S5_emmigration",
               cles = c("interview__key", "emigration__id")),
  QM_S6 = list(f = function() etape_QM_S6(etat, regles), sortie = "QM_S6_difficultes_fonctionnelles"))
for (sec in names(SECTIONS)) {
  if (!faire(sec)) next
  chrono(sec, SECTIONS[[sec]]$f())
  nom <- SECTIONS[[sec]]$sortie
  controler(sec, nom, etat$sortie_menage[[nom]], file.path(ch$ref_standard_menage, paste0(nom, ".dta")),
            SECTIONS[[sec]]$cles %||% c("interview__key", "membres__id"), section = TRUE)
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
