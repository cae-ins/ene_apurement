# Opérations Stata non génériques (R/lib/stata_ops.R).
racine <- normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/")
for (f in c("do_parser.R", "stata_expr.R", "regles.R", "stata_ops.R"))
  source(file.path(racine, "R", "lib", f), encoding = "UTF-8")

test_that("egen mode : manquant si plusieurs modes ou aucun non manquant", {
  g <- c("a", "a", "a", "b", "b", "c")
  x <- c(1, 1, 2, 1, 2, NA)
  expect_equal(egen_mode(x, g), c(1, 1, 1, NA, NA, NA))
})

test_that("egen max/total ignorent les manquants", {
  g <- c("a", "a", "b")
  expect_equal(egen_max(c(NA, 3, NA), g), c(3, 3, NA))
  expect_equal(egen_total(c(NA, 3, NA), g), c(3, 3, 0))
})

test_that("merge garde les appariés, n'écrase pas les variables existantes, trie par clé", {
  m <- data.table::data.table(k = c("b", "a", "c"), x = 1:3)
  d <- data.table::data.table(k = c("a", "b"), x = c(9, 9), y = c(10, 20))
  r <- fusionner_garder_apparies(m, d, "k", c("x", "y"))
  expect_equal(r$k, c("a", "b")); expect_equal(r$x, c(2L, 1L)); expect_equal(r$y, c(10, 20))
})

test_that("nettoyage des chaînes : blancs finaux Unicode, espaces initiaux", {
  dt <- data.table::data.table(s = c("  a b  ", "x", ""))
  nettoyer_chaines(dt)
  expect_equal(dt$s, c("a b", "x", ""))
})
