# =============================================================================
# 01_traitement_autres.R : do: 01-traitrement_autres.do
#
# Le do-file (14 654 lignes) enchaîne des blocs `use <base> ... save` sur
# membres, QX_EEC_VF et r_activite_s, composés uniquement de `replace` (12 392
# instructions actives) et de 18 `export excel` de contrôle. Tous les replace
# sont extraits dans referentiels/recodages_texte.csv (colonne base) et sont
# appliqués ici dans l'ordre des lignes, base par base. Chaque bloc étant
# sauvegardé avant le `use` suivant, enchaîner les règles d'une même base dans
# l'ordre des lignes équivaut à l'exécution Stata.
# Particularité : 4 règles `replace ... in <n>` (lignes 6728, 6739, 6742,
# 6955) visent une observation par sa position ; elles supposent que l'ordre
# des lignes de membres est celui de Stata à ce stade (contrôlé par la parité).
# =============================================================================

#' Remplace le qualificatif `in <n>` par la clé de l'individu visé sous Stata
#' (referentiels/positions_in_resolues.csv). Sans résolution pour le
#' trimestre, la règle reste positionnelle (ordre R) et un avertissement est émis.
resoudre_regles_positionnelles <- function(r, trimestre, dossier_ref) {
  f <- file.path(dossier_ref, "positions_in_resolues.csv")
  res <- if (file.exists(f)) utils::read.csv(f, colClasses = "character", encoding = "UTF-8") else NULL
  for (k in which(nzchar(r$observation))) {
    s <- if (is.null(res)) NULL else res[res$id_regle == r$id_regle[[k]] & res$trimestre == trimestre, ]
    if (is.null(s) || !nrow(s)) {
      warning("Règle positionnelle ", r$id_regle[[k]], " non résolue pour ", trimestre,
              " : appliquée à l'observation ", r$observation[[k]], " de l'ordre R.")
      next
    }
    cle <- sprintf('interview__key == "%s" & membres__id == %s', s$interview__key, s$membres__id)
    r$condition[[k]] <- if (nzchar(r$condition[[k]])) sprintf("(%s) & %s", r$condition[[k]], cle) else cle
    r$observation[[k]] <- ""
  }
  r
}

etape_traitement_autres <- function(etat, regles, dossier_ref) {
  f <- "01-traitrement_autres.do"
  r <- regles[regles$fichier_do == f, ]
  r <- resoudre_regles_positionnelles(r, etat$trimestre, dossier_ref)
  bases <- c(membres = "membres", QX_EEC_VF = "menage", r_activite_s = "r_activite_s")
  inconnues <- setdiff(unique(r$base), names(bases))
  if (length(inconnues)) stop("Base inattendue dans ", f, " : ", paste(inconnues, collapse = ", "))
  etat$changements_autres <- list()
  for (b in names(bases)) {
    rb <- r[r$base == b, ]
    if (!nrow(rb)) next
    d <- get(bases[[b]], envir = etat)
    etat$changements_autres[[b]] <- appliquer_regles(d, rb, f)
  }
  invisible(etat)
}
