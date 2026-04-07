*================================================
*********DIFFICULTES FONCTIONNELLES

****RESPONSABLE: SEKONGO
*=============================================
*==============================================================================*

use "$datain_standard\QM_S6_difficultes_fonctionnelles.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH12 HH13 HH3)
drop if _merge!=3
cap drop _merge


cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\QM_S1_composition_menage.dta", keepusing(AgeAnnee Statut_Res)
drop if _merge!=3
cap drop _merge



**=================================================================
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
*==================================================================

* DIF1A : problèmes de vue, même avec ses lunettes pharmaceutiques?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
*count if missing(DIF1A) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")
*18 individus concernés

count if (DIF1A==.a) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")
*256 individus concernés. Il s'agit des entretiens pour lesquels la SECTION n'a pas été renseignée. 



*br interview__key membres__id DIF1A membre_id_v1 if (DIF1A==.a) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")



*Exportation:
export excel interview__key HH13 DIF1A using "$folderpath/document/Manquants_DIF1A" if DIF1A==.a & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##"),  firstrow(variables) replace


*Correction : Mettre ne sait pas car aucune autre variable ne permet de savoir
replace DIF1A=9998 if  DIF1A==.a & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if DIF1A==.a & (AgeAnnee<5 | Statut_Res!=1 | (membre_id_v1!="##N/A##" & membre_id_v1!=""))


*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(DIF1A) & !inlist(DIF1A,1,2,3,4,9997,9998)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

***DIF2A. %rostertitle% a-t-il des difficultés à ente ndre ?, même avec une ou des prothèse(s) audi tive(s)? Diriez-vous...

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if DIF2A==.a & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")
*256 individus sont concernés 


*Exportation:
export excel interview__key HH13 DIF2A using "$folderpath/document/Manquants_DIF2A" if missing(DIF2A) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##"),  firstrow(variables) replace


*Correction : 
replace DIF2A=9998 if missing(DIF2A) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")



*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if DIF2A==.a & (AgeAnnee<5 | Statut_Res!=1 | (membre_id_v1!="##N/A##" & membre_id_v1!=""))

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if DIF2A==.a & !inlist(DIF1A,1,2,3,4,9997,9998)
*256 individus sont concernés 

*export excel interview__key HH13 DIF2A using "$folderpath/document/Manquants_DIF2A" if DIF2A==.a & !inlist(DIF1A,1,2,3,4,9997,9998),  firstrow(variables) replace



*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

****DIF3. %rostertitle% utilise-t-il/elle un équipeme nt ou reçoit-il/elle de l’aide pour se déplacer : 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

forvalues i = 1/9 {
    * Compter les réponses manquantes pour les personnes qui devaient répondre
    count if DIF3__`i'==.a & (AgeAnnee>=5 & Statut_Res==1 & membre_id_v1=="##N/A##")
    
    * Si des réponses manquantes existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 DIF3__`i' using "$folderpath/document/DIF3__`i'_manquants.xlsx" if DIF3__`i'==.a & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##"), firstrow(variables) replace
        display "Exportation terminée pour DIF3__`i' avec " r(N) " réponses manquantes"
    }
    else {
        display "Toutes les réponses sont présentes pour DIF3__`i'"
    }
	*Correction : Mettre non
	replace (DIF3__`i') = 0 if missing(DIF3__`i') & (AgeAnnee>=5 & Statut_Res==1 & membre_id_v1=="##N/A##")
*	count if missing(DIF3__`i') & (AgeAnnee>=5 & Statut_Res==1 & membre_id_v1=="##N/A##")
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 

forvalues i = 1/9 {
    * Compter les réponses présentes pour les individus qui ne devaient pas répondre (sauts incorrects)
    count if DIF3__`i'==.a & (AgeAnnee < 5 | Statut_Res != 1 | (membre_id_v1 != "##N/A##" & membre_id_v1 != ""))
    
    * Si des réponses incorrectes sont trouvées, exporter les individus concernés dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 DIF3__`i' using "$folderpath/document/DIF3__`i'_Sauts.xlsx" ///
        if DIF3__`i'==.a & (AgeAnnee < 5 | Statut_Res != 1 | (membre_id_v1 != "##N/A##" & membre_id_v1 != "")), ///
        firstrow(variables) replace
        
        * Afficher un message indiquant que l'exportation est terminée pour cette sous-variable
        display "Exportation terminée pour DIF3__`i' avec " r(N) " réponses incorrectes"
    }
    else {
        * Si aucune réponse incorrecte n'est trouvée, afficher ce message
        display "Toutes les réponses sont correctes pour DIF3__`i'"
    }
}

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 

forvalues i = 1/9 {
    * Vérification des réponses inattendues dans DIF3__`i'
    count if DIF3__`i'==.a & !inrange(DIF3__`i', 0, 1)
    
    * Si des réponses inattendues existent, exporter les individus concernés dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 DIF3__`i' using "$folderpath/document/DIF3__`i'_inattendues.xlsx" if DIF3__`i'==.a & !inrange(DIF3__`i', 0, 1), firstrow(variables) replace
        display "Exportation terminée pour DIF3__`i' avec " r(N) " réponses inattendues"
    }
    else {
        display "Toutes les réponses sont correctes pour DIF3__`i'"
    }
}

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

****DIF3_Aut. veuillez préciser ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(DIF3_Aut) & DIF3__9==1
*0 personne concernée 

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 DIF1A DIF3_Aut using "$folderpath/document/Manquants_DIF3A" if missing(DIF3_Aut) & DIF3__9==1,  firstrow(variables) replace

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(DIF3_Aut) & (AgeAnnee<5 | Statut_Res!=1 | (membre_id_v1!="##N/A##" & membre_id_v1!=""))
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if DIF3_Aut =="##N/A##"
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

**** DIF3B. %rostertitle% a t il des difficultés utiliser ses mains/bras comme par exemple souleve r une bouteille d’eau ou de soda de 2 litres du n iveau de la taille jusqua niveau des yeux, ramas ser des petits objects avec ses doigts, ouvrir ou fermer un recipients ? diriez vous…

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if DIF3B==.a & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")
*256 individus concernés
*RAS

*Exportation:
*export excel interview__key HH13 DIF3B using "$folderpath/document/Manquants_DIF3B" if DIF3B==.a & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##"),  firstrow(variables) replace


*Correction : Ne sait pas
*replace DIF3B=9998 if missing(DIF3B) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")



*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if DIF3B==.a & (AgeAnnee<5 | Statut_Res!=1 | (membre_id_v1!="##N/A##" & membre_id_v1!=""))

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if DIF3B==.a & !inlist(DIF3B,1,2,3,4,9997,9998)
*256 individus sont concernés 

*Exportation:
export excel interview__key HH13 DIF3D using "$folderpath/document/_DIF3" if  DIF3B==.a & !inlist(DIF3B,1,2,3,4,9997,9998),  firstrow(variables) replace



*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


****DIF3D. %rostertitle% a-t-il des difficultés à communiquer dans sa langue habituelle,à comprendre  les autres ou à se faire comprendre, y co mpris l’utilisation du langage des signes ? Dirie

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if DIF3D==.a & (AgeAnnee>=5 & Statut_Res==1 & membre_id_v1=="##N/A##")
*RAS

*Exportation:
export excel interview__key HH13 DIF3D using "$folderpath/document/Manquants_DIF3D" if missing(DIF3D) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##"),  firstrow(variables) replace


*Correction : Ne sait pas
replace DIF3D=9998 if missing(DIF3D) & (AgeAnnee>=5 & Statut_Res==1 & membre_id_v1=="##N/A##")




*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if DIF3D==.a & (AgeAnnee<5 | Statut_Res!=1 | (membre_id_v1!="##N/A##" & membre_id_v1!=""))

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if DIF3D==.a & !inlist(DIF3D,1,2,3,4,9997,9998)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


****DIF5. %rostertitle% a-t-il des problèmes psychique, trouble mentaux ? Diriez-vous…

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if DIF5==.a & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")
*256 individus concernés



*Exportation:
export excel interview__key HH13 DIF5 using "$folderpath/document/Manquants_DIF5" if missing(DIF5) & (AgeAnnee>=5 & Statut_Res==1 & membre_id_v1=="##N/A##"),  firstrow(variables) replace


*Correction : Ne sait pas
replace DIF5=9998 if missing(DIF5) & (AgeAnnee>=5 & !inlist(AgeAnnee,.,.a) & Statut_Res==1 & membre_id_v1=="##N/A##")





*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if DIF5==.a & (AgeAnnee<5 | Statut_Res!=1 | (membre_id_v1!="##N/A##" & membre_id_v1!=""))

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if DIF5==.a & !inlist(DIF5,1,2,3,4,9997,9998)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


drop HH2 HH3 HH4 HH12 HH13 Statut_Res AgeAnnee


save "$standard_menage\QM_S6_difficultes_fonctionnelles.dta", replace
