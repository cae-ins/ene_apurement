# =============================================================================
# 10_QM_S1.R : do: 01-QM_S1_composition_menage.do (pilote des sections)
#
# Les 770 replace traduits (dont 740 corrections au cas par cas, lignes
# 300-1039) sont appliqués depuis referentiels/ par segments de lignes ; les
# instructions procédurales (merge, egen par ménage, gen/drop) sont portées
# entre les segments, dans l'ordre du do-file. Les export excel de contrôle
# ne modifient pas la base et ne sont pas reproduits ici.
# =============================================================================

etape_QM_S1 <- function(etat, regles, ch) {
  f <- "01-QM_S1_composition_menage.do"
  std <- etat$standard
  regles_f <- regles[regles$fichier_do == f, ]
  seg <- function(de, a) appliquer_regles(d, regles_f, f, de, a)
  # Contrôle de couverture : chaque règle active du fichier tombe dans un segment
  segments <- rbind(c(69, 292), c(294, 1171), c(1181, 1377), c(1379, 1384), c(1386, 1451),
                    c(1459, 1476), c(1478, 1533), c(1538, 1545), c(1547, 1593), c(1601, 1625), c(1627, 1715))
  actives <- regles_f$ligne[regles_f$statut == "actif"]
  couvert <- vapply(actives, function(l) any(l >= segments[, 1] & l <= segments[, 2]), TRUE)
  if (!all(couvert)) stop("QM_S1 : règles hors segments, lignes ", paste(actives[!couvert], collapse = ","))

  # do: :9-25  base QM_S1 + variables de contrôle (merge, drop if _merge!=3)
  d <- data.table::copy(std$QM_S1_composition_menage)
  d <- fusionner_garder_apparies(d, std$QM_S0_identification, "interview__key",
         c("HH2", "HH3", "HH12", "HH13", "HH4", "HH6", "HH8B", "V1interviewkey", "V1MODINTR", "M0__0", "rgmen"))
  d <- fusionner_garder_apparies(d, etat$membres, c("interview__key", "membres__id"),
         c("membre_id_v1_IND", "HH14a", "HH14a_Aut"))
  d <- fusionner_garder_apparies(d, std$INDIV_S1_autres_formes_travail, c("interview__key", "membres__id"), "M4Confirm")
  # do: :27-28
  supprimer_vars(d, "commentaire"); d[, commentaire := ""]

  # do: :32-39  global ID_MEMB_MEN = interview__id membres__id ;
  # sort ... M0 ; by ...: gen dup = cond(_N==1,0,_n) ; drop if dup > 1.
  # `sort` sans stable : R trie de façon stable (ex aequo dans l'ordre courant).
  supprimer_vars(d, "dup")
  data.table::setorderv(d, c("interview__id", "membres__id", "M0"))
  d[, dup := if (.N == 1L) 0 else as.double(seq_len(.N)), by = c("interview__id", "membres__id", "M0")]
  etat$QM_S1_dup_supprimes <- sum(d$dup > 1)
  d <- d[!(dup > 1)]

  # do: :42-46  suppression des blancs autour des variables texte
  nettoyer_chaines(d)

  # do: :68  gen flag_M1A_missing = (M1A==.a & membre_id_v1!="##N/A##")
  d[, flag_M1A_missing := st_and(st_eq(M1A, st_manquant("a")), st_ne(membre_id_v1, "##N/A##"))]
  seg(69, 292)
  # do: :293  bysort interview__key: egen sexe_chef = max(cond(V1M4==1, M5, .))
  d[, sexe_chef := egen_max(stf_cond(st_eq(V1M4, 1), M5, st_manquant("")), interview__key)]
  seg(294, 1171)
  # do: :1172-1180  âge du chef de ménage et écarts d'âge
  supprimer_vars(d, c("cm", "agecm", "ecart_age", "ecart_age1"))
  d[, cm := st_eq(M4, 1)]
  d[, agecm := gen_si(st_mul(cm, AgeAnnee), st_vrai(st_eq(M4, 1)))]
  d[, Age_Cm_men := egen_total(agecm, interview__key)]
  d[, ecart_age := st_sub(Age_Cm_men, AgeAnnee)]
  d[, ecart_age1 := st_sub(AgeAnnee, Age_Cm_men)]
  seg(1181, 1377)
  # do: :1378  bysort interview__key: egen mode_M15 = mode(M15)
  d[, mode_M15 := egen_mode(M15, interview__key)]
  seg(1379, 1384)
  supprimer_vars(d, "mode_M15")                                        # do: :1385
  seg(1386, 1451)
  # do: :1452-1458  nationalité du chef et du conjoint (hommes)
  d[, nat_cm_homme := gen_si(M19, st_vrai(st_and(st_and(st_eq(M4, 1), st_eq(M5, 1)), st_not(stf_missing(M19)))))]
  d[, nat_cm_homme_final := egen_max(nat_cm_homme, interview__key)]
  d[, nat_conjoint_homme := gen_si(M19, st_vrai(st_and(st_and(st_eq(M4, 2), st_eq(M5, 1)), st_not(stf_missing(M19)))))]
  d[, nat_conjoint_homme_final := egen_max(nat_conjoint_homme, interview__key)]
  seg(1459, 1476)
  supprimer_vars(d, c("nat_cm_homme", "nat_cm_homme_final", "nat_conjoint_homme", "nat_conjoint_homme_final"))  # :1477
  seg(1478, 1533)
  # do: :1534-1537  mode de M22 par ménage (calculé sur les non manquants)
  nm <- !st_vrai(stf_missing(d$M22))
  d[, mode_M22 := NA_real_]
  d[nm, mode_M22 := egen_mode(M22, interview__key)]
  d[, mode_M22_final := egen_max(mode_M22, interview__key)]
  seg(1538, 1545)
  supprimer_vars(d, c("mode_M22", "mode_M22_final"))                  # do: :1546
  seg(1547, 1593)
  # do: :1594-1600  statut matrimonial du chef et du conjoint
  d[, M23A_cm := gen_si(M23A, st_vrai(st_and(st_eq(M4, 1), st_not(stf_missing(M23A)))))]
  d[, M23A_cm_final := egen_max(M23A_cm, interview__key)]
  d[, M23A_conjoint := gen_si(M23A, st_vrai(st_and(st_eq(M4, 2), st_not(stf_missing(M23A)))))]
  d[, M23A_conjoint_final := egen_max(M23A_conjoint, interview__key)]
  seg(1601, 1625)
  supprimer_vars(d, c("M23A_cm", "M23A_conjoint", "M23A_cm_final", "M23A_conjoint_final"))  # :1626
  seg(1627, 1715)
  # do: :1716-1718  retrait des variables de travail
  supprimer_vars(d, c("HH2", "HH3", "HH12", "HH13", "HH4", "HH6", "HH8B", "V1interviewkey", "V1MODINTR",
                      "M0__0", "rgmen", "membre_id_v1_IND", "M4Confirm"))
  supprimer_vars(d, c("dup", "commentaire", "cm", "agecm", "Age_Cm_men", "ecart_age", "ecart_age1", "HH14a", "HH14a_Aut"))
  # Les bysort interview__key trient la base par ménage (do: :293) ; R garde
  # un ordre stable par interview__key.
  data.table::setorderv(d, "interview__key")
  if (is.null(etat$sortie_menage)) etat$sortie_menage <- list()
  etat$sortie_menage$QM_S1_composition_menage <- d
  invisible(etat)
}
