# =============================================================================
# 11_QM_S2_S3.R
#   01-QM_S2_education_formation.do       -> etape_QM_S2()
#   01-QM_S3_formation_professionnelle.do -> etape_QM_S3()
# Même schéma que QM_S1 : règles extraites appliquées par segments de lignes,
# instructions procédurales portées entre les segments.
# =============================================================================

#' Applique les règles d'un fichier par segments et vérifie que chaque règle
#' active tombe dans un segment.
segmenteur <- function(regles, fichier, segments) {
  r <- regles[regles$fichier_do == fichier, ]
  act <- r$ligne[r$statut == "actif"]
  ok <- vapply(act, function(l) any(l >= segments[, 1] & l <= segments[, 2]), TRUE)
  if (!all(ok)) stop(fichier, " : règles hors segments, lignes ", paste(act[!ok], collapse = ","))
  function(d, de, a) appliquer_regles(d, r, fichier, de, a)
}

#' gen <v> = <x> : copie numérique sans libellés (manquants étendus conservés).
copie_num <- function(x) { v <- as.double(unclass(x)); attributes(v) <- NULL; v }

etape_QM_S2 <- function(etat, regles) {
  f <- "01-QM_S2_education_formation.do"
  seg <- segmenteur(regles, f, rbind(c(21, 115), c(117, 139), c(141, 643), c(646, 952)))
  # do: :8-17  base + variables ménage (merge m:1) et individu (merge 1:1)
  d <- data.table::copy(etat$standard$QM_S2_education_formation)
  d <- fusionner_garder_apparies(d, etat$menage, "interview__key",
         c("V1interviewkey", "rgmen", "HH01", "HH2", "HH12", "HH2A", "HH8", "rghab", "rgmen", "HH2", "HH4", "HH13", "hh"))
  d <- fusionner_garder_apparies(d, etat$membres, c("interview__key", "membres__id"),
         c("membre_id_v1", "AgeAnnee", "Statut_Res", "M7", "M6_A", "M4Confirm"))
  supprimer_vars(d, "commentaire"); d[, commentaire := ""]            # do: :19-20
  seg(d, 21, 115)
  d[, EF3_ := copie_num(EF3)]                                          # do: :116
  seg(d, 117, 139)
  supprimer_vars(d, "EF3_")                                            # do: :140
  seg(d, 141, 643)
  d[, EF7_New := NA_real_]; d[, EF11_New := NA_real_]                  # do: :644-645
  seg(d, 646, 952)
  supprimer_vars(d, c("HH01", "HH2A", "HH2", "HH4", "HH8", "rghab", "rgmen", "V1interviewkey", "HH12",
                      "HH13", "hh", "Statut_Res", "M6_A", "M7", "AgeAnnee", "commentaire"))  # do: :953
  etat$sortie_menage$QM_S2_education_formation <- d
  invisible(etat)
}

etape_QM_S3 <- function(etat, regles) {
  f <- "01-QM_S3_formation_professionnelle.do"
  seg <- segmenteur(regles, f, rbind(c(31, 243)))
  # do: :18-27
  d <- data.table::copy(etat$standard$QM_S3_formation_professionnelle)
  d <- fusionner_garder_apparies(d, etat$menage, "interview__key",
         c("V1interviewkey", "rgmen", "HH01", "HH2A", "HH8", "rghab", "rgmen", "HH2", "HH4", "HH12", "HH13", "hh"))
  d <- fusionner_garder_apparies(d, etat$membres, c("interview__key", "membres__id"),
         c("membre_id_v1", "AgeAnnee", "Statut_Res", "M6_A"))
  supprimer_vars(d, "commentaire"); d[, commentaire := ""]            # do: :29-30
  seg(d, 31, 243)
  supprimer_vars(d, c("HH01", "HH2A", "HH2", "HH4", "HH8", "rghab", "rgmen", "V1interviewkey", "HH13",
                      "hh", "Statut_Res", "M6_A", "AgeAnnee"))         # do: :244
  etat$sortie_menage$QM_S3_formation_professionnelle <- d
  invisible(etat)
}
