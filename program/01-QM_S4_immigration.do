*=========================================================
* IMMIGRATION (IM)

* RESPONSABLE: RENAUD HIVITES AKATTIA (PECHOUX)
*========================================================




use "$datain_standard\QM_S4_immigration.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH12 HH13 HH3)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\QM_S1_composition_menage.dta", keepusing(AgeAnnee Statut_Res M6_A M1 M2)
drop if _merge!=3
cap drop _merge


*=========================================
*IM1.a-t-il vecu de manière continue dans une autre localité pendant au moins six mois ?
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if IM1==.a & Statut_Res==1 & membre_id_v1 =="##N/A##"
*132 individus sont concernés 


*br  interview__key IM1 if IM1==.a & Statut_Res==1 & membre_id_v1 =="##N/A##"

*Ientification des agents ayant fait des erreurs 
export excel interview__key HH13 IM1 Statut_Res using "$folderpath/document/Erreur_IM1_NA" if IM1==.a & Statut_Res==1 & membre_id_v1 =="##N/A##", firstrow(varlabels) replace 

*Correction : Mettre 2 si l'individu est résident
replace IM1= 2 if  missing(IM1) & Statut_Res==1 & membre_id_v1 =="##N/A##" & (M1==2 | M2==2)


*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM1) & (Statut_Res!=1 | membre_id_v1 !="##N/A##")
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
count if !inrange(IM1,1,2) & !missing(IM1)
*RAS

*Problem4: Vraisemblance des reponses 
*RAS

*=========================================
*IM2A. Depuis quelle année vit-il/elle dans cette localité de manière continue
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if IM2A==.a & IM1==1
*1 individu est concerné  

*br if IM2A==.a & IM1==1

*Correction :  Considérer qu'il n'a pas vécu dans une autre localité
*replace IM1= 2 if missing(IM2A) & IM1==1 & Statut_Res==1



*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM2A) & IM1==2
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
*RAS

*Problem4: Vraisemblance des reponses 
*On peut voir si les valeurs renseignées sont superieures à la date de naissance

count if M6_A != 9998 & IM2A != 9998 & M6_A > IM2A & !missing(IM2A)


*=========================================
*IM2M. Depuis quel mois, %rostertitle% vit-il/elle dans cette localité de manière continue 
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if missing(IM2M) & IM2A!=9998 & !missing(IM2A)
*RAS


*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM2M) & IM2A==9998
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
*RAS

*Problem4: Vraisemblance des reponses 
*RAS

*=========================================
*IM3A. Depuis combien de temps (en nombre d’années) vit-il  dans cette localité de manière continue ?
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if missing(IM3A) & IM2A==9998


*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM3A) & IM2A!=9998
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
*On peut regarder et essayer de detecter les valeurs aberrantes par exemple, je choisis pour le cas ci 80

count if IM3A>80 & !inlist(IM3A,.,.a,9998) // RAS



*Correction : Ramener à l'année de naissance
*replace IM3A=M7 if IM3A>80 & !missing(IM3A)


*Problem4: Vraisemblance des reponses 
*On regarde  si l'age  est inferieur au nombre d'année qu'il a pasé dans la localité

count if AgeAnnee<IM3A & !inlist(AgeAnnee,.,.a,9998) & !inlist(IM3A,.,.a,9998)
*RAS

*=========================================
*IM3M depuis combien de mois vit-il (elle) (%rostertitle%) dans cette localité 
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
*count if missing(IM3M) & IM3A!=9998 & !missing(IM3A)	
count if IM3A>AgeAnnee & !inlist(IM3A, ., .a, 9998)
*RAS

*Identification des agents ayant fait des erreurs
*export excel interview__key HH13 IM3A Statut_Res using "$folderpath/document/Erreur_IM3M_NA" if missing(IM3M) & IM3A!=9998 & !missing(IM3A), firstrow(varlabels) replace 


*Problem 2: ceux qui devaient repondre ont ils repondu
count if IM3A==.a & IM2A==9998
*RAS


*Problem3: Les valeurs renseignées sont elles permises 
*On verifie que les valeurs renseignées pour cette variable n'excèdent pas 12

count if IM3M>12 & !missing(IM3M)
*RAS

*Problem4: Vraisemblance des reponses 
*RAS


*=========================================
*IM4 Où habitait  avant de venir ou de revenir dans cette localité 
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if IM4==.a & IM1==1
*RAS


*Identification des agents ayant fait des erreurs
*export excel interview__key HH13 IM4 Statut_Res using "$folderpath/document/Erreur_IM4_NA" if missing(IM4) & IM1==1, firstrow(varlabels) replace 


*Correction : toutes les autres questions ne sont pas repondues, donc remettre la première variable a manquant.
replace IM1=.a if IM4==.a & IM1==1	



*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM4) & IM1==2
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
*On verifie que les valeurs renseignées pour cette variable n'excèdent pas 12

count if !inrange(IM4,1,2) & !missing(IM4)
*RAS

*Problem4: Vraisemblance des reponses 
*RAS

*=========================================
*IM5.Dans quel pays habitaitavant de venir dans cette localité ? 
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if missing(IM5) & IM4==2	
*RAS


*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM5) & IM4==1
*RAS

*Problem3: Les valeurs renseignées sont elles permises 

count if !inrange(IM5,1,216) & !missing(IM5)
*RAS

*Problem4: Vraisemblance des reponses 
*RAS


*=========================================
*IM5_Aut. Autres à preciser 
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if missing(IM5_Aut) & inlist(IM5,28,36,41,44,47,48)
*RAS


*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM5_Aut) & !inlist(IM5,28,36,41,44,47,48)
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
*les valeurs renseignées sont elles presentes chez IM5

*On pourrait essayer de comparer les valeurs obtenues dans autres à preciser et les comparer à celles renseignées à IM5_Aut

*Problem4: Vraisemblance des reponses 
*RAS

*=========================================
*IM7.Dans quelle sous-préfecture habitait avant de venir dans cette localité 
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if missing(IM7) & IM4==1	
*RAS


*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM7) & IM4==2
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
*On verifie que les valeurs renseignées pour cette variable n'excèdent pas 12

count if !inrange(IM7, 1010100202 , 1142309103) & !missing(IM7)& IM7!=0
*RAS

*Problem4: Vraisemblance des reponses 
*RAS


*=========================================
*IM7A.Dans quelle localité habitait avant de venir dans cette localité 
*=========================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
*count if missing(IM7A) & IM4==1	
count if missing(IM7A) & IM4==1 & IM7!=0000000000
 

*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM7A) & IM4==2
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
*On verifie que les valeurs renseignées pour cette variable n'excèdent pas 12

*count if !inrange(IM7A,1,8432) & !missing(IM7A)
*RAS

*Problem4: Vraisemblance des reponses 
*RAS

*=====================================================
*IM8.Pourquoi est-il venu dans cette localité ?
*=============================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
foreach var of varlist IM8__1-IM8__9{
	count if missing(`var')& IM1==1
}


*Identification des agents ayant fait des erreurs
*export excel interview__key HH13 IM8__1 IM8__2 IM8__3 IM8__4 IM8__5 IM8__6 IM8__7 IM8__8 IM8__9 Statut_Res using "$folderpath/document/Erreur_IM8_NA" if missing(IM8__1, IM8__2, IM8__3, IM8__4, IM8__5, IM8__6, IM8__7, IM8__8, IM8__9) & IM1==1	, firstrow(varlabels) replace 


*Problem 2: ceux qui devaient repondre ont ils repondu
foreach var of varlist IM8__1-IM8__9{
	count if !missing(`var') & IM1==2
}
*RAS

*Problem3: Les valeurs renseignées sont elles permises 
foreach var of varlist IM8__1-IM8__9{
count if !inrange(`var',0,1) & !missing(`var')
}
*RAS

*Problem4: Vraisemblance des reponses 
*RAS


*=====================================================
*IM8. Autres à preciser 
*=============================================

*Problem 1: Ceux qui devaient repondre devaient ils repondre
count if missing(IM8_Aut)&IM8__9==1
*23 personnes n'ont pas repondus


*br if missing(IM8_Aut)&IM8__9==1


*Identification des agents concernés
*export excel interview__key HH13 IM1 Statut_Res IM8_Aut using "$folderpath/document/Erreur_IM8_NA" if missing(IM8_Aut)&IM8__9==1, firstrow(varlabels) replace  

*Problem 2: ceux qui devaient repondre ont ils repondu
count if !missing(IM8_Aut)& IM8__9==2
*RAS





drop HH2 HH3 HH4 HH12 HH13 M1 M2 Statut_Res M6_A AgeAnnee


save "$standard_menage\QM_S4_immigration.dta", replace