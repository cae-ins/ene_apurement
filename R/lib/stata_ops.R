# =============================================================================
# stata_ops.R : équivalents R d'opérations Stata non génériques (merge, egen
# par groupe, nettoyage des chaînes), réutilisés par les sections.
# =============================================================================

#' Sous-ensemble de lignes d'une colonne en conservant ses attributs (libellé
#' de variable, format) : `[` de R les supprime sur un numérique simple.
extraire_lignes <- function(x, idx) {
  if (inherits(x, "vctrs_vctr")) return(x[idx])
  a <- attributes(x)
  y <- unclass(x)[idx]
  a$names <- NULL
  attributes(y) <- a
  y
}

#' Emule `merge <type> <cles> using <d>, keepus(<vars>)` suivi de
#' `drop if _merge != 3` : seules les lignes appariées sont gardées ; les
#' variables de `vars` absentes de la base maître sont ajoutées en fin de base
#' (une variable déjà présente garde la valeur de la base maître, comme Stata
#' sans l'option update). La base résultante est triée par les clés (tri
#' stable ; Stata trie sans garantie d'ordre entre ex aequo).
fusionner_garder_apparies <- function(m, d, cles, vars) {
  d <- data.table::as.data.table(d)
  vars <- unique(vapply(vars, resoudre_variable, "", noms_base = names(d)))
  # Stata ajoute les variables dans l'ordre de la base using, pas de keepus()
  ajout <- intersect(names(d), setdiff(vars, names(m)))
  cm <- do.call(paste, c(lapply(cles, function(k) as.character(m[[k]])), sep = "\r"))
  cd <- do.call(paste, c(lapply(cles, function(k) as.character(d[[k]])), sep = "\r"))
  if (anyDuplicated(cd)) stop("merge : clés non uniques dans la base using (", paste(cles, collapse = ","), ")")
  idx <- match(cm, cd)
  garde <- which(!is.na(idx))
  r <- m[garde]
  for (v in ajout) data.table::set(r, j = v, value = extraire_lignes(d[[v]], idx[garde]))
  data.table::setorderv(r, cles)
  r
}

#' Emule `merge 1:1 <cles> using <u>, update replace keep(1 3 4 5) nogen` :
#' pour les lignes appariées, toute valeur non manquante de `u` remplace celle
#' de la base maître (les manquants de `u` ne remplacent jamais) ; les lignes
#' propres à `u` sont écartées ; la base est triée par les clés.
fusion_update_replace <- function(m, u, cles, vars) {
  m <- data.table::copy(m)
  cm <- do.call(paste, c(lapply(cles, function(k) as.character(m[[k]])), sep = "\r"))
  cu <- do.call(paste, c(lapply(cles, function(k) as.character(u[[k]])), sep = "\r"))
  idx <- match(cm, cu)
  for (v in vars) {
    nv <- u[[v]][idx]
    remp <- !is.na(idx) & !st_vrai(stf_missing(nv))
    remp[is.na(remp)] <- FALSE
    if (any(remp)) affecter(m, v, which(remp), if (is.character(nv)) nv[remp] else as.double(unclass(nv))[remp])
  }
  data.table::setorderv(m, cles)
  m
}

#' egen <v> = max(x), by(g) : maximum des non manquants (manquant si aucun).
egen_max <- function(x, g) {
  v <- as.double(unclass(x)); attributes(v) <- NULL
  r <- stats::ave(v, g, FUN = function(z) { z <- z[!is.na(z)]; if (length(z)) max(z) else NA_real_ })
  r
}

#' egen <v> = total(x), by(g) : somme des non manquants (0 si aucun).
egen_total <- function(x, g) {
  v <- as.double(unclass(x)); attributes(v) <- NULL
  stats::ave(v, g, FUN = function(z) sum(z, na.rm = TRUE))
}

#' egen <v> = mode(x), by(g) : valeur la plus fréquente parmi les non
#' manquants ; manquant s'il y a plusieurs modes (comportement par défaut de
#' Stata, sans minmode/maxmode) ou aucun non manquant.
egen_mode <- function(x, g) {
  v <- as.double(unclass(x)); attributes(v) <- NULL
  stats::ave(v, g, FUN = function(z) {
    z <- z[!is.na(z)]
    if (!length(z)) return(NA_real_)
    t <- table(z); mx <- which(t == max(t))
    if (length(mx) > 1L) NA_real_ else as.double(names(t)[mx])
  })
}

#' egen <v> = <stat>(x) [if sel], [by(g)] : statistique calculée sur les seules
#' lignes `sel` (par groupe g, manquants de g formant un groupe), manquante
#' ailleurs. `stat` : "median" (moyenne des deux valeurs centrales si n pair,
#' comme Stata), "mode" (manquant si plusieurs modes), "max".
egen_si <- function(x, sel, stat, g = NULL) {
  v <- as.double(unclass(x)); attributes(v) <- NULL
  r <- rep(NA_real_, length(v))
  if (!any(sel)) return(r)
  gg <- if (is.null(g)) rep("", length(v)) else { k <- as.character(unclass(g)); k[is.na(k)] <- "<NA>"; k }
  f <- switch(stat,
    median = function(z) { z <- z[!is.na(z)]; if (length(z)) stats::median(z) else NA_real_ },
    max = function(z) { z <- z[!is.na(z)]; if (length(z)) max(z) else NA_real_ },
    min = function(z) { z <- z[!is.na(z)]; if (length(z)) min(z) else NA_real_ },
    total = function(z) sum(z, na.rm = TRUE),
    mean = function(z) { z <- z[!is.na(z)]; if (length(z)) mean(z) else NA_real_ },
    mode = function(z) { z <- z[!is.na(z)]; if (!length(z)) return(NA_real_)
      t <- table(z); m <- which(t == max(t)); if (length(m) > 1L) NA_real_ else as.double(names(t)[m]) })
  i <- which(sel)
  r[i] <- stats::ave(v[i], gg[i], FUN = f)
  # egen crée une variable float : arrondi en simple précision
  r[i] <- en_float(r[i])
  r
}

#' Arrondi en simple précision (type float de Stata).
en_float <- function(v) {
  ok <- !is.na(v)
  if (any(ok)) v[ok] <- readBin(writeBin(v[ok], raw(), size = 4), "double", n = sum(ok), size = 4)
  v
}

#' gen <v> = expr [if cond] : manquant hors condition.
gen_si <- function(valeur, condition) {
  v <- as.double(unclass(valeur)); attributes(v) <- NULL
  v[!condition] <- NA_real_
  v
}

#' Boucle `ds, has(type string)` + `replace v = ustrregexra(v, "\s+$", "")`
#' + `replace v = strltrim(v)` : blancs finaux (Unicode) puis espaces initiaux.
nettoyer_chaines <- function(dt) {
  for (v in names(dt)[vapply(dt, is.character, TRUE)]) {
    x <- dt[[v]]; a <- attributes(x)
    y <- stf_ltrim(stf_ustrregexra(x, "\\s+$", ""))
    y[is.na(x)] <- NA_character_
    attributes(y) <- a
    data.table::set(dt, j = v, value = y)
  }
  invisible(dt)
}

#' Supprime des variables si elles existent (cap drop).
supprimer_vars <- function(dt, vars) {
  v <- intersect(vars, names(dt))
  if (length(v)) dt[, (v) := NULL]
  invisible(dt)
}
