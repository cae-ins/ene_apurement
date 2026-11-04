# =============================================================================
# regles.R : découpage des instructions `replace` et application générique des
# tables de règles (referentiels/recodages_texte.csv, corrections_cas.csv).
# =============================================================================

#' Découpe le corps d'une instruction replace (préfixes déjà retirés).
#' Renvoie list(variable, valeur, condition) ; condition = "" si absente.
decouper_replace <- function(corps) {
  m <- regmatches(corps, regexec("^replace\\s+([\\p{L}_][\\p{L}\\p{N}_]*)\\s*=(?!=)\\s*(.*)$", corps, perl = TRUE))[[1]]
  if (!length(m)) stop("forme de replace non reconnue")
  var <- m[[2]]; reste <- m[[3]]
  # Qualificatif "in #" (une seule observation, désignée par sa position dans
  # l'ordre courant de la base) : conservé tel quel, appliqué par position.
  obs <- ""
  mi <- regmatches(reste, regexec("^(.*?)\\s+in\\s+([0-9]+)\\s*$", reste, perl = TRUE))[[1]]
  if (length(mi)) { reste <- mi[[2]]; obs <- mi[[3]] }
  # Recherche du mot-clé if de premier niveau (hors chaînes et parenthèses)
  ch <- strsplit(reste, "", fixed = TRUE)[[1]]
  prof <- 0L; dans_chaine <- FALSE; pos_if <- NA_integer_
  for (i in seq_along(ch)) {
    c1 <- ch[[i]]
    if (dans_chaine) { if (c1 == "\"") dans_chaine <- FALSE; next }
    if (c1 == "\"") { dans_chaine <- TRUE; next }
    if (c1 == "(") prof <- prof + 1L
    if (c1 == ")") prof <- prof - 1L
    if (prof == 0L && c1 == "i" && i + 1L <= length(ch) && ch[[i + 1L]] == "f" &&
        (i == 1L || grepl("[\\s)\"]", ch[[i - 1L]], perl = TRUE)) &&
        (i + 2L > length(ch) || grepl("[\\s(!~]", ch[[i + 2L]], perl = TRUE))) {
      pos_if <- i; break
    }
  }
  if (is.na(pos_if)) {
    valeur <- trimws(reste); cond <- ""
  } else {
    valeur <- trimws(paste(ch[seq_len(pos_if - 1L)], collapse = ""))
    cond <- trimws(paste(ch[(pos_if + 2L):length(ch)], collapse = ""))
  }
  if (grepl("(^|\\s)in\\s+[0-9f]", cond) || grepl(",\\s*(nopromote)?\\s*$", cond))
    stop("qualificatif in/options non pris en charge")
  if (!nzchar(valeur)) stop("valeur vide")
  list(variable = var, valeur = valeur, condition = cond, observation = obs)
}

# ---- Résolution des noms de variables (abréviations Stata) -------------------

#' Résout un nom de variable comme Stata (nom exact, sinon préfixe unique).
resoudre_variable <- function(nom, noms_base) {
  if (nom %in% noms_base) return(nom)
  cand <- noms_base[startsWith(noms_base, nom)]
  if (length(cand) == 1L) return(cand)
  if (!length(cand)) stop("variable ", nom, " introuvable", call. = FALSE)
  stop("abréviation ambiguë ", nom, call. = FALSE)
}

.cache_traduction <- new.env(parent = emptyenv())
traduire_cache <- function(s) {
  if (!nzchar(s)) return(NULL)
  r <- .cache_traduction[[s]]
  if (is.null(r)) { r <- traduire_expr_stata(s); assign(s, r, envir = .cache_traduction) }
  r
}

.env_fonctions <- function() environment(st_eq)

#' Évalue une expression Stata traduite sur un data.table.
evaluer_expr <- function(dt, e) {
  if (is.null(e)) return(NULL)
  vars <- all.vars(e)
  if (length(vars)) {
    noms <- names(dt)
    res <- vapply(vars, resoudre_variable, "", noms_base = noms)
    if (any(res != vars)) {
      e <- do.call(substitute, list(e, lapply(res, as.name)))
    }
  }
  v <- eval(e, envir = dt, enclos = .env_fonctions())
  v
}

#' Affecte val aux lignes idx de la colonne var, en conservant les attributs
#' (libellés haven) et en promouvant le type comme le ferait Stata.
affecter <- function(dt, var, idx, val) {
  if (!length(idx)) return(invisible(0L))
  # NB : data.table::set(i = ...) sur une colonne haven_labelled (classe vctrs)
  # produit des NA ; on modifie donc le vecteur sous-jacent puis on remet ses
  # attributs (libellés, classe) avant de remplacer la colonne entière.
  col <- dt[[var]]
  attrs <- attributes(col)
  # val est déjà aligné sur idx (longueur 1 ou length(idx))
  val <- rep_len(val, length(idx))
  if (is.character(col)) {
    if (!is.character(val)) stop("type mismatch : ", var, " est texte", call. = FALSE)
    x <- unclass(col)
  } else {
    if (is.character(val)) stop("type mismatch : ", var, " est numérique", call. = FALSE)
    x <- unclass(col)
    if (!is.double(x)) { x <- as.double(x); attrs$class <- attrs$class }
    val <- as.double(unclass(val))
  }
  attributes(x) <- NULL
  x[idx] <- val
  attributes(x) <- attrs
  data.table::set(dt, j = var, value = x)
  invisible(length(idx))
}

#' Applique une instruction replace Stata (variable, valeur, condition) à dt.
#' Renvoie le nombre de lignes concernées (équivalent de "real changes" au
#' sens large : lignes satisfaisant la condition).
appliquer_replace <- function(dt, variable, valeur, condition, capture = FALSE,
                              observation = "") {
  r <- tryCatch({
    var <- resoudre_variable(variable, names(dt))
    cond <- traduire_cache(condition)
    sel <- if (is.null(cond)) rep(TRUE, nrow(dt)) else st_vrai(evaluer_expr(dt, cond))
    if (!is.na(observation) && nzchar(observation)) {
      o <- as.integer(observation)
      if (o > nrow(dt)) stop("observation ", o, " hors limites (Stata : obs. nos. out of range)")
      sel <- sel & seq_len(nrow(dt)) == o
    }
    idx <- which(sel)
    if (length(idx)) {
      v <- evaluer_expr(dt, traduire_cache(valeur))
      if (length(v) > 1L) v <- v[idx] else v <- rep_len(v, length(idx))
      # changement réel : comparer à l'ancienne valeur (sémantique Stata)
      ancien <- dt[[var]][idx]
      chg <- if (is.character(ancien)) ancien != v else st_cle(ancien) != st_cle(v)
      affecter(dt, var, idx, v)
      sum(chg)
    } else 0L
  }, error = function(e) {
    if (capture) return(NA_integer_)
    stop(sprintf("replace %s = %s if %s : %s", variable, valeur, condition, conditionMessage(e)), call. = FALSE)
  })
  r
}

#' Applique, dans l'ordre (fichier_do, ligne), les règles actives d'une table
#' pour un fichier et une plage de lignes donnés.
appliquer_regles <- function(dt, regles, fichier, de = 0L, a = .Machine$integer.max,
                             journal = NULL) {
  r <- regles[regles$fichier_do == fichier & regles$ligne >= de & regles$ligne <= a &
                regles$statut == "actif", , drop = FALSE]
  r <- r[order(r$ligne), , drop = FALSE]
  n_chg <- integer(nrow(r))
  for (k in seq_len(nrow(r))) {
    n_chg[[k]] <- appliquer_replace(dt, r$variable[[k]], r$valeur_cible[[k]],
                                    r$condition[[k]], isTRUE(r$capture[[k]]),
                                    r$observation[[k]])
  }
  if (!is.null(journal)) {
    journal$ajouter(data.frame(id_regle = r$id_regle, changements = n_chg))
  }
  invisible(sum(n_chg, na.rm = TRUE))
}

#' Charge et fusionne les tables de règles applicables (recodages + corrections).
charger_regles <- function(dossier_ref) {
  lire <- function(f) {
    d <- utils::read.csv(file.path(dossier_ref, f), stringsAsFactors = FALSE,
                         encoding = "UTF-8", na.strings = character(0),
                         colClasses = "character")
    d$ligne <- as.integer(d$ligne)
    d$capture <- d$capture == "TRUE"
    d
  }
  rec <- lire("recodages_texte.csv")
  cor <- lire("corrections_cas.csv")
  cor$observation <- ""
  champs <- c("id_regle", "fichier_do", "ligne", "base", "variable", "valeur_cible",
              "condition", "observation", "capture", "statut")
  rbind(rec[, champs], cor[, champs])
}
