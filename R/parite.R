#!/usr/bin/env Rscript
# =============================================================================
# parite.R : banc de parité entre une base produite par R et la référence
# produite par Stata.
#
# Contrôles : nombre de lignes, unicité et correspondance des clés, ordre des
# lignes, variables présentes de part et d'autre, égalité valeur par valeur
# (manquants étendus .a/.b... compris), libellés de variables et de valeurs.
# Sorties : un rapport texte et deux CSV (synthèse par variable, échantillon
# de cellules divergentes).
#
# En ligne de commande :
#   Rscript --vanilla R/parite.R --r base_R.dta --ref base_Stata.dta \
#       --cles interview__key,membres__id --nom QM_S1 --sortie dossier
# =============================================================================

TOLERANCE_REL <- 1e-6   # écarts dus au stockage float de Stata (7 chiffres)

.cle_valeur <- function(x) {
  # représentation comparable : texte, ou nombre avec manquants étiquetés
  if (is.character(x)) return(list(v = x, tag = rep(NA_character_, length(x))))
  v <- as.double(unclass(x))
  tag <- ifelse(is.na(v), ifelse(is.na(haven::na_tag(v)), ".", paste0(".", haven::na_tag(v))), NA_character_)
  list(v = v, tag = tag)
}

#' Compare une colonne alignée ; renvoie un vecteur logique "différent" et
#' un vecteur "différent seulement au-delà de la précision float".
comparer_colonne <- function(a, b) {
  if (is.character(a) != is.character(b)) {
    return(list(diff = rep(TRUE, length(a)), diff_float = rep(FALSE, length(a)), type = TRUE))
  }
  if (is.character(a)) {
    a[is.na(a)] <- ""; b[is.na(b)] <- ""
    return(list(diff = a != b, diff_float = rep(FALSE, length(a)), type = FALSE))
  }
  ca <- .cle_valeur(a); cb <- .cle_valeur(b)
  na_a <- !is.na(ca$tag); na_b <- !is.na(cb$tag)
  d <- rep(FALSE, length(a))
  d[na_a != na_b] <- TRUE
  both_na <- na_a & na_b
  d[both_na] <- ca$tag[both_na] != cb$tag[both_na]
  ok <- !na_a & !na_b
  ecart <- abs(ca$v[ok] - cb$v[ok])
  exact <- ecart == 0
  proche <- ecart <= TOLERANCE_REL * pmax(1, abs(cb$v[ok]))
  df <- rep(FALSE, length(a))
  d[ok] <- !proche
  df[ok] <- !exact & proche
  list(diff = d, diff_float = df, type = FALSE)
}

.libelles_valeurs <- function(x) {
  l <- attr(x, "labels", exact = TRUE)
  if (is.null(l)) return("")
  paste(paste0(unclass(l), "=", names(l)), collapse = "|")
}

#' Compare deux bases. Renvoie une liste (synthese, variables, cellules).
comparer_bases <- function(r, ref, cles, nom = "base", max_cellules = 20L) {
  r <- data.table::as.data.table(r); ref <- data.table::as.data.table(ref)
  res <- list(nom = nom, n_r = nrow(r), n_ref = nrow(ref), cles = cles)
  manq_cles <- setdiff(cles, intersect(names(r), names(ref)))
  if (length(manq_cles)) stop("Clés absentes : ", paste(manq_cles, collapse = ","))
  kr <- do.call(paste, c(lapply(cles, function(k) as.character(r[[k]])), sep = "\r"))
  kf <- do.call(paste, c(lapply(cles, function(k) as.character(ref[[k]])), sep = "\r"))
  res$doublons_cles_r <- sum(duplicated(kr)); res$doublons_cles_ref <- sum(duplicated(kf))
  res$cles_seulement_r <- sum(!kr %in% kf); res$cles_seulement_ref <- sum(!kf %in% kr)
  communs <- intersect(kr, kf)
  res$cles_communes <- length(communs)
  # ordre des lignes : même séquence de clés ?
  res$ordre_identique <- length(kr) == length(kf) && all(kr == kf)
  vr <- names(r); vf <- names(ref)
  res$vars_seulement_r <- setdiff(vr, vf); res$vars_seulement_ref <- setdiff(vf, vr)
  res$ordre_variables_identique <- identical(vr[vr %in% vf], vf[vf %in% vr])
  ir <- match(communs, kr); iff <- match(communs, kf)
  vars <- intersect(vf, vr)
  lignes <- vector("list", length(vars)); cell <- list()
  for (j in seq_along(vars)) {
    v <- vars[[j]]
    a <- r[[v]][ir]; b <- ref[[v]][iff]
    cmp <- comparer_colonne(a, b)
    nd <- sum(cmp$diff)
    lab_r <- attr(r[[v]], "label", exact = TRUE); lab_f <- attr(ref[[v]], "label", exact = TRUE)
    lignes[[j]] <- data.frame(
      variable = v, type_r = if (is.character(r[[v]])) "texte" else "num",
      type_ref = if (is.character(ref[[v]])) "texte" else "num",
      ecarts = nd, ecarts_float = sum(cmp$diff_float),
      libelle_identique = identical(as.character(lab_r %||% ""), as.character(lab_f %||% "")),
      libelles_valeurs_identiques = identical(.libelles_valeurs(r[[v]]), .libelles_valeurs(ref[[v]])),
      stringsAsFactors = FALSE)
    if (nd > 0) {
      k <- head(which(cmp$diff), max_cellules)
      fmt <- function(x) if (is.character(x)) x else {
        cv <- .cle_valeur(x); ifelse(is.na(cv$tag), format(cv$v, digits = 15), cv$tag) }
      cell[[length(cell) + 1L]] <- data.frame(variable = v, cle = gsub("\r", "|", communs[k]),
        valeur_r = fmt(a[k]), valeur_ref = fmt(b[k]), stringsAsFactors = FALSE)
    }
  }
  res$variables <- do.call(rbind, lignes)
  res$cellules <- if (length(cell)) do.call(rbind, cell) else
    data.frame(variable = character(0), cle = character(0), valeur_r = character(0), valeur_ref = character(0))
  res$vars_en_ecart <- sum(res$variables$ecarts > 0)
  res$cellules_en_ecart <- sum(res$variables$ecarts)
  res$conforme <- res$n_r == res$n_ref && res$cles_seulement_r == 0 && res$cles_seulement_ref == 0 &&
    res$doublons_cles_r == 0 && !length(res$vars_seulement_r) && !length(res$vars_seulement_ref) &&
    res$vars_en_ecart == 0
  res$libelles_conformes <- all(res$variables$libelle_identique) && all(res$variables$libelles_valeurs_identiques)
  res
}

`%||%` <- function(a, b) if (is.null(a)) b else a

#' Ligne de synthèse (data.frame d'une ligne) d'un résultat de comparaison.
synthese_parite <- function(res) {
  data.frame(base = res$nom, lignes_r = res$n_r, lignes_ref = res$n_ref,
             cles_seulement_r = res$cles_seulement_r, cles_seulement_ref = res$cles_seulement_ref,
             vars_seulement_r = length(res$vars_seulement_r), vars_seulement_ref = length(res$vars_seulement_ref),
             vars_en_ecart = res$vars_en_ecart, cellules_en_ecart = res$cellules_en_ecart,
             cellules_ecart_float = sum(res$variables$ecarts_float),
             ordre_lignes_identique = res$ordre_identique,
             libelles_conformes = res$libelles_conformes,
             statut = if (res$conforme) "CONFORME" else "ECART", stringsAsFactors = FALSE)
}

#' Écrit rapport texte + CSV d'une comparaison.
ecrire_rapport_parite <- function(res, dossier) {
  dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
  base <- file.path(dossier, paste0("parite_", res$nom))
  utils::write.csv(res$variables, paste0(base, "_variables.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  utils::write.csv(res$cellules, paste0(base, "_cellules.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  ec <- res$variables[res$variables$ecarts > 0, ]
  txt <- c(
    sprintf("Parité %s  (clés : %s)", res$nom, paste(res$cles, collapse = ", ")),
    sprintf("Statut : %s", if (res$conforme) "CONFORME" else "ECART"),
    sprintf("Lignes R / Stata : %d / %d ; clés communes : %d ; seulement R : %d ; seulement Stata : %d",
            res$n_r, res$n_ref, res$cles_communes, res$cles_seulement_r, res$cles_seulement_ref),
    sprintf("Doublons de clés R / Stata : %d / %d ; ordre des lignes identique : %s",
            res$doublons_cles_r, res$doublons_cles_ref, res$ordre_identique),
    sprintf("Variables seulement R (%d) : %s", length(res$vars_seulement_r), paste(head(res$vars_seulement_r, 30), collapse = " ")),
    sprintf("Variables seulement Stata (%d) : %s", length(res$vars_seulement_ref), paste(head(res$vars_seulement_ref, 30), collapse = " ")),
    sprintf("Ordre des variables identique : %s", res$ordre_variables_identique),
    sprintf("Variables comparées : %d ; en écart : %d ; cellules en écart : %d ; écarts float tolérés : %d",
            nrow(res$variables), res$vars_en_ecart, res$cellules_en_ecart, sum(res$variables$ecarts_float)),
    sprintf("Libellés de variables différents : %d ; libellés de valeurs différents : %d",
            sum(!res$variables$libelle_identique), sum(!res$variables$libelles_valeurs_identiques)),
    if (nrow(ec)) c("Variables en écart :", sprintf("  %-35s %7d", ec$variable, ec$ecarts)) else character(0)
  )
  writeLines(txt, paste0(base, ".txt"), useBytes = FALSE)
  invisible(txt)
}

# ---- Exécution en ligne de commande -------------------------------------------
if (sys.nframe() == 0L && !interactive()) {
  a <- commandArgs(trailingOnly = TRUE)
  arg <- function(n, d = NULL) { i <- match(paste0("--", n), a); if (is.na(i)) d else a[[i + 1L]] }
  lire <- function(p) if (grepl("\\.parquet$", p)) arrow::read_parquet(p) else haven::read_dta(p)
  res <- comparer_bases(lire(arg("r")), lire(arg("ref")), strsplit(arg("cles"), ",")[[1]], arg("nom", "base"))
  cat(ecrire_rapport_parite(res, arg("sortie", ".")), sep = "\n")
  quit(status = if (res$conforme) 0 else 1)
}
