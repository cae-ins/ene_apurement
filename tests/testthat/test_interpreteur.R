# Fusions et précision de stockage (R/lib/stata_ops.R, R/lib/regles.R).
racine <- normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/")
for (f in c("do_parser.R", "stata_expr.R", "regles.R", "stata_ops.R", "io.R"))
  source(file.path(racine, "R", "lib", f), encoding = "UTF-8")

test_that("merge 1:m : une ligne par ligne appariée du roster, variables maître d'abord", {
  m <- data.table::data.table(k = c("a", "b"), x = c(1, 2))
  d <- data.table::data.table(k = c("b", "a", "a", "z"), r = 1:4)
  out <- fusionner_1_m(m, d, "k")
  expect_equal(out$k, c("a", "a", "b")); expect_equal(out$r, c(2L, 3L, 1L)); expect_equal(names(out), c("k", "x", "r"))
})

test_that("keep(master match) garde les lignes maître sans appariement", {
  m <- data.table::data.table(k = c("a", "b"))
  d <- data.table::data.table(k = "a", y = 5, s = "t")
  out <- fusionner_garder_maitre(m, d, "k", c("y", "s"))
  expect_equal(out$y, c(5, NA)); expect_equal(out$s, c("t", ""))
})

test_that("update replace : les manquants de la base using ne remplacent pas", {
  m <- data.table::data.table(k = c("a", "b"), v = c(1, 2))
  u <- data.table::data.table(k = c("a", "b"), v = c(9, NA))
  expect_equal(fusion_update_replace(m, u, "k", "v")$v, c(9, 2))
})

test_that("replace dans une variable float : stockage en simple précision", {
  dt <- data.table::data.table(x = c(0, 0))
  data.table::setattr(dt$x, "stata_type", "float")
  appliquer_replace(dt, "x", "1/3", "")
  expect_equal(dt$x[[1]], en_float(1 / 3))
  expect_false(dt$x[[1]] == 1 / 3)
})

test_that("types de stockage lus dans l'en-tête .dta", {
  f <- tempfile(fileext = ".dta")
  haven::write_dta(data.frame(a = 1.5, b = "x"), f)
  expect_equal(types_stata(f), c("double", "str"))
})
