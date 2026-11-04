# Complétude des tables de règles extraites (referentiels/) : chaque `replace`
# actif des do-files doit se retrouver soit dans une table appliquée
# (recodages_texte.csv, corrections_cas.csv), soit dans regles_non_traduites.csv.
# Les tests qui relisent les do-files nécessitent ENE_DATA_DIR (dépôt Stata).

racine <- normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/")
ref <- file.path(racine, "referentiels")
lire <- function(f) utils::read.csv(file.path(ref, f), colClasses = "character", encoding = "UTF-8")
rec <- lire("recodages_texte.csv"); cor <- lire("corrections_cas.csv")
nt <- lire("regles_non_traduites.csv"); cpt <- lire("comptage_replace.csv")
dbl <- lire("doublons_a_supprimer.csv")

test_that("comptage : replace actifs = extraits + non traduits, par fichier", {
  cpt[, 2:4] <- lapply(cpt[, 2:4], as.integer)
  expect_equal(cpt$replace_actifs, cpt$extraits + cpt$non_traduits)
  n_ext <- table(factor(c(rec$fichier_do, cor$fichier_do), levels = cpt$fichier_do))
  expect_equal(as.integer(n_ext), cpt$extraits)
  n_nt <- table(factor(nt$fichier_do, levels = cpt$fichier_do))
  expect_equal(as.integer(n_nt), cpt$non_traduits)
})

test_that("identifiants de règle uniques", {
  expect_false(any(duplicated(c(rec$id_regle, cor$id_regle, nt$id_regle))))
})

test_that("01-traitrement_autres.do est entièrement extrait (12 392 replace actifs)", {
  x <- cpt[cpt$fichier_do == "01-traitrement_autres.do", ]
  expect_equal(as.integer(x$replace_actifs), 12392L)
  expect_equal(as.integer(x$non_traduits), 0L)
})

test_that("doublons : 525 identifiants distincts", {
  expect_equal(length(unique(dbl$interview__key)), 525L)
  expect_true(all(grepl("^[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$", dbl$interview__key)))
})

test_that("corrections au cas par cas de QM_S1 : 740 entre les lignes 300 et 1039", {
  x <- cor[cor$fichier_do == "01-QM_S1_composition_menage.do", ]
  l <- as.integer(x$ligne)
  expect_equal(sum(l >= 300 & l <= 1039), 740L)
})

test_that("toutes les règles appliquées se traduisent en R", {
  for (f in c("do_parser.R", "stata_expr.R", "regles.R")) source(file.path(racine, "R", "lib", f), encoding = "UTF-8")
  r <- rbind(rec[, c("valeur_cible", "condition")], cor[, c("valeur_cible", "condition")])
  ok <- vapply(seq_len(nrow(r)), function(k) {
    is.language(traduire_expr_stata(r$valeur_cible[[k]])) || is.atomic(traduire_expr_stata(r$valeur_cible[[k]]))
  }, TRUE)
  expect_true(all(ok))
})

test_that("contrôle croisé avec un comptage brut des lignes `replace` (si ENE_DATA_DIR)", {
  d <- Sys.getenv("ENE_DATA_DIR")
  skip_if(!nzchar(d), "ENE_DATA_DIR non défini")
  f <- file.path(d, "program", "01-traitrement_autres.do")
  l <- readLines(f, encoding = "UTF-8", warn = FALSE)
  brut <- sum(grepl("^\\s*replace\\b", l))
  # écart attendu = lignes replace situées dans des commentaires /* */
  source(file.path(racine, "R", "lib", "do_parser.R"), encoding = "UTF-8")
  ins <- lire_instructions_do(f)
  actifs <- sum(ins$commande == "replace")
  expect_equal(actifs, 12392L)
  expect_gte(brut, actifs)
})
