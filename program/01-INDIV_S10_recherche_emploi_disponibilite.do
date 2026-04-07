
*================================================
*********RECHERCHE D'EMPLOI ET DISPONIBILITÉ

****RESPONSABLE: SEKONGO MAMADOU (PECHOUX )
*=============================================

/*

use "$datain_brute\membres.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_brute\qx_eec_vf.dta", keepusing(HH12 HH13 HH3)

drop if _merge!=3
cap drop _merge

*/
********************************

use "$datain_standard\INDIV_S10_recherche_emploi_disponibilite.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH2 HH3 HH12 HH13 HH4 HH6 HH8B rgmen)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(membre_id_v1_IND EP1a  hhb HH14a ) 
drop if _merge!=3
cap drop _merge


////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
////////////////
********************RECHERCHE D’EMPLOI ET DISPONIBILITÉ (SRH)********
****SRH1:SRH1. Au cours de la période allant du %DateJ3 0% au %DateJ0% (30 jours), avez-vous cherché un emploi à titre indépendant ou salarié, à tem ps partiel ou non, ou un travail de type apprent issage rémunéré?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH1) & EN_EMP == 0 & M4Confirm>=15 & !inlist(M4Confirm,.,.a)
*13


cap drop commentaire_SRH
gen commentaire_SRH=""

replace commentaire_SRH="Valeurs manquantes: Est ce que ceux qui devaient repondre à la question SRH1 et n'ont pas  repondu? " if missing(SRH1) & EN_EMP == 0 & M4Confirm>=15 & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH12 HH13 SRH1 commentaire_SRH using "$folderpath/document/SRH1_Manquants.xlsx" if missing(SRH1) & EN_EMP == 0 & M4Confirm>=15 & !inlist(M4Confirm,.,.a) ,firstrow(variables) replace
}

***Correction: Pas de correction possible
replace SRH1=2 if missing(SRH1) & !missing(SRH2)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH1) & !(EN_EMP == 0 & M4Confirm>=15) & !inlist(M4Confirm,.,.a)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(SRH1) & !inlist(SRH1,1,2)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 


****SRH2
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH2) & SRH1 == 2 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH2) & SRH1 != 2
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if  !missing(SRH2) & !inlist(SRH2,1,2)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 

***SRH2A 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH2A) & SRH2 == 2 

replace commentaire_SRH="ceux qui devaient repondre à la question SRH2A et n'ont pas repondu" if missing(SRH2A) & SRH1 == 2 

if r(N) > 0 {
*export excel interview__key HH13 SRH2A  commentaire_SRH using "$folderpath/document/SRH2A_Manquants.xlsx" if missing(SRH2A) & SRH1 == 2 ,firstrow(variables) replace
}

**********COrrection: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH2A) & SRH1 != 2

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH2) & !inlist(SRH2,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 

****SRH3 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH3) & (SRH1==1 | SRH2==1 | SRH2A==1) 

replace commentaire_SRH="ceux qui devaient repondre à la question ont veritablement repondu" if missing(SRH3) & (SRH1==1 | SRH2==1 | SRH2A==1) 

if r(N) > 0 {
*export excel interview__key HH12 HH13 SRH3 commentaire_SRH using "$folderpath/document/SRH3_Manquants.xlsx" if missing(SRH3) & (SRH1==1 | SRH2==1 | SRH2A==1)  ,firstrow(variables) replace
}
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH3) & !((SRH1==1 | SRH2==1 | SRH2A==1) )

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH3) & !inrange(SRH3,1,19)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 

****SRH4 Depuis quel mois êtes-vous sans emploi et essayez-vous de trouve

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH4) & (SRH1==1 | SRH2==1 | SRH2A==1) 

*replace commentaire_SRH="ceux qui devaient repondre à la question ont veritablement repondu" if missing(SRH4) & (SRH1==1 | SRH2==1 | SRH2A==1) 

if r(N) > 0 {
*export excel interview__key HH12 HH13 SRH4 commentaire_SRH using "$folderpath/document/SRH4_Manquants.xlsx" if  missing(SRH4) & (SRH1==1 | SRH2==1 | SRH2A==1)   ,firstrow(variables) replace
}
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH4) & !((SRH1==1 | SRH2==1 | SRH2A==1) )

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH4) & !inrange(SRH4,1,12) & SRH4!=9998
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 



****SRH4A 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH4A) & (SRH1==1 | SRH2==1 | SRH2A==1)

*replace commentaire_SRH="ceux qui devaient repondre à la question ont veritablement repondu" if missing(SRH4A) & (SRH1==1 | SRH2==1 | SRH2A==1)


if r(N) > 0 {
*export excel interview__key HH12 HH13 SRH4A commentaire_SRH using "$folderpath/document/SRH4A_Manquants.xlsx" if  missing(SRH4A) & (SRH1==1 | SRH2==1 | SRH2A==1)   ,firstrow(variables) replace
}
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH4A) & !((SRH1==1 | SRH2==1 | SRH2A==1) )

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH4A) & (SRH4A > 2025 | SRH4A<1922 ) & SRH4A !=9998

replace SRH4A =2025 if !missing(SRH4A) & (SRH4A > 2025 | SRH4A<1922 ) & SRH4A !=9998
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 


***SRH4B
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH4B) & (SRH1==1 | SRH2==1 | SRH2A==1) & SRH4A==9998

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH4B) & !((SRH1==1 | SRH2==1 | SRH2A==1) & SRH4A==9998)

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH4B) & !inrange(SRH4B,1,6) 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 

******SRH5 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH5) & (SRH2==2 & SRH2A==2)

replace commentaire_SRH="ceux qui devaient repondre à la question SRH5 n'ont pas repondu" if missing(SRH5) & (SRH2==2 & SRH2A==2)
if r(N) > 0 {
*export excel interview__key HH12 HH13 SRH5 commentaire_SRH using "$folderpath/document/SRH5_Manquants.xlsx" if missing(SRH5) & (SRH2==2 & SRH2A==2) ,firstrow(variables) replace
}
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH5) & !(SRH2==2 & SRH2A==2)

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH5) & !inlist(SRH5,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

******SRH6
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH6) &  SRH2A==2

replace commentaire_SRH="ceux qui devaient repondre à la question SRH6 n'ont pas repondu" if missing(SRH6) &  SRH2A==2


*export excel interview__key HH12  HH13 SRH6  commentaire_SRH using "$folderpath/document/SRH6_Manquants.xlsx" if missing(SRH6) &  SRH2A==2,firstrow(variables) replace

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH6) & SRH2A!=2

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH5) & !inlist(SRH5,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

******SRH7
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH7) & SRH2== 2
*count if inlist(SRH7,24,27)

/*
ENSEIGNANT EN PERIODE DE VACANCES
TRAVAIL
FONCTIONNAIRE DANS LE  PRIVÉ
NE SOUHAITE PAS CHANGER D'EMPLOI DE COUTURE
EN CONGES
ELLE A DEJA UNE PLANTATION EN SON NOM, MAIS N'Y TRAVAIL PAS VU L'AGE AVANCE.
CHAMP D AUBERGINE ET DE HARICOT
ENSEIGNANT EN VACANCE


*/

br interview__key membres__id  SRH7_Aut if inlist(SRH7,24,27) & SRH7_Aut!=""

replace commentaire_SRH="Ils sont en emploi, mais il se retrouve en SRH" if  inlist(SRH7_Aut,"ÉTAIT EN EMPLOI À CETTE PÉRIODE","MARABOUT","TRAVAILLEUSE DU SEXE")

*export excel interview__key membres__id HH12 HH13 SRH7_Aut rgmen using "$folderpath/document/SRH7_en_emploi.xlsx" if  inlist(SRH7_Aut,"ÉTAIT EN EMPLOI À CETTE PÉRIODE","MARABOUT","TRAVAILLEUSE DU SEXE"),firstrow(variables) replace


count if missing(SRH7) &  SRH2A==2

replace commentaire_SRH="ceux qui devaient repondre à la question SRH7 et n'ont repondu" if missing(SRH7) &  SRH2A==2

if r(N) > 0 {
*export excel interview__key membres__id HH12 HH13 SRH7 commentaire_SRH  using "$folderpath/document/SRH7_Manquants.xlsx" if missing(SRH7) &  SRH2A==2,firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH7) & SRH2A!=2

br SRH2A SRH7 if !missing(SRH7) & SRH2A==1

replace SRH2A=2 if !missing(SRH7) & SRH2A==1

br SRH1 SRH7 if !missing(SRH7) & SRH1==1

br SRH2 SRH7 if !missing(SRH7) & SRH2==1


*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH7) & !inrange(SRH7,1,27)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


******SRH7_Aut
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH7_Aut) &  (SRH7 == 24 | SRH7== 27)

if r(N) > 0 {
export excel interview__key HH13 SRH7_Aut using "$folderpath/document/SRH7_Aut_Manquants.xlsx" if missing(SRH7_Aut) &  (SRH7 == 24 | SRH7== 27),firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH7_Aut) &  SRH7 != 24 & SRH7!= 27

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if SRH7_Aut=="##N/A##"
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

****SRH7A.Spécifiquement, quelle est la principale raison pour laquelle vous n’avez pas créé une exploitation agricole (champs, élevage, etc.) au c ours de la période allant du %DateJ30% au %Da teJ0% (30 jours) ?



/*



*/

br interview__key membres__id SRH7A SRH7A_Aut if inlist(SRH7A,7) & SRH7A_Aut!=""


count if missing(SRH7A) & SRH2A==2

*replace commentaire_SRH="Ils sont en emploi, mais il se retrouve en SRH" if  inlist(SRH7A_Aut,"APPRENTI COUTURE", "APPRENTI MÉCANICIEN", "APPRENTI DE COIFFURE", "APPRENTI DE COUTURE", "EN APPRENTISSAGE", "Activités religieuses (Pasteur)", "OCCUPE DANS LE CHAMP FAMILIAL") | inlist(SRH7A_Aut, "APPRENTISSAGE", "AIDE SON MARI DANS LE CHAMP DE RIZ POUR LA CONSOMMATION DU MENAGE", "STAGIAIRE NON PAYÉ", "OCCUPÉ PAR MON APPRENTISSAGE DE MÉCANIQUE", "APPRENTI FRIGORISTE","JE TRAVAILLE DANS LE CHAMP DE MON MARI","TRAVAUX CHAMPÊTRES") | inlist(SRH7A_Aut,"EN DEUIL DEPUIS MAINTENANT DEUX MOIS, ELLE A STOPPÉ TOUTES SES ACTIVITÉS COMME LE VEUT LEUR TRADITION ET NE SAIT PAS QUAND ELLE VA REPRENDRE SES ACTIVITÉS. C'EST SON MARI QUI LUI DONNE DE L'ARGENT POUR SUBVENIR A SES BESOINS POUR LE MOMENT","JE CULTIVE LE JARDIN POTAGER FAMILIAL","TRAVAUX CHAMPÊTRES", "apprenti non payé", "TRAVAUX CHAMPÊTRES", "Vous travailliez dans la plantation/ferme/pisciculture/pêche pour le compte du ménage") | inlist(SRH7A_Aut, "TRAVAUX CHAMPÊTRES", "APPREND LA COUTURIERE ACTUELLEMENT"; "APPRENTI NON PAYE DU PERE", "JE TRAVAILLE DANS LE CHAMP FAMILIALE", "AIDE SON MARI A TRAVAILLER DANS SON CHAMP DE RIZ POUR LA CONSOMMATION DU MENAGE", "EN APPRENTISSAGE")


*export excel interview__key membres__id HH12 HH13 SRH7A_Aut commentaire_SRH rgmen HH2 using "$folderpath/document/SRH7A_en_emploi.xlsx" if  inlist(SRH7A_Aut,"Travailles dans la plantation pour le compte du ménage", "AIDE SON PERE DANS LE CHAMP FAMILIAL", "APPRENTI DE COIFFURE", "APPRENTI DE COUTURE", "EN APPRENTISSAGE", "Activités religieuses (Pasteur)", "OCCUPE DANS LE CHAMP FAMILIAL") | inlist(SRH7A_Aut, "APPRENTISSAGE", "AIDE SON MARI DANS LE CHAMP DE RIZ POUR LA CONSOMMATION DU MENAGE", "STAGIAIRE NON PAYÉ", "OCCUPÉ PAR MON APPRENTISSAGE DE MÉCANIQUE", "APPRENTI FRIGORISTE","JE TRAVAILLE DANS LE CHAMP DE MON MARI","TRAVAUX CHAMPÊTRES") | inlist(SRH7A_Aut,"EN DEUIL DEPUIS MAINTENANT DEUX MOIS, ELLE A STOPPÉ TOUTES SES ACTIVITÉS COMME LE VEUT LEUR TRADITION ET NE SAIT PAS QUAND ELLE VA REPRENDRE SES ACTIVITÉS. C'EST SON MARI QUI LUI DONNE DE L'ARGENT POUR SUBVENIR A SES BESOINS POUR LE MOMENT","JE CULTIVE LE JARDIN POTAGER FAMILIAL","TRAVAUX CHAMPÊTRES", "apprenti non payé", "TRAVAUX CHAMPÊTRES", "Vous travailliez dans la plantation/ferme/pisciculture/pêche pour le compte du ménage") | inlist(SRH7A_Aut, "TRAVAUX CHAMPÊTRES", "APPREND LA COUTURIERE ACTUELLEMENT"; "APPRENTI NON PAYE DU PERE", "JE TRAVAILLE DANS LE CHAMP FAMILIALE", "AIDE SON MARI A TRAVAILLER DANS SON CHAMP DE RIZ POUR LA CONSOMMATION DU MENAGE", "EN APPRENTISSAGE"),firstrow(variables) replace

*export excel interview__key HH12 HH13 SRH7A  using "$folderpath/document/SRH7A_Incoherance.xlsx" if  missing(SRH7A) & SRH2A==2,firstrow(variables) replace

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 

count if !missing(SRH7A) & SRH2A!=2

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

******SRH7A_Aut
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH7A_Aut) &  SRH7A == 7

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH7A_Aut) &  SRH7A != 7 

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 

count if SRH7A_Aut=="##N/A##"

if r(N) > 0 {
*export excel interview__key HH12 HH13 SRH7A_Aut  using "$folderpath/document/SRH7A_Aut_Inattendu.xlsx" if SRH7A_Aut=="##N/A##",firstrow(variables) replace
}
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


****SRH8. Quand prévoyez-vous de commencer à t ravailler dans ce nouvel emploi ou cette nouvell e entreprise ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH8) &  SRH7 == 18

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH8) & SRH7 != 18

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH8) & !inrange( SRH8,1,3)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 


***** SRH9. Si cela dépendait de vous, auriez-vous co mmencé à travailler la semaine allant du %Date J7% au %DateJ0% , dans ce nouvel emploi ou ce tte nouvelle entreprise ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH9) &  SRH7 == 18

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH9) & SRH7 != 18

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH9) & !inrange( SRH9,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 


***SRH11. Si vous aviez trouvé un emploi durant la semaine du %DateJ7% au %DateJ0% (7 jours), a uriez-vous pu l’occuper dans les deux semaines suivantes, c’est-à-dire du %DateJ_1% à %DateJ_1 4% ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH11) & ( EN_EMP == 0 & M4Confirm>=15 ) & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH12 HH13 SRH11  using "$folderpath/document/SRH11_Aut_manquants.xlsx" if missing(SRH11) & ( EN_EMP == 0 & M4Confirm>=15 ) & !inlist(M4Confirm,.,.a),firstrow(variables) replace
}

****Correction: RAS


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH11) & !(EN_EMP == 0 & M4Confirm>=15 ) & !inlist(M4Confirm,.,.a)

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH11) & !inrange( SRH11,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*******SRH12A.Quelles sont les raisons de votre indisponibilité?? 
*************|||||Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
 
*** Boucle pour vérifier les réponses manquantes pour chaque sous-question de SRH12A et les exporter si elles existent: 
forvalues i = 1/27 {
    * Compter combien de personnes devaient répondre mais n'ont pas répondu pour chaque sous-variable de SRH12A  
    count if missing(SRH12A__`i') & (EN_EMP == 0 & M4Confirm >= 15 & !inlist(M4Confirm, .,.a) ) & SRH11 == 2  
    
    * Si il existe des réponses manquantes, les exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH12 HH13 SRH12A__`i' using "$folderpath/document/SRH12A__`i'.xlsx" if if missing(SRH12A__`i') & (EN_EMP == 0 & M4Confirm >= 15 & !inlist(M4Confirm, .,.a) ) & SRH11 == 2 , firstrow(variables) replace
        display "Exportation terminée pour SRH12A__`i' avec " r(N) " réponses manquantes"
    }
	*Si pas d'erreurs alors  le message suivant apparaittra
    else {
        display "Pas de réponses manquantes pour SRH12A__`i'"
    }
}

*************Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
***Les identifier et les exporter s'ils existent apres identification____
forvalues i = 1/27 {
    * Vérification des individus qui ont répondu à SRH12A mais ne devaient pas y répondre
    count if !missing(SRH12A__`i') & (SRH11 != 2 | EN_EMP == 1 | M4Confirm < 15) & !inlist(M4Confirm, .,.a) 
	
    * Si des réponses non attendues existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH12 HH13 SRH12A__`i' using "$folderpath/document/SRH12A__`i'_non_attendu.xlsx" if !missing(SRH12A__`i') & SRH11 != 2, firstrow(variables) replace
        display "Exportation terminée pour SRH12A_1__`i' avec " r(N) " réponses non attendues"
    }
	*Si pas d'erreurs alors  le message suivant apparaittra
    else {
        display "Pas de réponses non attendues pour SRH12A__`i'"
    }
}

*********Etape3: Est ce que les reponses données sont celles qu'on atendait? 

forvalues i = 1/27 {
    * Vérification des réponses données dans SRH12A
    count if !missing(SRH12A__`i') & !inrange(SRH12A__`i', 0, 1)
    
    * Si des réponses inattendues existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH12 HH13 SRH12A__`i' using "$folderpath/document/SRH12A_inattendus__`i'.xlsx" if !missing(SRH12A__`i') & !inrange(SRH12A__`i', 0, 1), firstrow(varlabels) replace
        display "Exportation terminée pour SRH12A__`i' avec " r(N) " réponses inattendues"
    }
    else {
        display "Toutes les réponses sont correctes pour SRH12A__`i'"
    }
}

*Etape4: Les reponses données sont elles coherentes au regard des precedentes?: RAS 



****SRH12A_Aut1 raison involontaire à préciser
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH12A_Aut1) & SRH12A__27 == 1 // presence de valeurs manquantes

***Exportation
if r(N) > 0 {
export excel interview__key HH12 HH13  SRH12A__27  SRH12A_Aut1  using "$folderpath/document/SRH12A_Aut1_manquants.xlsx" if missing(SRH12A_Aut1) & SRH12A__27 == 1,firstrow(variables) replace
}

***Correction: RAS car necessite de revenir aux agents

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH12A_Aut1) & SRH12A__27 == 0 // le saut ne marche pas 

replace SRH12A__27=1 if !missing(SRH12A_Aut1) & SRH12A__27 == 0
*15

**Exportation: 
if r(N) > 0 {
*export excel interview__key HH12 HH13 SRH12A__27  SRH12A_Aut1  using "$folderpath/document/SRH12A_Aut1_sauts.xlsx" if !missing(SRH12A_Aut1) & SRH12A__27 == 0,firstrow(variables) replace
}

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if SRH12A_Aut1=="##N/A##"
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 



***SRH12A_Aut2. Autre raison volontaire à précise 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH12A_Aut2) & SRH12A__27 == 1 // pas de valeurs manquantes

br SRH12A_Aut2 SRH12A__27 if missing(SRH12A_Aut2) & SRH12A__27 == 1 

replace SRH12A__27=2 if missing(SRH12A_Aut2) & SRH12A__27 == 1 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH12A_Aut2) & SRH12A__27 != 1

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if SRH12A_Aut2=="##N/A##"

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 

*******SRH12B. Si un emploi était disponible hors de v

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH12B) & (SRH6==1 | SRH11==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH12B) & !(SRH6==1 | SRH11==1)

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(SRH12B) & !inrange( SRH12B,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

***SRH13. Lequel des éléments suivants décrit le mieux ce que vous faites principalement actuellement ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?

/*
TRAVAIL
AIDE MAÇON
TRAVAILLEUR FAMILIAL
CUISINIERE EN CANTINE
APPRENTI MENUISIER
TRAVAILLEUR  SAISONNIER


*/

*count if inlist(SRH13,8)
 
count if missing(SRH13) & EN_EMP == 0 & M4Confirm>=15 & !inlist(M4Confirm,.,.a)
*58

br SRH13 SRH13_Aut if missing(SRH13) & EN_EMP == 0 & M4Confirm>=15 & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH13 SRH13  using "$folderpath/document/SRH13_Manquants.xlsx" if missing(SRH13) & EN_EMP == 0 & M4Confirm>=15 & !inlist(M4Confirm,.,.a) ,firstrow(variables) replace
}

***Correction: LRAS : La correction necessite de revenir aux agents


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH13) & !(EN_EMP == 0 & M4Confirm>=15) & !inlist(M4Confirm,.,.a)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(SRH13) & !inrange(SRH13,1,8)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 

*** SRH13_Aut. Veuillez préciser ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(SRH13_Aut) &  SRH13 == 8 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(SRH13_Aut) &  SRH13 != 8 

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 

count if SRH13_Aut=="##N/A##"

if r(N) > 0 {
*export excel interview__key HH12 HH13 SRH7A_Aut  using "$folderpath/document/SRH13_Aut_Inattendu.xlsx" if SRH13_Aut=="##N/A##",firstrow(variables) replace
}

drop HH2 HH3 HH4 HH6 HH8B HH12 HH13 EN_EMP M4Confirm commentaire_SRH rgmen  EP1a  hhb HH14a


save "$standard_individu\INDIV_S10_recherche_emploi_disponibilite.dta", replace