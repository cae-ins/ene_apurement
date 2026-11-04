# =============================================================================
# interpreteur.R : exécute une plage de lignes d'un do-file, instruction par
# instruction, pour les commandes simples et génériques :
#   replace            -> règle extraite (referentiels/) de même ligne
#   gen/generate [float|double] v = expr [if cond]
#   [bysort g:] egen v = median|mode|max|min|total|mean|rownonmiss(...) [if c] [, by(g)]
#   [cap] drop varlist (cap : tout ou rien, comme Stata) ; drop if / keep if
#   order v, after(w)|before(w) ; label var v "..."
#   commandes de lecture/contrôle (count, ta, export, display…) : ignorées
# Toute autre commande (merge, use, save, preserve…) arrête l'exécution : elle
# doit être portée à la main en dehors des plages interprétées.
# =============================================================================

.dossier_do <- function() file.path(Sys.getenv("ENE_DATA_DIR"), "program")
.cache_instr <- new.env(parent = emptyenv())
instructions_do <- function(fichier) {
  if (is.null(.cache_instr[[fichier]]))
    assign(fichier, lire_instructions_do(file.path(.dossier_do(), fichier)), envir = .cache_instr)
  .cache_instr[[fichier]]
}

.eval_s <- function(d, s) evaluer_expr(d, traduire_expr_stata(s))

#' Découpe "x [if cond] [, opts]" au premier niveau (hors chaînes/parenthèses).
.decouper_if_options <- function(s) {
  ch <- strsplit(s, "", fixed = TRUE)[[1]]; prof <- 0L; dq <- FALSE; pif <- NA; pvir <- NA
  for (i in seq_along(ch)) {
    c1 <- ch[[i]]
    if (dq) { if (c1 == "\"") dq <- FALSE; next }
    if (c1 == "\"") { dq <- TRUE; next }
    if (c1 == "(") prof <- prof + 1L else if (c1 == ")") prof <- prof - 1L
    if (prof == 0L && is.na(pvir) && c1 == ",") pvir <- i
    if (prof == 0L && is.na(pif) && is.na(pvir) && c1 == "i" && i < length(ch) && ch[[i + 1L]] == "f" &&
        (i == 1L || grepl("[\\s)]", ch[[i - 1L]], perl = TRUE)) &&
        (i + 2L > length(ch) || grepl("[\\s(!]", ch[[i + 2L]], perl = TRUE))) pif <- i
  }
  fin_x <- min(c(pif, pvir, length(ch) + 1L), na.rm = TRUE) - 1L
  x <- trimws(paste(ch[seq_len(fin_x)], collapse = ""))
  cond <- if (is.na(pif)) "" else trimws(paste(ch[(pif + 2L):(if (is.na(pvir)) length(ch) else pvir - 1L)], collapse = ""))
  opts <- if (is.na(pvir)) "" else trimws(paste(ch[(pvir + 1L):length(ch)], collapse = ""))
  list(x = x, cond = cond, opts = opts)
}

.cle_groupe <- function(d, vars) {
  if (!length(vars)) return(NULL)
  do.call(paste, c(lapply(vars, function(v) { k <- as.character(unclass(d[[v]])); k[is.na(k)] <- "<NA>"; k }), sep = "\r"))
}

.egen <- function(d, corps, by_prefixe) {
  m <- regmatches(corps, regexec("^egen\\s+(?:(float|double|byte|int|long)\\s+)?(\\w+)\\s*=\\s*(\\w+)\\((.*)$", corps, perl = TRUE))[[1]]
  if (!length(m)) stop("egen non reconnu : ", corps)
  type <- m[[2]]; v <- m[[3]]; f <- m[[4]]
  # argument entre parenthèses (équilibrées)
  reste <- m[[5]]; ch <- strsplit(reste, "", fixed = TRUE)[[1]]; prof <- 1L; k <- 0L
  for (i in seq_along(ch)) { if (ch[[i]] == "(") prof <- prof + 1L; if (ch[[i]] == ")") prof <- prof - 1L; if (prof == 0L) { k <- i; break } }
  argument <- paste(ch[seq_len(k - 1L)], collapse = "")
  io <- .decouper_if_options(paste(ch[-seq_len(k)], collapse = ""))
  sel <- if (nzchar(io$cond)) st_vrai(.eval_s(d, io$cond)) else rep(TRUE, nrow(d))
  by <- by_prefixe
  mb <- regmatches(io$opts, regexec("by\\(([^)]*)\\)", io$opts))[[1]]
  if (length(mb)) by <- c(by, resoudre_varlist(mb[[2]], names(d)))
  autres <- trimws(gsub("by\\([^)]*\\)", "", io$opts))
  if (nzchar(autres)) stop("option egen non prise en charge : ", autres)
  g <- .cle_groupe(d, by)
  if (f == "rownonmiss") {
    r <- rownonmiss(d, argument); r[!sel] <- NA_real_
  } else {
    x <- .eval_s(d, argument)
    stat <- switch(f, median = "median", mode = "mode", max = "max", min = "min",
                   total = "total", sum = "total", mean = "mean", stop("egen ", f, " non pris en charge"))
    r <- egen_si(x, sel, stat, g)
  }
  if (identical(type, "double")) stop("egen double : à porter à la main")
  supprimer_vars(d, character(0))
  if (v %in% names(d)) stop("egen : la variable ", v, " existe déjà (Stata s'arrêterait)")
  d[, (v) := r]
}

.gen <- function(d, corps) {
  m <- regmatches(corps, regexec("^(?:gen|generate|g|ge|gene)\\s+(?:(float|double|str\\d*|strL)\\s+)?(\\w+)\\s*=\\s*(.*)$", corps, perl = TRUE))[[1]]
  if (!length(m)) stop("gen non reconnu : ", corps)
  type <- m[[2]]; v <- m[[3]]
  io <- .decouper_if_options(m[[4]])
  if (nzchar(io$opts)) stop("gen avec options non pris en charge : ", corps)
  if (v %in% names(d)) stop("gen : la variable ", v, " existe déjà")
  val <- .eval_s(d, io$x)
  sel <- if (nzchar(io$cond)) st_vrai(.eval_s(d, io$cond)) else rep(TRUE, nrow(d))
  if (length(val) == 1L) val <- rep(val, nrow(d))
  if (is.character(val)) { val[!sel] <- "" } else {
    val <- as.double(unclass(val)); attributes(val) <- NULL
    val[!sel] <- NA_real_
    if (!identical(type, "double")) val <- en_float(val)   # type float par défaut
  }
  d[, (v) := val]
}

#' Exécute les instructions du fichier entre les lignes de et a. Renvoie d
#' (qui peut être une nouvelle table si des lignes sont supprimées).
executer_plage <- function(d, fichier, regles_f, de, a) {
  ins <- instructions_do(fichier)
  ins <- ins[ins$ligne >= de & ins$ligne <= a, ]
  for (k in seq_len(nrow(ins))) {
    x <- ins[k, ]; cmd <- x$commande; corps <- x$corps
    lecture <- cmd %in% COMMANDES_LECTURE && !(cmd %in% c("preserve", "restore", "include", "do", "run"))
    if (lecture) next
    if (x$contexte != "") stop(fichier, ":", x$ligne, " instruction modifiante dans un bloc (", x$contexte, ") : à porter à la main")
    by_prefixe <- character(0)
    if (x$prefixe_by) {
      mb <- regmatches(x$texte, regexec("(?:bys(?:o|or|ort)?|by)\\s+([^:]*):", x$texte, perl = TRUE))[[1]]
      by_prefixe <- resoudre_varlist(gsub("[()]", "", mb[[2]]), names(d))
    }
    res <- tryCatch({
      if (cmd == "replace") {
        r <- regles_f[regles_f$ligne == x$ligne & regles_f$statut == "actif", ]
        if (!nrow(r)) stop("replace sans règle extraite")
        if (length(by_prefixe)) stop("by: replace non pris en charge")
        appliquer_regles(d, r, fichier, x$ligne, x$ligne)
      } else if (cmd %in% c("gen", "generate", "g", "ge", "gene")) {
        .gen(d, corps)
      } else if (cmd == "egen") {
        .egen(d, corps, by_prefixe)
      } else if (cmd %in% c("drop", "keep")) {
        reste <- trimws(sub("^(drop|keep)\\s*", "", corps))
        if (grepl("^if\\b", reste)) {
          sel <- st_vrai(.eval_s(d, sub("^if\\s*", "", reste)))
          d <- if (cmd == "drop") d[!sel] else d[sel]
        } else {
          vars <- tryCatch(resoudre_varlist(reste, names(d)), error = function(e) if (x$capture) NULL else stop(e))
          if (!is.null(vars)) {
            if (cmd == "drop") supprimer_vars(d, vars) else supprimer_vars(d, setdiff(names(d), vars))
          }
        }
      } else if (cmd == "order") {
        mo <- regmatches(corps, regexec("^order\\s+(.+?)\\s*,\\s*(after|before)\\((\\w+)\\)$", corps))[[1]]
        if (!length(mo)) stop("order non reconnu")
        v <- resoudre_varlist(mo[[2]], names(d)); ref <- resoudre_variable(mo[[4]], names(d))
        autres <- setdiff(names(d), v); p <- match(ref, autres)
        nouv <- if (mo[[3]] == "after") append(autres, v, after = p) else append(autres, v, after = p - 1L)
        data.table::setcolorder(d, nouv)
      } else if (cmd %in% c("label", "lab", "la") && grepl("^(label|lab|la)\\s+var(iable)?\\s", corps)) {
        ml <- regmatches(corps, regexec('^\\w+\\s+var\\w*\\s+(\\w+)\\s+"(.*)"$', corps))[[1]]
        data.table::setattr(d[[resoudre_variable(ml[[2]], names(d))]], "label", ml[[3]])
      } else {
        stop("commande non interprétée : ", cmd)
      }
      NULL
    }, error = function(e) {
      if (x$capture && cmd != "replace") return(NULL)  # cap … : erreur ignorée
      stop(sprintf("%s:%d [%s] %s", fichier, x$ligne, corps, conditionMessage(e)), call. = FALSE)
    })
  }
  d
}
