#!/usr/bin/env Rscript
# =============================================================================
# resoudre_positions.R : traduit les règles `replace ... in <n>` en clés
# (interview__key, membres__id).
#
# Sous Stata, `in <n>` vise la n-ième observation dans l'ordre courant. Or cet
# ordre résulte du `merge m:1 interview__key` de 00-suppression_non_residents.do,
# qui trie par ménage SANS tri stable : à l'intérieur d'un ménage, l'ordre des
# individus dépend de l'algorithme de tri interne de Stata (reproductible d'un
# run à l'autre, mais non documenté). R ne peut pas le reproduire ; on lit donc
# dans la référence Stata (état juste avant 01-traitrement_autres.do) quel
# individu occupait la position visée, pour le trimestre donné.
#
#   Rscript --vanilla R/extraction/resoudre_positions.R --quarter T1_2026 \
#       --ref $ENE_REF_DIR/03_nettoyage/membres.dta
# =============================================================================
a <- commandArgs(trailingOnly = TRUE)
arg <- function(n, d = NULL) { i <- match(paste0("--", n), a); if (is.na(i)) d else a[[i + 1L]] }
racine <- normalizePath(file.path(dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))), "..", ".."), winslash = "/")
trimestre <- arg("quarter"); if (!grepl("^T[1-4]_[0-9]{4}$", trimestre)) stop("--quarter TX_YYYY")
ref <- arg("ref", file.path(Sys.getenv("ENE_REF_DIR"), "03_nettoyage", "membres.dta"))
regles <- utils::read.csv(file.path(racine, "referentiels", "recodages_texte.csv"), colClasses = "character", encoding = "UTF-8")
pos <- regles[nzchar(regles$observation), ]
m <- haven::read_dta(ref, col_select = tidyselect::all_of(c("interview__key", "membres__id")))
res <- data.frame(id_regle = pos$id_regle, trimestre = trimestre, base = pos$base,
                  observation = pos$observation,
                  interview__key = m$interview__key[as.integer(pos$observation)],
                  membres__id = as.character(m$membres__id[as.integer(pos$observation)]),
                  source = paste0("ordre Stata de ", basename(dirname(ref)), "/", basename(ref)),
                  stringsAsFactors = FALSE)
f <- file.path(racine, "referentiels", "positions_in_resolues.csv")
ancien <- if (file.exists(f)) utils::read.csv(f, colClasses = "character", encoding = "UTF-8") else NULL
if (!is.null(ancien)) ancien <- ancien[ancien$trimestre != trimestre, ]
utils::write.csv(rbind(ancien, res), f, row.names = FALSE, fileEncoding = "UTF-8")
print(res)
