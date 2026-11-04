# Sémantique Stata reproduite par R/lib/stata_expr.R.
# Les valeurs attendues ont été vérifiées sous Stata 17 (essai du 4 nov. 2026).

racine <- normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/")
for (f in c("do_parser.R", "stata_expr.R", "regles.R"))
  source(file.path(racine, "R", "lib", f), encoding = "UTF-8")

ev <- function(s, env = list()) eval(traduire_expr_stata(s), envir = env, enclos = environment(st_eq))

test_that("priorités d'opérateurs comme Stata", {
  expect_equal(ev("!2==0"), 1)        # (!2)==0
  expect_equal(ev("-2^2"), -4)
  expect_equal(ev("2^3^2"), 64)       # associativité à gauche
  expect_equal(ev("5 - 3 + 1"), 3)
  expect_equal(ev("8/2*2"), 8)
  expect_equal(ev("1 < 2 == 1"), 1)
})

test_that("manquants : plus grands que tout nombre, ordonnés", {
  expect_equal(ev(". < .a"), 1)
  expect_equal(ev(".a > 5"), 1)
  x <- c(1, NA, haven::tagged_na("a"))
  expect_equal(ev("x != 3", list(x = x)), c(1, 1, 1))
  expect_equal(ev("x > 5", list(x = x)), c(0, 1, 1))
  expect_equal(ev("x == .a", list(x = x)), c(0, 0, 1))
  expect_equal(ev("inlist(x, ., .a)", list(x = x)), c(0, 1, 1))
  expect_equal(ev("missing(x)", list(x = x)), c(0, 1, 1))
})

test_that("une condition manquante est vraie", {
  expect_true(st_vrai(NA_real_))
  expect_false(st_vrai(0))
})

test_that("fonctions texte : octets et ASCII comme Stata", {
  expect_equal(ev('lower("ÉCOLE École")'), "École École")  # É inchangé (ASCII seul)
  expect_equal(ev('regexm("élève", "^.l")'), 0)   # é = 2 octets
  expect_equal(ev('regexm("élève", "^..l")'), 1)
  expect_equal(ev('strtrim("  a b  ")'), "a b")
  expect_equal(ev('itrim("a    b")'), "a b")
})

test_that("round, inrange et syntaxes tolérées par Stata", {
  expect_equal(ev("round(-2.5)"), -2)
  expect_equal(ev("inrange(., 1, .)"), 0)
  expect_equal(ev("inrange(5, ., 10)"), 1)
  s <- c("A", "B", "")
  expect_equal(ev('s == "A" || s == "B"', list(s = s)), c(1, 1, 0))  # || = |
  expect_equal(ev('s == "B""Z"', list(s = s)), c(0, 1, 0))           # 1er littéral seul
})

test_that("les blancs internes aux chaînes sont conservés", {
  expect_equal(compresser_blancs('replace  x = 1 if y == "A  B"'), 'replace x = 1 if y == "A  B"')
})

test_that("découpage d'un replace", {
  d <- decouper_replace('replace M21 = 47 if M21_Aut == "BISSA"')
  expect_equal(d$variable, "M21"); expect_equal(d$valeur, "47")
  expect_equal(d$condition, 'M21_Aut == "BISSA"')
  d <- decouper_replace("replace EP6__2 = 1 in 8455")
  expect_equal(d$observation, "8455"); expect_equal(d$condition, "")
})

test_that("affectation : libellés haven conservés, tagged NA possibles", {
  dt <- data.table::data.table(x = haven::labelled(c(98, 98, 1), c(A = 1, Autre = 98)), s = c("u", "v", "w"))
  appliquer_replace(dt, "x", "47", 's == "v"')
  expect_equal(as.double(unclass(dt$x)), c(98, 47, 1))
  expect_true(inherits(dt$x, "haven_labelled"))
  appliquer_replace(dt, "x", ".a", 's == "w"')
  expect_equal(haven::na_tag(unclass(dt$x))[[3]], "a")
})
