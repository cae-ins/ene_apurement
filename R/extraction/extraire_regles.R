#!/usr/bin/env Rscript
# =============================================================================
# extraire_regles.R : extrait des do-files Stata les règles de recodage, les
# corrections au cas par cas et la liste des doublons, vers referentiels/.
#
# Usage :
#   Rscript --vanilla R/extraction/extraire_regles.R --quarter T1_2026 \
#       [--program <dossier des do-files>] [--sortie referentiels]
# Par défaut, les do-files sont lus dans $ENE_DATA_DIR/program.
#
# Tables produites :
#   recodages_texte.csv      replace de premier niveau traduits (hors cas)
#   corrections_cas.csv      replace ciblant un interview__key précis
#   doublons_a_supprimer.csv identifiants d'entretiens doublons
#   regles_non_traduites.csv replace non traduits (boucles, _n, macros...)
#   inventaire_instructions.csv toutes les instructions modifiant les données
#   comptage_replace.csv     contrôle : replace actifs par fichier vs extraits
# =============================================================================

args_cli <- commandArgs(trailingOnly = TRUE)
arg <- function(nom, defaut = NULL) {
  i <- match(paste0("--", nom), args_cli)
  if (is.na(i)) defaut else args_cli[[i + 1L]]
}
racine <- normalizePath(file.path(dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))), "..", ".."), winslash = "/")
source(file.path(racine, "R", "lib", "do_parser.R"))
source(file.path(racine, "R", "lib", "stata_expr.R"))
source(file.path(racine, "R", "lib", "regles.R"))

trimestre <- arg("quarter", Sys.getenv("ENE_QUARTER", ""))
if (!grepl("^T[1-4]_[0-9]{4}$", trimestre)) stop("--quarter TX_YYYY obligatoire")
dossier_do <- arg("program", file.path(Sys.getenv("ENE_DATA_DIR"), "program"))
sortie <- arg("sortie", file.path(racine, "referentiels"))
dir.create(sortie, showWarnings = FALSE, recursive = TRUE)

# Ordre d'exécution : includes de apurement.do (non commentés)
ordre <- lire_instructions_do(file.path(dossier_do, "apurement.do"))
ordre <- ordre[ordre$commande == "include", ]
fichiers <- sub('.*/([^/"]+\\.do)".*', "\\1", ordre$corps)
cat(length(fichiers), "do-files inclus par apurement.do\n")

nom_base <- function(corps) {
  p <- sub("^use\\s+", "", corps)
  p <- sub(",.*$", "", p)
  p <- gsub("\"", "", p)
  if (grepl("\\$brute_menage_work", p)) return("QX_EEC_VF")
  b <- sub("\\.dta$", "", basename(gsub("\\\\", "/", trimws(p))))
  b
}

rec <- list(); cor <- list(); nt <- list(); inv <- list(); cpt <- list()
for (f in fichiers) {
  ins <- lire_instructions_do(file.path(dossier_do, f))
  # Base courante et sauvegarde effective de chaque bloc use ... save
  base <- rep(NA_character_, nrow(ins)); sauve <- rep(FALSE, nrow(ins))
  bloc <- integer(nrow(ins)); b_cour <- 0L; base_cour <- NA_character_
  est_save <- ins$commande == "save" | grepl("^save_brute_", ins$commande)
  for (i in seq_len(nrow(ins))) {
    if (ins$commande[[i]] == "use" && ins$contexte[[i]] == "") {
      b_cour <- b_cour + 1L; base_cour <- nom_base(ins$corps[[i]])
    }
    bloc[[i]] <- b_cour; base[[i]] <- base_cour
  }
  for (b in unique(bloc)) {
    sauve[bloc == b] <- any(est_save[bloc == b] & ins$contexte[bloc == b] == "")
  }
  ins$base <- base; ins$bloc <- bloc; ins$bloc_sauve <- sauve

  # Inventaire des instructions modifiant les données (hors lecture/contrôle)
  modif <- !(ins$commande %in% COMMANDES_LECTURE) & !grepl("^report_codif", ins$commande)
  inv[[f]] <- ins[modif, c("fichier_do", "ligne", "ligne_fin", "commande", "contexte",
                           "prefixe_by", "capture", "base", "bloc_sauve", "corps")]

  rp <- ins[ins$commande == "replace", ]
  n_ok <- 0L
  for (k in seq_len(nrow(rp))) {
    x <- rp[k, ]
    id <- sprintf("%s:%d", sub("\\.do$", "", f), x$ligne)
    raison <- ""
    if (x$contexte != "") raison <- paste0("dans un bloc (", x$contexte, ")")
    if (x$prefixe_by) raison <- "préfixe by"
    d <- NULL
    if (!nzchar(raison)) {
      d <- tryCatch(decouper_replace(x$corps), error = function(e) { raison <<- conditionMessage(e); NULL })
    }
    if (!is.null(d)) {
      ok <- tryCatch({ traduire_expr_stata(d$valeur)
        if (nzchar(d$condition)) traduire_expr_stata(d$condition); TRUE },
        error = function(e) { raison <<- conditionMessage(e); FALSE })
      if (!ok) d <- NULL
    }
    if (is.null(d)) {
      nt[[length(nt) + 1L]] <- data.frame(id_regle = id, fichier_do = f, ligne = x$ligne,
        ligne_fin = x$ligne_fin, raison = raison, texte = x$corps, stringsAsFactors = FALSE)
      next
    }
    n_ok <- n_ok + 1L
    statut <- if (!x$bloc_sauve) "bloc_non_sauvegarde" else "actif"
    cle <- regmatches(d$condition, regexec('interview__key\\s*==\\s*"([^"]+)"', d$condition))[[1]]
    if (length(cle)) {
      mid <- regmatches(d$condition, regexec("membres__id\\s*==\\s*([0-9]+)", d$condition))[[1]]
      cor[[length(cor) + 1L]] <- data.frame(id_regle = id, fichier_do = f, ligne = x$ligne,
        ligne_fin = x$ligne_fin, base = x$base, interview__key = cle[[2]],
        membres__id = if (length(mid)) mid[[2]] else "", variable = d$variable,
        valeur_cible = d$valeur, condition = d$condition, capture = x$capture,
        statut = statut, trimestre_origine = trimestre, stringsAsFactors = FALSE)
    } else {
      simple <- regmatches(d$condition, regexec('^\\(?\\s*([\\p{L}_][\\p{L}\\p{N}_]*)\\s*==\\s*"([^"]*)"\\s*\\)?$', d$condition, perl = TRUE))[[1]]
      rec[[length(rec) + 1L]] <- data.frame(id_regle = id, fichier_do = f, ligne = x$ligne,
        ligne_fin = x$ligne_fin, base = x$base, variable = d$variable, valeur_cible = d$valeur,
        variable_source = if (length(simple)) simple[[2]] else "",
        valeur_source = if (length(simple)) simple[[3]] else "",
        condition = d$condition, observation = d$observation,
        capture = x$capture, statut = statut, stringsAsFactors = FALSE)
    }
  }
  cpt[[f]] <- data.frame(fichier_do = f, replace_actifs = nrow(rp), extraits = n_ok,
                         non_traduits = nrow(rp) - n_ok, stringsAsFactors = FALSE)
}

ecrire <- function(l, nom) {
  d <- do.call(rbind, l)
  rownames(d) <- NULL
  utils::write.csv(d, file.path(sortie, nom), row.names = FALSE, fileEncoding = "UTF-8")
  cat(sprintf("%-30s %6d lignes\n", nom, nrow(d)))
  invisible(d)
}
ecrire(rec, "recodages_texte.csv")
ecrire(cor, "corrections_cas.csv")
ecrire(nt, "regles_non_traduites.csv")
ecrire(inv, "inventaire_instructions.csv")
ecrire(cpt, "comptage_replace.csv")

# ---- Doublons : listes des boucles foreach de 00-suppression_doublons.do -----
f <- "00-suppression_doublons.do"
brut <- readLines(file.path(dossier_do, f), encoding = "UTF-8", warn = FALSE)
ins <- lire_instructions_do(file.path(dossier_do, f))
fe <- ins[ins$commande == "foreach" & grepl("^foreach\\s+id\\s+in", ins$corps), ]
dbl <- list()
for (k in seq_len(nrow(fe))) {
  ids <- regmatches(fe$corps[[k]], gregexpr('"[^"]+"', fe$corps[[k]]))[[1]]
  ids <- gsub('"', "", ids)
  avant <- brut[seq_len(fe$ligne[[k]] - 1L)]
  coh <- grep("Cohorte", avant, value = TRUE)
  coh <- if (length(coh)) trimws(gsub("^\\s*\\*\\s*", "", coh[[length(coh)]])) else ""
  dbl[[k]] <- data.frame(interview__key = ids, cohorte = coh, fichier_do = f,
                         ligne = fe$ligne[[k]], stringsAsFactors = FALSE)
}
d <- ecrire(dbl, "doublons_a_supprimer.csv")
cat("Doublons distincts :", length(unique(d$interview__key)), "\n")
