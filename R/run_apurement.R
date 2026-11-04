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
for (f in c("do_parser.R", "stata_expr.R", "regles.R", "io.R", "anomalies.R", "stata_ops.R", "interpreteur.R"))
  source(file.path(RACINE_DEPOT, "R", "lib", f), encoding = "UTF-8")
source(file.path(RACINE_DEPOT, "R", "parite.R"), encoding = "UTF-8")
for (f in sort(list.files(file.path(RACINE_DEPOT, "R", "etapes"), "\\.R$", full.names = TRUE)))
  source(f, encoding = "UTF-8")

a <- commandArgs(trailingOnly = TRUE)
arg <- function(n, d = NULL) { i <- match(paste0("--", n), a); if (is.na(i)) d else a[[i + 1L]] }
drapeau <- function(n) paste0("--", n) %in% a

trimestre <- verifier_trimestre(arg("quarter", Sys.getenv("ENE_QUARTER", "")))
ch <- chemins_apurement(trimestre, RACINE_DEPOT)
jusqua <- arg("jusqua", "fusion")
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
            "QM_S4", "QM_S5", "QM_S6", "QM_S7", "INDIV_S1", "INDIV_S2", "INDIV_S3", paste0("INDIV_S", 4:14), "fusion")
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
  QM_S6 = list(f = function() etape_QM_S6(etat, regles), sortie = "QM_S6_difficultes_fonctionnelles"),
  QM_S7 = list(f = function() etape_QM_S7(etat, regles), sortie = "QM_S7_logement", cles = "interview__key"))
SECTIONS$INDIV_S1 <- list(f = function() etape_INDIV_S1(etat, regles), sortie = "INDIV_S1_autres_formes_travail",
                          individu = TRUE)
# INDIV_S2 est réécrite par la section S3 : référence = état intermédiaire
# Stata après S2 (ENE_REF_DIR/07_indiv_S1_S2) si disponible.
SECTIONS$INDIV_S2 <- list(f = function() etape_INDIV_S2(etat, regles), sortie = "INDIV_S2_situation_emploi",
                          individu = TRUE, ref_inter = "07_indiv_S1_S2")
SECTIONS$INDIV_S3 <- list(f = function() etape_INDIV_S3(etat, regles), sortie = "INDIV_S3_emploi_principal",
  individu = TRUE, extra = function() {
    k2 <- c("interview__key", "membres__id")
    # INDIV_S2 après ses deux mises à jour par S3 = sortie finale Stata
    controler("INDIV_S3", "INDIV_S2_apres_S3", etat$sortie_individu$INDIV_S2_situation_emploi,
              file.path(ch$ref_standard_individu, "INDIV_S2_situation_emploi.dta"), k2, section = TRUE)
    controler("INDIV_S3", "datain_standard_INDIV_S3", etat$standard$INDIV_S3_emploi_principal,
              file.path(ch$ref_standard_in, "INDIV_S3_emploi_principal.dta"), k2, section = TRUE)
    controler("INDIV_S3", "Revenu", etat$sortie_rosters$Revenu, file.path(ch$ref_dataout, "Revenu.dta"),
              c(k2, "Revenu__id"), section = TRUE)
  })
# Sections INDIV_S4 à S14 : sortie dataout/standard/individu + rosters dataout/
cles_roster <- function(d) c("interview__key", setdiff(grep("__id$", names(d), value = TRUE), "interview__id"))
controler_rosters <- function(sec, noms) for (n in noms)
  controler(sec, n, etat$sortie_rosters[[n]], file.path(ch$ref_dataout, paste0(n, ".dta")),
            cles_roster(etat$sortie_rosters[[n]]), section = TRUE)
SORTIES_INDIV <- c(INDIV_S4 = "INDIV_S4_competences_qualifications", INDIV_S5 = "INDIV_S5_pluriactivite",
                   INDIV_S6 = "INDIV_S6_emploi_secondaire", INDIV_S7 = "INDIV_S7_temps_travail",
                   INDIV_S8 = "INDIV_S8_emploi_inadequat", INDIV_S9 = "INDIV_S9_recherche_emploi",
                   INDIV_S10 = "INDIV_S10_recherche_emploi_disponibilite", INDIV_S11 = "INDIV_S11_chomage",
                   INDIV_S12 = "INDIV_S12_emploi_anterieur", INDIV_S13 = "INDIV_S13_revenu_hors_emploi",
                   INDIV_S14 = "INDIV_S14_activite_parents")
ROSTERS_SECTION <- list(INDIV_S4 = "r_competence_quali", INDIV_S5 = "r_activite_s", INDIV_S6 = "Revenu_es",
                        INDIV_S13 = "r_revenu_h_emp", INDIV_S14 = "Activiteparent")
for (sec in names(SORTIES_INDIV)) local({
  s <- sec
  SECTIONS[[s]] <<- list(f = function() get(paste0("etape_", s))(etat, regles), sortie = SORTIES_INDIV[[s]],
    individu = TRUE, extra = function() {
      if (!is.null(ROSTERS_SECTION[[s]])) controler_rosters(s, ROSTERS_SECTION[[s]])
      if (s == "INDIV_S6")
        controler(s, "datain_standard_INDIV_S6", etat$standard$INDIV_S6_emploi_secondaire,
                  file.path(ch$ref_standard_in, "INDIV_S6_emploi_secondaire.dta"), c("interview__key", "membres__id"), section = TRUE)
    })
})
SECTIONS$fusion <- list(f = function() etape_fusion(etat), sortie = NULL, extra = function() {
  controler("fusion", "qx_eec_vf", etat$fusion_menage, file.path(ch$ref_dataout, "menage", "qx_eec_vf.dta"),
            "interview__key", section = TRUE)
  controler("fusion", "membres", etat$fusion_individu, file.path(ch$ref_dataout, "individu", "membres.dta"),
            c("interview__key", "membres__id"), section = TRUE)
})
for (sec in names(SECTIONS)) {
  if (!faire(sec)) next
  if (sec == "fusion") { chrono(sec, SECTIONS$fusion$f()); SECTIONS$fusion$extra(); next }
  chrono(sec, SECTIONS[[sec]]$f())
  S <- SECTIONS[[sec]]; nom <- S$sortie
  base_r <- if (isTRUE(S$individu)) etat$sortie_individu[[nom]] else etat$sortie_menage[[nom]]
  ref <- file.path(if (isTRUE(S$individu)) ch$ref_standard_individu else ch$ref_standard_menage, paste0(nom, ".dta"))
  if (!is.null(S$ref_inter)) {
    ri <- ref_inter(S$ref_inter, paste0(nom, ".dta"))
    if (nzchar(ri) && file.exists(ri)) ref <- ri else
      cat("  [parité] ", nom, " : référence intermédiaire absente, comparaison au run final (écarts attendus)\n")
  }
  controler(sec, nom, base_r, ref, S$cles %||% c("interview__key", "membres__id"), section = TRUE)
  if (!is.null(S$extra)) S$extra()
}

if (ecrire) {
  ecrire_dta(etat$membres, file.path(ch$sortie, "brute", "membres.dta"))
  ecrire_dta(etat$menage, file.path(ch$sortie, "brute", "QX_EEC_VF.dta"))
  for (s in names(etat$sortie_menage)) ecrire_dta(etat$sortie_menage[[s]], file.path(ch$sortie, "standard", "menage", paste0(s, ".dta")))
  for (s in names(etat$sortie_individu)) ecrire_dta(etat$sortie_individu[[s]], file.path(ch$sortie, "standard", "individu", paste0(s, ".dta")))
  for (s in names(etat$sortie_rosters)) ecrire_dta(etat$sortie_rosters[[s]], file.path(ch$sortie, paste0(s, ".dta")))
  if (!is.null(etat$fusion_menage)) ecrire_dta(etat$fusion_menage, file.path(ch$sortie, "menage", "qx_eec_vf.dta"))
  if (!is.null(etat$fusion_individu)) ecrire_dta(etat$fusion_individu, file.path(ch$sortie, "individu", "membres.dta"))
  writeLines(ch$trimestre, file.path(ch$sortie, "apurement_quarter.txt"))
}
if (length(synth)) {
  s <- do.call(rbind, synth)
  dir.create(file.path(ch$sortie, "parite"), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(s, file.path(ch$sortie, "parite", "synthese_parite.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  cat("\nSynthèse de parité :\n"); print(s[, c("base", "statut", "lignes_r", "lignes_ref", "vars_en_ecart", "cellules_en_ecart", "ordre_lignes_identique", "libelles_conformes")], row.names = FALSE)
}
