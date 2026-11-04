# =============================================================================
# anomalies.R : mécanisme générique d'export des listes d'anomalies.
#
# Les do-files Stata contiennent ~250 `export excel <vars> using <fichier>
# if <condition>, firstrow(varl)`. Ces listes sont des sorties de contrôle,
# jamais relues par la chaîne. En R, une seule fonction les produit ; chaque
# appel est désactivé par défaut (ENE_EXPORT_ANOMALIES=1 pour les écrire).
# =============================================================================

#' Écrit la liste des observations de `dt` satisfaisant `condition` (expression
#' Stata, ou vecteur logique) pour les variables `vars`.
#' En-têtes : libellés de variables si `libelles = TRUE` (firstrow(varl)).
exporter_anomalies <- function(dt, vars, condition, nom, dossier, libelles = TRUE) {
  if (Sys.getenv("ENE_EXPORT_ANOMALIES", "0") != "1") return(invisible(NULL))
  sel <- if (is.character(condition)) st_vrai(evaluer_expr(dt, traduire_expr_stata(condition))) else condition
  if (!any(sel)) return(invisible(NULL))
  vars <- vapply(vars, resoudre_variable, "", noms_base = names(dt))
  sortie <- as.data.frame(dt[which(sel), vars, with = FALSE])
  sortie[] <- lapply(sortie, function(x) if (inherits(x, "haven_labelled")) as.vector(haven::as_factor(x, levels = "both")) else as.vector(x))
  if (libelles) {
    lab <- vapply(vars, function(v) { l <- attr(dt[[v]], "label", exact = TRUE); if (is.null(l) || !nzchar(l)) v else l }, "")
    names(sortie) <- make.unique(lab)
  }
  dir.create(dossier, recursive = TRUE, showWarnings = FALSE)
  f <- file.path(dossier, paste0(sub("\\.xlsx?$", "", nom), ".xlsx"))
  writexl::write_xlsx(sortie, f)
  invisible(f)
}
