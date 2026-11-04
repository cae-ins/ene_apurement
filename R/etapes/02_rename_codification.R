# =============================================================================
# 02_rename_codification.R
#   Rename_label_var.do      -> etape_rename_label()
#   00-codification_brute.do -> etape_codification()
# =============================================================================

# do: Rename_label_var.do — préfixes des variables binaires issues des
# questions à choix multiples (foreach var of varlist <préfixe>*)
PREFIXES_BINAIRES <- c("EF16E__", "IM8__", "DIF3__", "EP6__", "EP31__", "EP24__", "WKI2__",
                       "R4__", "C12b__", "Q1_5__", "Q1_8__", "Q1_10__", "Q1_13__", "C12c__",
                       "DI4__", "CQ6__", "SRH12A__", "RHE__")

#' Pose un jeu de libellés de valeurs (label define/label values) sur une
#' colonne numérique en conservant son libellé de variable et son format.
poser_libelles_valeurs <- function(dt, var, libelles) {
  x <- dt[[var]]
  lab <- attr(x, "label", exact = TRUE); fmt <- attr(x, "format.stata", exact = TRUE)
  v <- as.double(unclass(x)); attributes(v) <- NULL
  nv <- haven::labelled(v, labels = libelles, label = lab)
  if (!is.null(fmt)) attr(nv, "format.stata") <- fmt
  data.table::set(dt, j = var, value = nv)
}

#' do: Rename_label_var.do — label define <var>_label 0 "Non" 1 "Oui", modify ;
#' label values <var> <var>_label, pour chaque variable des préfixes.
etape_rename_label <- function(etat) {
  m <- etat$membres
  for (p in PREFIXES_BINAIRES) {
    vars <- names(m)[startsWith(names(m), p)]
    if (!length(vars)) stop("Rename_label_var.do : aucune variable ", p, "* (Stata s'arrêterait)")
    for (v in vars) poser_libelles_valeurs(m, v, c(Non = 0, Oui = 1))
  }
  invisible(etat)
}

# ---- 00-codification_brute.do -------------------------------------------------

#' Lit une feuille Excel comme `import excel ..., firstrow` : types devinés
#' sur toute la colonne (texte dès qu'une cellule est du texte).
lire_excel_codif <- function(chemin, feuille = NULL) {
  if (!file.exists(chemin)) stop("Fichier de codification absent : ", chemin, call. = FALSE)
  d <- suppressMessages(readxl::read_excel(chemin, sheet = feuille %||% 1L, guess_max = 1e6,
                                           .name_repair = "minimal"))
  as.data.frame(d)
}

#' Colonne dont l'en-tête commence par `prefixe` (unique).
colonne <- function(d, prefixe) {
  k <- which(startsWith(names(d), prefixe))
  if (length(k) != 1L) stop("Colonne ", prefixe, " introuvable ou ambiguë")
  d[[k]]
}

#' destring, force : texte non numérique -> manquant.
destring_force <- function(x) if (is.character(x)) suppressWarnings(as.double(trimws(x))) else as.double(x)

verifier_isid <- function(d, cles, quoi) {
  if (anyDuplicated(d[, cles, drop = FALSE])) stop("isid échoue (", quoi, ") : doublons sur ", paste(cles, collapse = ","), call. = FALSE)
}

#' Emule `merge 1:1 interview__key membres__id using <d>` suivi de
#' `drop if _merge == 2` : les variables de `d` sont ajoutées en fin de base,
#' manquantes pour les individus sans correspondance.
fusionner_codif <- function(m, d, vars, libelles_var = NULL) {
  cle_m <- paste(m$interview__key, m$membres__id, sep = "\r")
  cle_d <- paste(d$interview__key, d$membres__id, sep = "\r")
  if (anyDuplicated(cle_d)) stop("merge 1:1 : clés en double dans la codification")
  idx <- match(cle_m, cle_d)
  for (v in vars) {
    x <- d[[v]][idx]
    if (is.character(x)) x[is.na(x)] <- ""
    if (!is.null(libelles_var[[v]])) attr(x, "label") <- libelles_var[[v]]
    data.table::set(m, j = v, value = x)
  }
  list(sans_correspondance = sum(is.na(idx)), hors_membres = sum(!cle_d %in% cle_m))
}

#' reshape wide <var>, i(interview__key membres__id) j(<j>) ; noms <prefixe><j>.
reshape_large <- function(d, var, j, prefixe) {
  js <- sort(unique(d[[j]]))
  base <- unique(d[, c("interview__key", "membres__id")])
  for (k in js) {
    s <- d[d[[j]] == k, ]
    base[[paste0(prefixe, k)]] <- s[[var]][match(paste(base$interview__key, base$membres__id),
                                                 paste(s$interview__key, s$membres__id))]
  }
  base
}

etape_codification <- function(etat, ch, regles) {
  m <- etat$membres
  dc <- ch$codification
  supprimer <- function(vars) for (v in intersect(vars, names(m))) m[, (v) := NULL]
  journal <- list()

  # ---- 1. CITP emploi principal (do: 00-codification_brute.do:49-70)
  x <- lire_excel_codif(file.path(dc, "codification_emploi_principal_T1_2026_cp.xlsx"), "Sheet1")
  d <- data.frame(interview__key = colonne(x, "Interview key"), membres__id = destring_force(colonne(x, "Id in membres")),
                  code_citp_emp_principal = destring_force(colonne(x, "code_citp_emp_principal")), stringsAsFactors = FALSE)
  d <- d[!is.na(d$interview__key) & d$interview__key != "", ]
  verifier_isid(d, c("interview__key", "membres__id"), "CITP principal")
  supprimer("code_citp_emp_principal")
  journal$citp_principal <- fusionner_codif(m, d, "code_citp_emp_principal")

  # ---- 2. CITP emploi secondaire (:73-94)
  x <- lire_excel_codif(file.path(dc, "codification_emploi_secondaire_T1_2026_cp.xlsx"), "Sheet1")
  d <- data.frame(interview__key = colonne(x, "Interview key"), membres__id = destring_force(colonne(x, "Id in membres")),
                  code_citp_emp_secondaire = destring_force(colonne(x, "code_citp_emp_secondaire")), stringsAsFactors = FALSE)
  d <- d[!is.na(d$interview__key) & d$interview__key != "", ]
  verifier_isid(d, c("interview__key", "membres__id"), "CITP secondaire")
  supprimer("code_citp_emp_secondaire")
  journal$citp_secondaire <- fusionner_codif(m, d, "code_citp_emp_secondaire")

  # ---- 3. CITP pluriactivité, reshape wide (:97-126)
  x <- lire_excel_codif(file.path(dc, "codification_autre_emploi_T1_2026_cp.xlsx"), "Sheet1")
  d <- data.frame(interview__key = colonne(x, "Interview key"), membres__id = destring_force(colonne(x, "Id in \"membres\"")),
                  j = colonne(x, "Id in r_activite_s"), v = destring_force(colonne(x, "code_citp_autre_emploi")),
                  stringsAsFactors = FALSE)
  d <- d[!is.na(d$interview__key) & d$interview__key != "", ]
  verifier_isid(d, c("interview__key", "membres__id", "j"), "CITP pluriactivité")
  w <- reshape_large(d, "v", "j", "pluriactivite")
  names(w) <- sub("^pluriactivite([0-9]+)$", "pluriactivite\\1_codif", names(w))
  supprimer(paste0("pluriactivite", 1:5, "_codif"))
  journal$citp_pluri <- fusionner_codif(m, w, setdiff(names(w), c("interview__key", "membres__id")))

  # ---- 4. CIAP emploi secondaire (:128-143)
  lire_ciap_sec <- function() {
    x <- lire_excel_codif(file.path(dc, "Activite_secondaire_T126.xlsx"), "Feuil1")
    d <- data.frame(interview__key = x$interview__key, membres__id = destring_force(x$membres__id),
                    CodeCIAPactivite_sec = as.character(x[["Code activité"]]), stringsAsFactors = FALSE)
    d$CodeCIAPactivite_sec[is.na(d$CodeCIAPactivite_sec)] <- ""
    d[!is.na(d$interview__key) & d$interview__key != "", ]
  }
  d <- lire_ciap_sec(); verifier_isid(d, c("interview__key", "membres__id"), "CIAP secondaire")
  supprimer("CodeCIAPactivite_sec")
  journal$ciap_sec <- fusionner_codif(m, d, "CodeCIAPactivite_sec")

  # ---- 5. CIAP pluriactivité, reshape wide (:146-161)
  lire_ciap_pluri <- function() {
    x <- lire_excel_codif(file.path(dc, "Pluriactivite_AllT126.xls"), "Sheet1")
    d <- data.frame(interview__key = x$interview__key, membres__id = destring_force(x$membres__id),
                    j = x$r_activite_s__id, v = as.character(x$Code), stringsAsFactors = FALSE)
    d$v[is.na(d$v)] <- ""
    d[!is.na(d$interview__key) & d$interview__key != "", ]
  }
  d <- lire_ciap_pluri(); verifier_isid(d, c("interview__key", "membres__id", "j"), "CIAP pluri")
  w <- reshape_large(d, "v", "j", "CodeCIAPactivite_pluri")
  supprimer(grep("^CodeCIAPactivite_pluri", names(m), value = TRUE))
  journal$ciap_pluri <- fusionner_codif(m, w, setdiff(names(w), c("interview__key", "membres__id")))

  # ---- 6. CIAP emploi principal : lu ici, fusionné après 3b/3c (:164-172)
  x <- lire_excel_codif(file.path(dc, "Codif_activite_principales_T126.xlsx"), "Feuil1")
  ciap_p <- data.frame(interview__key = x$interview__key, membres__id = destring_force(x$membres__id),
                       `CodeCIAPactivité` = as.character(x[["Code activité"]]), stringsAsFactors = FALSE, check.names = FALSE)
  ciap_p$`CodeCIAPactivité`[is.na(ciap_p$`CodeCIAPactivité`)] <- ""
  ciap_p <- ciap_p[!is.na(ciap_p$interview__key) & ciap_p$interview__key != "", ]
  verifier_isid(ciap_p, c("interview__key", "membres__id"), "CIAP principal")

  # ---- 3b / 3c : le do-file refait les fusions 4 et 5 (:174-203). Le
  # résultat est identique, mais les variables passent en fin de base.
  supprimer("CodeCIAPactivite_sec"); fusionner_codif(m, lire_ciap_sec(), "CodeCIAPactivite_sec")
  w <- reshape_large(lire_ciap_pluri(), "v", "j", "CodeCIAPactivite_pluri")
  supprimer(grep("^CodeCIAPactivite_pluri", names(m), value = TRUE))
  fusionner_codif(m, w, setdiff(names(w), c("interview__key", "membres__id")))

  # do: :205-209  fusion CIAP principal ; libellé de variable = en-tête Excel
  supprimer("CodeCIAPactivité")
  journal$ciap_principal <- fusionner_codif(m, ciap_p, "CodeCIAPactivité", list(`CodeCIAPactivité` = "Code activité"))

  # ---- 7. Branches (:213-236) : gen + règles extraites (replace) + libellés
  m[, Code_1er := stf_substr(`CodeCIAPactivité`, 1, 1)]
  m[, branche2 := ifelse(Code_1er != "", 99, NA_real_)]
  appliquer_regles(m, regles, "00-codification_brute.do", 214, 222)
  data.table::setattr(m[["branche2"]], "label", "Branche d'activité 2")
  poser_libelles_valeurs(m, "branche2", c("Secteur primaire" = 1, "Secteur secondaire" = 2,
                                          "Secteur tertiaire" = 3, "Non-classés" = 99))
  m[, branche1 := ifelse(Code_1er != "", 4, NA_real_)]
  appliquer_regles(m, regles, "00-codification_brute.do", 227, 235)
  data.table::setattr(m[["branche1"]], "label", "Branche d'activité 1")
  poser_libelles_valeurs(m, "branche1", c(Agriculture = 1, Industrie = 2, Commerce = 3, "Autre service" = 4))

  # ---- 8. Libellés CITP (:240-250) : définis entre preserve et restore, donc
  # annulés par restore ; `label values ... codification` (:259-261) pointe
  # vers un jeu inexistant. Aucun libellé de valeur n'est posé.
  # ---- 9. Libellés de variables (:263-269) ; les destring sont sans effet
  # (variables déjà numériques).
  data.table::setattr(m[["code_citp_emp_principal"]], "label", "Emploi principal codifié")
  data.table::setattr(m[["code_citp_emp_secondaire"]], "label", "Emploi secondaire codifié")
  data.table::setattr(m[["CodeCIAPactivite_sec"]], "label", "Activite secondaire codifiee (CIAP)")
  for (i in 1:5) {
    v <- paste0("pluriactivite", i, "_codif"); if (v %in% names(m)) data.table::setattr(m[[v]], "label", sprintf("Pluriactivité %d codifiée", i))
    v <- paste0("CodeCIAPactivite_pluri", i); if (v %in% names(m)) data.table::setattr(m[[v]], "label", sprintf("Activite %d de pluriactivite codifiee (CIAP)", i))
  }
  etat$membres <- m
  etat$journal_codification <- journal
  invisible(etat)
}
