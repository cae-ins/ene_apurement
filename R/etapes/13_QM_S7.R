# =============================================================================
# 13_QM_S7.R : do: 01-QM_S7_logement.do (base ménage, une ligne par ménage)
# Imputations par médiane / mode (egen) portées à la main ; les replace qui
# les utilisent sont des règles extraites appliquées par segments.
# =============================================================================

etape_QM_S7 <- function(etat, regles) {
  f <- "01-QM_S7_logement.do"
  seg <- segmenteur(regles, f, rbind(c(15, 65), c(68, 68), c(72, 72), c(74, 144), c(147, 147),
                                     c(151, 151), c(153, 271), c(274, 274), c(279, 279), c(281, 324),
                                     c(341, 358), c(361, 361), c(365, 365), c(367, 406), c(411, 411),
                                     c(416, 454), c(459, 459), c(464, 502), c(507, 507), c(512, 590)))
  # do: :9-14
  d <- data.table::copy(etat$standard$QM_S7_logement)
  supprimer_vars(d, "_merge")
  d <- fusionner_garder_apparies(d, etat$standard$QM_S0_identification, "interview__key",
                                 c("HH2", "HH3", "HH4", "HH12", "HH13", "HH3", "hha", "rgmen", "rghab"))
  ev <- function(s) st_vrai(evaluer_expr(d, traduire_expr_stata(s)))
  seg(d, 15, 65)
  # do: :66-73  L2A : médiane par type de logement
  d[, med_L2A := egen_si(L2A, ev("L1 == 5"), "median")]; seg(d, 68, 68)
  d[, med_L2A := egen_si(L2A, ev("L1 == 4"), "median")]; seg(d, 72, 72)
  supprimer_vars(d, "med_L2A")
  seg(d, 74, 144)
  # do: :145-152  L2B
  d[, med_L2B := egen_si(L2B, ev("L1 == 4 & L2A ==2"), "median")]; seg(d, 147, 147)
  d[, med_L2B := egen_si(L2B, ev("L1 == 5 & L2A ==3"), "median")]; seg(d, 151, 151)
  supprimer_vars(d, "med_L2B")
  seg(d, 153, 271)
  # do: :272-280  L5 : mode calculé sur des lignes où L5 est manquant (donc
  # toujours manquant : la correction Stata est sans effet, reproduite telle quelle)
  d[, mod_L5 := egen_si(L5, ev('missing(L5) & L1==4 & hha != "" & (rgmen == 1 | rghab == 4)'), "mode")]; seg(d, 274, 274)
  supprimer_vars(d, "mod_L5")
  d[, mod_L5 := egen_si(L5, ev('missing(L5) & L1==5 & hha != "" & (rgmen == 1 | rghab == 4)'), "mode")]; seg(d, 279, 279)
  supprimer_vars(d, "mod_L5")
  seg(d, 281, 324)
  # do: :325-340  loyers < 1000 remplacés par la médiane du type de logement
  for (i in 1:7) {
    tm <- egen_si(d$L6, ev(sprintf("L1==%d & !missing(L6)", i)), "median")
    tm2 <- egen_si(tm, rep(TRUE, nrow(d)), "max", d$L1)
    sel <- ev(sprintf("L6 < 1000 & !missing(L6) & L1==%d", i))
    if (any(sel)) affecter(d, "L6", which(sel), tm2[sel])
  }
  seg(d, 341, 358)
  # do: :359-366  L7 : mode
  d[, mod_L7 := egen_si(L7, ev("!missing(L1) & L1==4 & L3==1 & L4==1"), "mode")]; seg(d, 361, 361)
  supprimer_vars(d, "mod_L7")
  d[, mod_L7 := egen_si(L7, ev("!missing(L1) & L1==5"), "mode")]; seg(d, 365, 365)
  supprimer_vars(d, "mod_L7")
  seg(d, 367, 406)
  # do: :407-415, 455-463, 503-511  L8, L9, L10 : mode par type de logement
  mode_par_L1 <- function(v, ligne) {
    m <- egen_si(d[[v]], ev(sprintf("!missing(%s)", v)), "mode", d$L1)
    d[, (paste0("mode_", v, "_final")) := egen_si(m, rep(TRUE, nrow(d)), "max", d$L1)]
    d[, (paste0("mode_", v)) := m]
    seg(d, ligne, ligne)
    supprimer_vars(d, c(paste0("mode_", v), paste0("mode_", v, "_final")))
  }
  mode_par_L1("L8", 411); seg(d, 416, 454)
  mode_par_L1("L9", 459); seg(d, 464, 502)
  mode_par_L1("L10", 507); seg(d, 512, 590)
  supprimer_vars(d, c("HH2", "HH3", "HH4", "rghab", "rgmen", "HH12", "HH13", "hha"))  # do: :591
  etat$sortie_menage$QM_S7_logement <- d
  invisible(etat)
}
