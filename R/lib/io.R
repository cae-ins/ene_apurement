# =============================================================================
# io.R : chemins (paramétrés par variables d'environnement et trimestre),
# lecture/écriture des bases .dta.
#
# Variables d'environnement :
#   ENE_DATA_DIR  racine contenant datain/staging (exports Survey Solutions),
#                 document/codification (classeurs CITP/CIAP) et, pour la
#                 parité, datain/standard et dataout/ (sorties Stata).
#   ENE_OUT_DIR   dossier de sortie des bases produites par R
#                 (défaut : <dépôt>/sortie_r/<trimestre>).
#   ENE_REF_DIR   références intermédiaires Stata (produites par
#                 R/reference/ref_brute.do), un sous-dossier par étape.
# =============================================================================

verifier_trimestre <- function(q) {
  if (!is.character(q) || !grepl("^T[1-4]_[0-9]{4}$", q))
    stop("Trimestre attendu sous la forme TX_YYYY (ex. T1_2026) : ", q, call. = FALSE)
  q
}

#' Construit la liste des chemins pour un trimestre.
chemins_apurement <- function(trimestre, racine_depot) {
  verifier_trimestre(trimestre)
  data_dir <- Sys.getenv("ENE_DATA_DIR", "")
  if (!nzchar(data_dir)) stop("Définir ENE_DATA_DIR (racine des données).", call. = FALSE)
  out <- Sys.getenv("ENE_OUT_DIR", file.path(racine_depot, "sortie_r", trimestre))
  list(
    trimestre = trimestre,
    data = data_dir,
    staging = file.path(data_dir, "datain", "staging"),
    codification = file.path(data_dir, "document", "codification"),
    # références Stata finales (run complet)
    ref_brute = file.path(data_dir, "datain", "brute"),
    ref_standard_in = file.path(data_dir, "datain", "standard"),
    ref_standard_menage = file.path(data_dir, "dataout", "standard", "menage"),
    ref_standard_individu = file.path(data_dir, "dataout", "standard", "individu"),
    ref_dataout = file.path(data_dir, "dataout"),
    ref_inter = Sys.getenv("ENE_REF_DIR", ""),
    sortie = out,
    # ENEM_<TX><YYYY>.dta : T1_2026 -> ENEM_T12026.dta (comme parentfile.do)
    menage_source = Sys.getenv("ENE_MENAGE_EXPORT",
                               paste0("ENEM_", sub("_", "", trimestre), ".dta"))
  )
}

#' Types de stockage Stata des variables d'un .dta (formats 117/118/119),
#' lus dans l'en-tête : "byte", "int", "long", "float", "double" ou "str".
#' haven ne les expose pas ; ils servent à reproduire la précision des
#' `replace` (une variable float stocke ses valeurs en simple précision).
types_stata <- function(chemin) {
  con <- file(chemin, "rb"); on.exit(close(con))
  b <- readBin(con, "raw", n = 4096L)
  pr <- grepRaw("<release>", b, fixed = TRUE)
  if (!length(pr)) return(NULL)
  rel <- suppressWarnings(as.integer(rawToChar(b[(pr + 9L):(pr + 11L)])))
  if (is.na(rel) || !rel %in% 117:119) return(NULL)
  endian <- if (length(grepRaw("<byteorder>MSF", b, fixed = TRUE))) "big" else "little"
  pk <- grepRaw("<K>", b, fixed = TRUE) + 3L
  k <- if (rel == 119) readBin(b[pk:(pk + 3L)], "integer", size = 4, endian = endian) else
    readBin(b[pk:(pk + 1L)], "integer", size = 2, signed = FALSE, endian = endian)
  # <variable_types> suit l'en-tête et la carte <map>
  seek(con, 0); bb <- readBin(con, "raw", n = 200000L)
  idx <- grepRaw("<variable_types>", bb, fixed = TRUE)
  if (!length(idx)) return(NULL)
  idx <- idx + nchar("<variable_types>")
  codes <- readBin(bb[idx:(idx + 2L * k - 1L)], "integer", size = 2, signed = FALSE, n = k, endian = endian)
  c("65526" = "double", "65527" = "float", "65528" = "long", "65529" = "int", "65530" = "byte")[as.character(codes)] -> ty
  ty[is.na(ty)] <- "str"
  unname(ty)
}

#' Lit un .dta en data.table en conservant libellés et manquants étendus,
#' et le type de stockage Stata de chaque variable numérique (attribut
#' "stata_type").
lire_dta <- function(chemin) {
  if (!file.exists(chemin)) stop("Fichier absent : ", chemin, call. = FALSE)
  d <- haven::read_dta(chemin)
  data.table::setDT(d)
  ty <- tryCatch(types_stata(chemin), error = function(e) NULL)
  if (length(ty) == ncol(d)) for (j in seq_along(ty)) if (ty[[j]] != "str") data.table::setattr(d[[j]], "stata_type", ty[[j]])
  d
}

#' Écrit un data.table en .dta (format Stata 15+, lisible par Stata 17).
ecrire_dta <- function(dt, chemin) {
  dir.create(dirname(chemin), recursive = TRUE, showWarnings = FALSE)
  haven::write_dta(as.data.frame(dt), chemin, version = 15)
  invisible(chemin)
}

#' Vérifie que le marqueur de trimestre des sorties Stata de référence
#' (dataout/apurement_quarter.txt) correspond au trimestre demandé.
verifier_marqueur_reference <- function(ch) {
  f <- file.path(ch$ref_dataout, "apurement_quarter.txt")
  if (!file.exists(f)) return(list(ok = FALSE, message = "marqueur absent"))
  q <- trimws(readLines(f, warn = FALSE)[[1]])
  list(ok = identical(q, ch$trimestre),
       message = sprintf("dataout/apurement_quarter.txt = %s (demandé : %s)", q, ch$trimestre))
}
