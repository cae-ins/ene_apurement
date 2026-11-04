# =============================================================================
# do_parser.R : découpe un do-file Stata en instructions logiques.
#
# Chaque instruction garde sa ligne de début et de fin dans le fichier source.
# Sont retirés : commentaires /* */ (imbriqués), commentaires // et lignes
# commençant par *. Les continuations /// sont jointes. Les blocs { } (foreach,
# forvalues, if, program...) sont suivis : chaque instruction porte son
# contexte, ce qui permet de distinguer une instruction de premier niveau
# d'une instruction exécutée dans une boucle.
# =============================================================================

#' Lit un do-file et renvoie un data.frame d'instructions.
#' Colonnes : fichier_do, ligne, ligne_fin, texte, contexte, commande,
#' prefixe_by, capture.
lire_instructions_do <- function(chemin) {
  lignes <- readLines(chemin, encoding = "UTF-8", warn = FALSE)
  lignes <- sub("\r$", "", lignes)
  n <- length(lignes)

  res_texte <- character(0)
  res_debut <- integer(0)
  res_fin <- integer(0)

  prof_bloc <- 0L          # profondeur des commentaires /* */
  tampon <- ""             # instruction en cours d'accumulation
  debut <- NA_integer_
  commentaire_etoile <- FALSE  # instruction courante = commentaire *

  emettre <- function(fin) {
    t <- trimws(tampon)
    if (nzchar(t) && !commentaire_etoile) {
      res_texte[[length(res_texte) + 1L]] <<- t
      res_debut[[length(res_debut) + 1L]] <<- debut
      res_fin[[length(res_fin) + 1L]] <<- fin
    }
    tampon <<- ""
    debut <<- NA_integer_
    commentaire_etoile <<- FALSE
  }

  for (k in seq_len(n)) {
    ch <- strsplit(lignes[[k]], "", fixed = TRUE)[[1]]
    m <- length(ch)
    i <- 1L
    continuation <- FALSE
    # Ligne commençant par * (hors commentaire bloc, en début d'instruction)
    if (prof_bloc == 0L && !nzchar(trimws(tampon)) &&
        grepl("^\\s*\\*", lignes[[k]])) {
      # NB : une ligne "*/" hors commentaire bloc est un commentaire * pour
      # Stata (vérifié dans le log : 01-traitrement_autres.do ligne 3246).
      commentaire_etoile <- TRUE
      if (is.na(debut)) debut <- k
      # un commentaire * se prolonge si la ligne se termine par ///
      if (grepl("(^|\\s)///", lignes[[k]])) {
        tampon <- paste(tampon, "*")
        next
      }
      emettre(k)
      next
    }
    if (commentaire_etoile) {
      # suite d'un commentaire * continué par ///
      if (grepl("(^|\\s)///", lignes[[k]])) next
      emettre(k)
      next
    }
    dans_chaine <- FALSE
    chaine_composee <- FALSE
    buf <- character(0)
    while (i <= m) {
      c1 <- ch[[i]]
      c2 <- if (i < m) paste0(c1, ch[[i + 1L]]) else c1
      if (prof_bloc > 0L) {
        if (c2 == "*/") { prof_bloc <- prof_bloc - 1L; i <- i + 2L; next }
        if (c2 == "/*") { prof_bloc <- prof_bloc + 1L; i <- i + 2L; next }
        i <- i + 1L
        next
      }
      if (dans_chaine) {
        buf[[length(buf) + 1L]] <- c1
        if (chaine_composee) {
          if (c2 == "\"'") { buf[[length(buf) + 1L]] <- "'"; i <- i + 2L
            dans_chaine <- FALSE; next }
        } else if (c1 == "\"") {
          dans_chaine <- FALSE
        }
        i <- i + 1L
        next
      }
      if (c2 == "/*") { prof_bloc <- prof_bloc + 1L; i <- i + 2L; next }
      prec_blanc <- (i == 1L) || grepl("\\s", ch[[i - 1L]])
      if (prec_blanc && c2 == "//") {
        c3 <- if (i + 2L <= m) ch[[i + 2L]] else ""
        if (c3 == "/") continuation <- TRUE
        break
      }
      if (c2 == "`\"") {
        dans_chaine <- TRUE; chaine_composee <- TRUE
        buf <- c(buf, "`", "\""); i <- i + 2L; next
      }
      if (c1 == "\"") { dans_chaine <- TRUE; chaine_composee <- FALSE }
      buf[[length(buf) + 1L]] <- c1
      i <- i + 1L
    }
    morceau <- paste(buf, collapse = "")
    if (nzchar(trimws(morceau)) && is.na(debut)) debut <- k
    tampon <- paste(tampon, morceau)
    if (continuation || (prof_bloc > 0L && nzchar(trimws(tampon)))) next
    if (prof_bloc > 0L) next
    emettre(k)
  }
  emettre(n)

  instr <- data.frame(
    fichier_do = basename(chemin), ligne = res_debut, ligne_fin = res_fin,
    texte = vapply(res_texte, compresser_blancs, ""), stringsAsFactors = FALSE
  )
  rownames(instr) <- NULL
  annoter_instructions(instr)
}

#' Compresse les suites de blancs HORS des littéraux "..." (les espaces
#' internes aux chaînes sont significatifs : "ÉCOLE  CORANIQUE").
compresser_blancs <- function(s) {
  m <- gregexpr('"[^"]*"', s)[[1]]
  if (m[[1]] < 0) return(gsub("\\s+", " ", s))
  debuts <- as.integer(m); fins <- debuts + attr(m, "match.length") - 1L
  morceaux <- character(0); pos <- 1L
  for (k in seq_along(debuts)) {
    if (debuts[[k]] > pos) morceaux <- c(morceaux, gsub("\\s+", " ", substr(s, pos, debuts[[k]] - 1L)))
    morceaux <- c(morceaux, substr(s, debuts[[k]], fins[[k]]))
    pos <- fins[[k]] + 1L
  }
  if (pos <= nchar(s)) morceaux <- c(morceaux, gsub("\\s+", " ", substr(s, pos, nchar(s))))
  paste(morceaux, collapse = "")
}

# Prefixes sans effet sur la sémantique de la commande
.re_prefixe <- "^(cap(t|tu|tur|ture)?|qui(e|et|etl|etly)?|noi(s|si|sil|sily)?)\\b\\s*:?\\s*"

#' Ajoute contexte de bloc, commande, préfixe by et capture.
annoter_instructions <- function(instr) {
  pile <- character(0)
  n <- nrow(instr)
  contexte <- character(n); commande <- character(n)
  by <- logical(n); capture <- logical(n); corps <- character(n)
  dans_programme <- FALSE
  dans_preserve <- FALSE
  for (i in seq_len(n)) {
    t <- instr$texte[[i]]
    cap <- FALSE
    repeat {
      t2 <- sub(.re_prefixe, "", t, perl = TRUE)
      if (identical(t2, t)) break
      if (grepl("^cap", t)) cap <- TRUE
      t <- t2
    }
    est_by <- FALSE
    if (grepl("^(bys(o|or|ort)?|by)\\s[^:]*:", t, perl = TRUE)) {
      est_by <- TRUE
      t <- trimws(sub("^(bys(o|or|ort)?|by)\\s[^:]*:", "", t, perl = TRUE))
      repeat { t2 <- sub(.re_prefixe, "", t, perl = TRUE); if (identical(t2, t)) break; t <- t2 }
    }
    cmd <- tolower(sub("^([A-Za-z_][A-Za-z0-9_]*).*$", "\\1", t, perl = TRUE))
    if (!grepl("^[A-Za-z_]", t)) cmd <- substr(t, 1, 1)
    contexte[[i]] <- if (length(pile)) paste(pile, collapse = ">") else ""
    if (dans_preserve && cmd != "restore")
      contexte[[i]] <- paste0("preserve", if (nzchar(contexte[[i]])) ">", contexte[[i]])
    if (dans_programme) contexte[[i]] <- paste0("program", if (nzchar(contexte[[i]])) ">", contexte[[i]])
    if (cmd == "preserve") dans_preserve <- TRUE
    if (cmd == "restore") dans_preserve <- FALSE
    commande[[i]] <- cmd; by[[i]] <- est_by; capture[[i]] <- cap; corps[[i]] <- t
    # Gestion des blocs
    if (cmd == "program" && !grepl("^program\\s+drop", t)) dans_programme <- TRUE
    if (cmd == "end" && dans_programme) dans_programme <- FALSE
    ouvre <- grepl("\\{\\s*$", t)
    ferme <- grepl("^\\}", t)
    if (ferme && length(pile)) pile <- pile[-length(pile)]
    if (ouvre) {
      type <- if (cmd %in% c("foreach", "forvalues", "while")) "boucle" else
        if (cmd %in% c("if", "else")) "si" else cmd
      if (ferme && cmd == "}") type <- "si"  # "} else {"
      pile <- c(pile, type)
    }
  }
  instr$contexte <- contexte
  instr$commande <- commande
  instr$prefixe_by <- by
  instr$capture <- capture
  instr$corps <- corps
  instr
}

# Commandes sans effet sur les données en mémoire (lecture, contrôle, export)
COMMANDES_LECTURE <- c(
  "count", "cou", "ta", "tab", "tabu", "tabulate", "tab1", "tab2", "di",
  "dis", "disp", "display", "list", "li", "l", "br", "browse", "bro", "sum",
  "su", "summ", "summarize", "des", "desc", "describe", "codebook", "export",
  "isid", "assert", "log", "set", "global", "local", "levelsof", "mdesc",
  "distinct", "misstable", "inspect", "tabstat", "table", "graph", "histogram",
  "violin", "display", "}", "{", "shell", "file", "tempname", "tempfile",
  "capture", "cls", "mean", "ds", "lookfor", "pause", "more", "exit", "end",
  "program", "args", "confirm", "macro", "return", "ereturn", "include",
  "do", "run", "which", "ssc", "net", "mkdir", "erase", "copy", "else", "if",
  "foreach", "forvalues", "while", "window", "preserve", "restore", "#", "ed", "edit"
)
