# =============================================================================
# stata_expr.R : traduction d'expressions Stata en expressions R, et fonctions
# R reproduisant la sémantique Stata.
#
# Points de sémantique reproduits :
# - les valeurs manquantes numériques (., .a ... .z) sont plus grandes que tout
#   nombre et ordonnées entre elles (. < .a < .b ...) ; x > 5 est vrai si x est
#   manquant, x != 3 aussi ;
# - une condition est vraie si sa valeur est non nulle (un manquant est vrai) ;
# - la chaîne vide "" est la valeur manquante des variables texte ;
# - lower()/upper() ne traitent que l'ASCII ; regexm() travaille sur les octets ;
# - la division par zéro et toute opération sur un manquant donnent "." ;
# - priorité des opérateurs : ! > ^ > - unaire > * / > + - > relationnels > & > |.
# Les manquants étendus sont lus par haven comme des NA étiquetés (tagged_na).
# =============================================================================

.GRAND <- 1e300   # clé de tri du manquant "." ; .a = .GRAND * 2, etc.

# Rang Stata d'un manquant : "." -> 0, ".a" -> 1 ... ".z" -> 26
.rang_manquant <- function(x) {
  tag <- haven::na_tag(x)
  r <- match(tag, letters)
  r[is.na(r)] <- 0
  r
}

#' Clé numérique comparable reproduisant l'ordre Stata (manquants en dernier).
st_cle <- function(x) {
  if (is.character(x)) return(x)
  v <- as.double(unclass(x))
  na <- is.na(v)
  if (any(na)) v[na] <- .GRAND * (1 + .rang_manquant(v[na]))
  v
}

#' Manquant Stata littéral ("" = ".", "a" = ".a").
st_manquant <- function(tag = "") {
  if (identical(tag, "")) NA_real_ else haven::tagged_na(tag)
}

.verifier_types <- function(a, b, op) {
  if (is.character(a) != is.character(b))
    stop("type mismatch (", op, ") : comparaison texte / numérique", call. = FALSE)
}

.comparer <- function(a, b, f, op) {
  .verifier_types(a, b, op)
  as.double(f(st_cle(a), st_cle(b)))
}
st_eq <- function(a, b) .comparer(a, b, `==`, "==")
st_ne <- function(a, b) .comparer(a, b, `!=`, "!=")
st_gt <- function(a, b) .comparer(a, b, `>`, ">")
st_lt <- function(a, b) .comparer(a, b, `<`, "<")
st_ge <- function(a, b) .comparer(a, b, `>=`, ">=")
st_le <- function(a, b) .comparer(a, b, `<=`, "<=")

#' Valeur de vérité Stata : non nul (manquant compris) = vrai.
st_vrai <- function(x) {
  if (is.character(x)) stop("type mismatch : condition sur une chaîne", call. = FALSE)
  v <- as.double(unclass(x))
  is.na(v) | v != 0
}
st_and <- function(a, b) as.double(st_vrai(a) & st_vrai(b))
st_or  <- function(a, b) as.double(st_vrai(a) | st_vrai(b))
st_not <- function(a) as.double(!st_vrai(a))

.normaliser_na <- function(v) {
  v[is.na(v) | is.infinite(v)] <- NA_real_
  v
}
.num <- function(x) as.double(unclass(x))
st_add <- function(a, b) {
  if (is.character(a) || is.character(b)) {
    .verifier_types(a, b, "+")
    return(paste0(a, b))
  }
  .normaliser_na(.num(a) + .num(b))
}
st_sub <- function(a, b) .normaliser_na(.num(a) - .num(b))
st_mul <- function(a, b) .normaliser_na(.num(a) * .num(b))
st_div <- function(a, b) .normaliser_na(.num(a) / .num(b))
st_pow <- function(a, b) .normaliser_na(.num(a) ^ .num(b))
st_neg <- function(a) .normaliser_na(-.num(a))

.est_manquant <- function(x) if (is.character(x)) x == "" else is.na(unclass(x))

# ---- Fonctions Stata ---------------------------------------------------------
stf_missing <- function(...) {
  l <- list(...)
  r <- .est_manquant(l[[1]])
  for (x in l[-1]) r <- r | .est_manquant(x)
  as.double(r)
}
stf_mi <- stf_missing
stf_inlist <- function(x, ...) {
  r <- rep(0, length(x))
  for (v in list(...)) r <- pmax(r, st_eq(x, v))
  r
}
stf_inrange <- function(x, a, b) {
  # Vérifié sous Stata 17 : inrange(., 1, .) = 0 ; inrange(5, ., 10) = 1
  # (borne basse manquante = -infini, borne haute manquante = +infini).
  k <- st_cle(x)
  ba <- st_cle(a); ba[.est_manquant(a)] <- -Inf
  bb <- st_cle(b); bb[.est_manquant(b)] <- Inf
  as.double(ba <= k & k <= bb & !.est_manquant(x))
}
stf_regexm <- function(s, p) as.double(grepl(p, s, useBytes = TRUE))
stf_regexr <- function(s, p, r) sub(p, gsub("\\\\([0-9])", "\\\\\\1", r), s, useBytes = TRUE)
stf_ustrregexm <- function(s, p, noc = 0) {
  as.double(stringi::stri_detect_regex(s, p, case_insensitive = .num(noc) != 0))
}
stf_ustrregexra <- function(s, p, r, noc = 0) {
  stringi::stri_replace_all_regex(s, p, r, case_insensitive = .num(noc) != 0)
}
stf_ustrregexrf <- function(s, p, r, noc = 0) {
  stringi::stri_replace_first_regex(s, p, r, case_insensitive = .num(noc) != 0)
}
stf_lower <- function(s) chartr("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz", s)
stf_upper <- function(s) chartr("abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", s)
stf_strlower <- stf_lower
stf_strupper <- stf_upper
stf_ustrlower <- function(s, loc = "") stringi::stri_trans_tolower(s)
stf_ustrupper <- function(s, loc = "") stringi::stri_trans_toupper(s)
stf_trim <- function(s) gsub("^ +| +$", "", s)
stf_strtrim <- stf_trim
stf_ltrim <- function(s) gsub("^ +", "", s)
stf_strltrim <- stf_ltrim
stf_rtrim <- function(s) gsub(" +$", "", s)
stf_strrtrim <- stf_rtrim
stf_itrim <- function(s) gsub("  +", " ", s)
stf_stritrim <- stf_itrim
stf_ustrtrim <- function(s) stringi::stri_trim_both(s)
stf_ustrltrim <- function(s) stringi::stri_trim_left(s)
stf_ustrrtrim <- function(s) stringi::stri_trim_right(s)
stf_strlen <- function(s) as.double(nchar(s, type = "bytes"))
stf_length <- stf_strlen
stf_ustrlen <- function(s) as.double(nchar(s, type = "chars"))
stf_strpos <- function(s, t) {
  r <- regexpr(t, s, fixed = TRUE, useBytes = TRUE)
  as.double(ifelse(r < 0, 0, r))
}
stf_ustrpos <- function(s, t) {
  r <- stringi::stri_locate_first_fixed(s, t)[, 1]
  as.double(ifelse(is.na(r), 0, r))
}
.substr_octets <- function(s, n1, n2) {
  n1 <- rep_len(.num(n1), length(s)); n2 <- rep_len(.num(n2), length(s))
  vapply(seq_along(s), function(i) {
    b <- charToRaw(enc2utf8(s[[i]])); L <- length(b)
    d <- n1[[i]]; if (d < 0) d <- L + d + 1
    if (is.na(d) || d < 1 || d > L) return("")
    f <- if (is.na(n2[[i]])) L else min(L, d + n2[[i]] - 1)
    if (f < d) return("")
    r <- rawToChar(b[d:f]); Encoding(r) <- "UTF-8"; r
  }, character(1))
}
stf_substr <- function(s, n1, n2) .substr_octets(s, n1, n2)
stf_usubstr <- function(s, n1, n2) {
  n1 <- .num(n1); n2 <- .num(n2)
  L <- nchar(s)
  d <- ifelse(n1 < 0, L + n1 + 1, n1)
  f <- ifelse(is.na(n2), L, d + n2 - 1)
  substr(s, d, f)
}
stf_subinstr <- function(s, a, b, n) {
  n <- .num(n)
  if (length(n) == 1 && is.na(n)) return(gsub(a, b, s, fixed = TRUE, useBytes = TRUE))
  r <- s
  for (k in seq_len(max(n))) r <- sub(a, b, r, fixed = TRUE, useBytes = TRUE)
  r
}
stf_usubinstr <- stf_subinstr
stf_real <- function(s) suppressWarnings(as.double(trimws(s)))
stf_string <- function(x, fmt = NULL) {
  v <- .num(x)
  r <- ifelse(is.na(v), ".", format(v, scientific = FALSE, trim = TRUE, drop0trailing = TRUE))
  r
}
stf_strofreal <- stf_string
stf_int <- function(x) .normaliser_na(trunc(.num(x)))
stf_floor <- function(x) .normaliser_na(floor(.num(x)))
stf_ceil <- function(x) .normaliser_na(ceiling(.num(x)))
stf_abs <- function(x) .normaliser_na(abs(.num(x)))
stf_round <- function(x, y = 1) {
  # Vérifié sous Stata 17 : round(-2.5) = -2 (arrondi vers +infini à 0,5)
  v <- .num(x); y <- .num(y)
  .normaliser_na(floor(v / y + 0.5) * y)
}
stf_mod <- function(x, y) .normaliser_na(.num(x) - .num(y) * floor(.num(x) / .num(y)))
stf_max <- function(...) {
  m <- do.call(pmax, c(lapply(list(...), .num), na.rm = TRUE))
  .normaliser_na(m)
}
stf_min <- function(...) {
  m <- do.call(pmin, c(lapply(list(...), .num), na.rm = TRUE))
  .normaliser_na(m)
}
stf_cond <- function(c, a, b, m) {
  n <- max(length(c), length(a), length(b))
  a <- rep_len(a, n); b <- rep_len(b, n)
  r <- ifelse(st_vrai(rep_len(c, n)), a, b)
  if (!missing(m)) {
    mi <- .est_manquant(rep_len(c, n))
    r[mi] <- rep_len(m, n)[mi]
  }
  r
}
stf_word <- function(s, n) {
  n <- .num(n)
  vapply(strsplit(s, " +"), function(w) { w <- w[nzchar(w)]; if (n[[1]] <= length(w) && n[[1]] >= 1) w[[n[[1]]]] else "" }, "")
}

# ---- Analyse lexicale et syntaxique ----------------------------------------------

.re_ident <- "^[\\p{L}_][\\p{L}\\p{N}_]*"

decouper_jetons <- function(s) {
  j <- list()
  i <- 1L
  n <- nchar(s)
  while (i <= n) {
    reste <- substr(s, i, n)
    if (grepl("^\\s", reste)) { i <- i + 1L; next }
    if (startsWith(reste, "`\"")) {
      f <- regexpr("\"'", reste, fixed = TRUE)
      if (f < 0) stop("chaîne composée non terminée")
      j[[length(j) + 1L]] <- list(t = "chaine", v = substr(reste, 3, f - 1))
      i <- i + f + 1L; next
    }
    if (startsWith(reste, "\"")) {
      f <- regexpr("\"", substr(reste, 2, nchar(reste)), fixed = TRUE)
      if (f < 0) stop("chaîne non terminée")
      # Vérifié sous Stata 17 : deux littéraux accolés ("B""Z") valent le
      # premier seul dans une expression ; le second est ignoré.
      prec <- if (length(j)) j[[length(j)]] else list(t = "")
      if (!identical(prec$t, "chaine") || !isTRUE(prec$colle_suivant))
        j[[length(j) + 1L]] <- list(t = "chaine", v = substr(reste, 2, f))
      i <- i + f + 1L
      j[[length(j)]]$colle_suivant <- (i <= n && substr(s, i, i) == "\"")
      next
    }
    m <- regmatches(reste, regexpr("^(\\d+\\.?\\d*|\\.\\d+)([eE][-+]?\\d+)?", reste, perl = TRUE))
    if (length(m)) {
      j[[length(j) + 1L]] <- list(t = "nombre", v = as.numeric(m))
      i <- i + nchar(m); next
    }
    m <- regmatches(reste, regexpr("^\\.[a-z]?(?![\\p{L}\\p{N}_])", reste, perl = TRUE))
    if (length(m)) {
      j[[length(j) + 1L]] <- list(t = "manquant", v = substr(m, 2, 2))
      i <- i + nchar(m); next
    }
    m <- regmatches(reste, regexpr(.re_ident, reste, perl = TRUE))
    if (length(m)) {
      j[[length(j) + 1L]] <- list(t = "ident", v = m)
      i <- i + nchar(m); next
    }
    op2 <- substr(reste, 1, 2)
    # Vérifié sous Stata 17 : "||" est accepté comme "|" dans une condition if
    # (mais "&&" est une erreur de syntaxe).
    if (op2 == "||") {
      j[[length(j) + 1L]] <- list(t = "op", v = "|")
      i <- i + 2L; next
    }
    if (op2 %in% c("==", "!=", "~=", ">=", "<=")) {
      j[[length(j) + 1L]] <- list(t = "op", v = if (op2 == "~=") "!=" else op2)
      i <- i + 2L; next
    }
    c1 <- substr(reste, 1, 1)
    if (c1 %in% c("<", ">", "!", "~", "&", "|", "+", "-", "*", "/", "^", "(", ")", ",", "[", "]", "=")) {
      j[[length(j) + 1L]] <- list(t = "op", v = if (c1 == "~") "!" else c1)
      i <- i + 1L; next
    }
    stop("caractère non reconnu : ", c1)
  }
  j
}

.bp <- c("|" = 1, "&" = 2, "==" = 3, "!=" = 3, ">" = 3, "<" = 3, ">=" = 3, "<=" = 3,
         "+" = 4, "-" = 4, "*" = 5, "/" = 5, "^" = 7)
.fn_bin <- c("|" = "st_or", "&" = "st_and", "==" = "st_eq", "!=" = "st_ne",
             ">" = "st_gt", "<" = "st_lt", ">=" = "st_ge", "<=" = "st_le",
             "+" = "st_add", "-" = "st_sub", "*" = "st_mul", "/" = "st_div", "^" = "st_pow")

#' Traduit une expression Stata (texte) en expression R (objet language).
#' Échoue (stop) sur toute construction non prise en charge : macros,
#' indices [_n], fonctions inconnues.
traduire_expr_stata <- function(s) {
  if (grepl("[`$]", gsub("`\"[^\"]*\"'|\"[^\"]*\"", "", s))) stop("macro Stata non résolue")
  jetons <- decouper_jetons(s)
  pos <- 1L
  voir <- function() if (pos <= length(jetons)) jetons[[pos]] else list(t = "fin", v = "")
  prendre <- function() { tk <- voir(); pos <<- pos + 1L; tk }
  attendre <- function(v) { tk <- prendre(); if (!(tk$t == "op" && tk$v == v)) stop("attendu '", v, "'") }

  prefixe <- function() {
    tk <- prendre()
    if (tk$t == "nombre") return(tk$v)
    if (tk$t == "chaine") return(tk$v)
    if (tk$t == "manquant") return(call("st_manquant", tk$v))
    if (tk$t == "op" && tk$v == "!") return(call("st_not", expr(8)))
    if (tk$t == "op" && tk$v == "-") return(call("st_neg", expr(6)))
    if (tk$t == "op" && tk$v == "+") return(expr(6))
    if (tk$t == "op" && tk$v == "(") { e <- expr(0); attendre(")"); return(e) }
    if (tk$t == "ident") {
      nx <- voir()
      if (nx$t == "op" && nx$v == "(") {
        prendre()
        args <- list()
        if (!(voir()$t == "op" && voir()$v == ")")) {
          repeat {
            args[[length(args) + 1L]] <- expr(0)
            if (voir()$t == "op" && voir()$v == ",") { prendre(); next }
            break
          }
        }
        attendre(")")
        nom <- paste0("stf_", tolower(tk$v))
        if (!exists(nom, mode = "function")) stop("fonction Stata non prise en charge : ", tk$v)
        return(as.call(c(as.name(nom), args)))
      }
      if (nx$t == "op" && nx$v == "[") stop("indice explicite [ ] non pris en charge")
      if (tk$v %in% c("_n", "_N")) stop("_n/_N non pris en charge")
      return(as.name(tk$v))
    }
    stop("jeton inattendu : ", tk$v)
  }
  expr <- function(rbp) {
    gauche <- prefixe()
    repeat {
      tk <- voir()
      if (tk$t != "op" || is.na(.bp[tk$v]) || .bp[[tk$v]] <= rbp) break
      prendre()
      # ^ est associatif à gauche dans Stata (2^3^2 = 64)
      droite <- expr(.bp[[tk$v]])
      gauche <- call(.fn_bin[[tk$v]], gauche, droite)
    }
    gauche
  }
  e <- expr(0)
  if (pos <= length(jetons)) stop("reste non analysé : ", voir()$v)
  e
}

#' Noms de variables référencés par une expression R traduite.
variables_expr <- function(e) {
  setdiff(all.vars(e), character(0))
}
