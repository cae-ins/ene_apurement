*******************************************************************************
*      VERIFICATION ET TRAITEMENT DE LA SECTION "EMIGRATION"                  *
*                                                                             * 
*       RESPONSABLE : RENAUD HIVITES AKATTIA (PECHOUX)                                  *
*
*******************************************************************************

*use "$datain_brute\qx_eec_vf.dta", clear

*use "$datain_brute\QM_S0_identification.dta", clear
*52-28-83-18


use "$datain_standard\QM_S5_emmigration.dta", clear
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(hha rgmen HH13 ME1 ME2A ME2B__0-ME2B__59)
drop if _merge!=3
cap drop _merge




*===================================================================================================
** ME1 : membres de votre ménage qui se sont installés à l'étranger et qui y résident actuellement
*==================================================================================================

*Problem 1: ceux qui devaient ils repondre ont ils repondu
count if !missing(hha1_EM) & rgmen==1 & ME1==.a
*RAS


*br if !missing(hha) & rgmen==1 & ME1==.a

*Idenification des agents ayant fait des erreurs 
*export excel interview__key HH13 ME1 hha rgmen  using "$folderpath/document/Erreur_ME1_NA" if hha!="" & rgmen==1 & missing(ME1), firstrow(varlabels) replace 

*Correction
*replace ME1=2 if hha!="" & rgmen==1 & ME1==.a

*Problem 2: Ceux qui ont repondus devaient ils repondre 
*count if ME1!=.a & missing(hha) | rgmen==2
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=====================================
*ME2A SI OUI, combien de membres se sont installés à l’étranger et y résident actuellement
*=====================================

*Problem 1: ceux qui devaient repondre ont ils repondus
count if ME1==1 & missing(ME2A)
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if (ME1==2 & !missing(ME2A))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*Il ne faut pas que les variables renseignées soient negatives ou de type text
count if (ME2A<0 | ME2A>50 & ME2A !=. & ME2A !=.a)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=====================================
*ME2B. Nom des personnes ayant quitté le ménage
*=====================================

*Problem 1: ceux qui devaient repondre ont ils repondus
foreach var of varlist ME2B__0-ME2B__59 {
count if missing(`var') & ME1==1
}



*Problem 2: Ceux qui ont repondu devaient ils repondre 
foreach var of varlist ME2B__0-ME2B__59 {
count if !missing(`var') & ME1==2
}
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*Il ne faut pas que les variables renseignées soient negatives ou de type text
count if (ME2A<0 | ME2A>50 ) & !missing(ME2A)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS



*save "$datain_brute\qx_eec_vf.dta", replace


*use "$datain_brute\emigration.dta", clear
*merge m:1 interview__key using "$datain_brute\qx_eec_vf.dta", keepusing( HH13  )
*drop if _merge!=3
*cap drop _merge

*==============================
*ME3. Quel est le sexe
*============================

*Problem : ceux qui devaient repondre ont ils repondu 
count if  missing(ME3)
*RAS


*Identifcation des agents ayant fait des erreurs 
*export excel interview__key HH13 ME3 using "$folderpath/document/Erreur_ME5A1" if  missing(ME3), firstrow(varlabels) replace 

*replace ME3=1 if interview__key=="06-24-61-17" & ME2B=="KABORE PASCAL"

*===========================
*ME4. Quel âge avait-t-il à son départ?
*===========================

*Problem 1: ceux qui devaient repondre ont ils repondus
count if missing(ME4)
*RAS

*Identifcation des agents ayant fait des erreurs 
*export excel interview__key HH13 ME4 using "$folderpath/document/Erreur_ME5A1" if  missing(ME4), firstrow(varlabels) replace 

*problem 2: les valeurs renseignees sont elles permises 
count if ME4>=150 &  !inlist(ME4,.,.a,998)

*=========================
*ME5A1. Depuis quelle Année  a quitté ce ménage pour l’extérieur ?
*==========================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(ME5A1)
*RAS

*Identifcation des agents ayant fait des erreurs 
*export excel interview__key HH13 ME5A1 using "$folderpath/document/Erreur_ME5A1" if  missing(ME5A1), firstrow(varlabels) replace 

*Problem 2: les valeurs renseignees sont elles permises 
count if (ME5A1>2024  |ME5A1<=1960) & !inlist(ME5A1,9998,.,.a)
*5 personnes concernées 


*Identifcation des agents ayant fait des erreurs 
export excel interview__key HH13 ME5A1 using "$folderpath/document/Erreur_ME5A1" if (ME5A1>2024  |ME5A1<=2019) & !inlist(ME5A1,9998,.,.a), firstrow(varlabels) replace 


*Proposition de correction (by Amine)
replace ME5A1 = 2024-ME5A1 if  (ME5A1>2024  |ME5A1<=1960) & !inlist(ME5A1,9998,.,.a)


*Correction
*pour ses années incorrectes, on va remplacer par 'ne sait pas'
*replace ME5A1=9998 if (ME5A1>2024  |ME5A1<=1960) & !inlist(ME5A1,9998,.,.a)

*Problem 4: Vraisemblance des reponses
*RAS

*========================
*ME5M1. Depuis quel mois a quitté ce ménage pour l’extérieur 
*======================

*Problem1: Ceux qui devaient repondre ont ils repondus
count if missing(ME5M1)& ME5A1!=9998
*RAS
 
*Identifcation des agents ayant fait des erreurs 
*export excel interview__key HH13 ME5M1 using "$folderpath/document/Erreur_ME5A1" if  missing(ME5M1), firstrow(varlabels) replace 


*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ME5M1)& ME5A1==9998 // RAS, car il s'agit des individus pour qui nous avions remplacé l'année par 9998

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 ME5M1 using "$folderpath/document/Erreur_ME5M1" if !missing(ME5M1)& ME5A1==9998, firstrow(varlabels) replace 

*Correction
*replace ME5M1=. if !missing(ME5M1)& ME5A1==9998

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ME5M1,1,12)& !inlist(ME5M1,9998,.,.a)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*==========================
*ME5A.Depuis combien d'Année a quitté ce ménage pour l’extérieur ?
*==========================

*Problem1: Ceux qui ont repondus devaient ils repondre 
count if missing(ME5A) & ME5A1==9998
*RAS car il s'agit des individus pour qui nous avons changer la valeur de ME5A1. 

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 ME5A using "$folderpath/document/Erreur_ME5A" if missing(ME5A)&ME5A1==9998, firstrow(varlabels) replace 

*Problem 2: Ceux qui devaient pas repondre ont ils repondus 
count if !missing(ME5A)&ME5A1!=9998
*RAS

*Problem 3: les valeurs renseignées sont elles permises 
count if (ME5A>5 |ME5A<0) & !missing(ME5A)
*3 individus 
*RAS

*Identifcation des agents ayant fait des erreurs 
*export excel interview__key HH13 ME5A using "$folderpath/document/Erreur_ME5A1" if  (ME5A>5 |ME5A<0) & !missing(ME5A), firstrow(varlabels) replace 



*Problem 4: Vraisemblance des reponses 
*RAS

*=================================
*ME5M. %rostertitle% a quitté ce ménage depuis %ME5A% an(s) combien de mois pour l’extérieur
*====================================

*Problem 1: Ceux qui devaient repondreont ils repondu
count if missing(ME5M) & !inlist(ME5A,9998,.,.a)
*RAS

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 ME5M using "$folderpath/document/Erreur_ME5M" if missing(ME5M) & ME5A!=9998, firstrow(varlabels) replace 

*Correction
*replace ME5A=9998 if missing(ME5M) & ME5A!=9998

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(ME5M) & ME5A==9998

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(ME5M,1,12) & !inlist(ME5M,9998,.,.a)
*RAS

*Problem 4: Vraisemblance des reponses

*========================
*ME6. Quel niveau d’enseignement %rostertitle% avait-il atteint à son départ ?
*========================

*Problem 1: ceux qui devaient repondre ont ils repondu
count if missing(ME6) & ME4>3
*1 individus  concernés
*RAS

*Identification des agents ayany fait des erreurs
*export excel interview__key HH13 ME6 using "$folderpath/document/Erreur_ME6" if missing(ME6) & ME4>3, firstrow(varlabels) replace 

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(ME6) & ME4<=3
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(ME6,0,12) & !missing(ME6)

*Vraisemblance des reponses 
*Coherence avec l'age

count if ME4<=10 & ME4>3 & ME6>6 & missing(ME6) // un enfant d'au plus 10 ans ne peut etre à un niveau superieur au secondaire cycle II
*RAS

*==========================
*ME7. Dans quel pays vit actuellement
*==========================

*Problem 1: Ceux qui doivent repondre ont ils repondus
count if missing(ME7)
*RAS
 
*Identification des agents ayany fait des erreurs
*export excel interview__key HH13 ME6 using "$folderpath/document/Erreur_ME6" if missing(ME7), firstrow(varlabels) replace 


*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(ME7,1,216)
*RAS 

*Identification des agents ayany fait des erreurs
*export excel interview__key HH13 ME6 using "$folderpath/document/Erreur_ME6" if !inrange(ME7,1,216), firstrow(varlabels) replace 


*================================
*ME8. Pour quelle principale raison %est parti à l’extérieur 
*================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(ME8) 
*RAS 

*Identification des agents ayany fait des erreurs
*export excel interview__key HH13 ME6 using "$folderpath/document/Erreur_ME6" if  missing(ME8) , firstrow(varlabels) replace 


*Problem 3: les valeurs renseignées sont elles permises 
count if !inrange(ME8,1,9)
*RAS

*Identification des agents ayany fait des erreurs
*export excel interview__key HH13 ME6 using "$folderpath/document/Erreur_ME6" if !inrange(ME8,1,9) , firstrow(varlabels) replace 


*Problem 4: vraisemblance des reponses 
*Selon le BIT, l'age legal pour travailler c'est 15ans. Un enfant de moins de cet age ne peut donc emigrer pour des raisons d'affectation de travail
count if ME8==4 & ME4<15
*RAS

*================================
*ME8_Aut. Veuillez préciser 
*=================================
*Problem 1: ceux qui devaient repondre ont ils repondu
count if missing(ME8_Aut) & ME8==9
*RAS

*Problem2: Ceux qui ont repondu devaient ils repondre 
count if !missing(ME8_Aut) & ME8!=9
*RAS

*Problem3 & Problem4 : Deja regardé lors du recodage des autres à préciser

*===============================
*ME9. Quelle était la catégorie socio-économique avant son départ pour l’extérieur
*==============================
*Problem1: ceux qui devaient repondre ont ils repondu
count if missing(ME9)
*RAS 

*Identification des agents ayany fait des erreurs
*export excel interview__key HH13 ME6 using "$folderpath/document/Erreur_ME6" if  missing(ME9) , firstrow(varlabels) replace 


*Problem3: les valeurs renseignées sont elles permises 
count if !inrange(ME9,1,11) & !inlist(ME9,9998,.,.a)

*RAS

*=============================
*ME9_Aut : Autres à preciser
*=============================

*Problem 1: ceux qui onME9_Autt repondu devaient ils repondre 
count if missing() & inlist(ME9,10,11)

*RAS

*Problem 2 : ceux qui ont repondu devaient ils repondre 
count if !missing(ME9_Aut) & !inlist(ME9,10,11,.,.a)
*RAS





drop rgmen HH13 hha ME1 ME2A ME2B__0 ME2B__1 ME2B__2 ME2B__3 ME2B__4 ME2B__5 ME2B__6 ME2B__7 ME2B__8 ME2B__9 ME2B__10 ME2B__11 ME2B__12 ME2B__13 ME2B__14 ME2B__15 ME2B__16 ME2B__17 ME2B__18 ME2B__19 ME2B__20 ME2B__21 ME2B__22 ME2B__23 ME2B__24 ME2B__25 ME2B__26 ME2B__27 ME2B__28 ME2B__29 ME2B__30 ME2B__31 ME2B__32 ME2B__33 ME2B__34 ME2B__35 ME2B__36 ME2B__37 ME2B__38 ME2B__39 ME2B__40 ME2B__41 ME2B__42 ME2B__43 ME2B__44 ME2B__45 ME2B__46 ME2B__47 ME2B__48 ME2B__49 ME2B__50 ME2B__51 ME2B__52 ME2B__53 ME2B__54 ME2B__55 ME2B__56 ME2B__57 ME2B__58 ME2B__59

save "$standard_menage\QM_S5_emmigration.dta", replace




