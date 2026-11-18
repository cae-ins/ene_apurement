*================================================
*********COMPOSITION DES MENAGES

****RESPONSABLE | AUTEUR: DIALLO AMINE
*=============================================
*******************************************

//Fusion de la base "Composotion_menage" avec les bases identification, membres et autres_formes_travail et récupération de variables clés
use "$datain_standard\QM_S0_identification.dta", clear


*------------------------------------------------------------
* HH12. NOM ET CODE DU CHEF D’EQUIPE
*------------------------------------------------------------
count if missing(HH12) & !missing(M0__0)
//RAS


*------------------------------------------------------------
* HH13. NOM ET CODE DE L’ENQUETEUR
*------------------------------------------------------------
count if missing(HH13) & !missing(M0__0)
//RAS


*------------------------------------------------------------
* HH9. NUMERO DU MENAGE DANS LE SEGMENT APRÈS LE TIRAGE
*------------------------------------------------------------
count if missing(HH9) & !missing(M0__0)


*------------------------------------------------------------
* GPS. COORDONNÉES GPS DU MÉNAGE
*------------------------------------------------------------
foreach var in GPS__Latitude GPS__Longitude GPS__Accuracy GPS__Altitude GPS__Timestamp {
count if missing(`var') & rgmen==1 & !missing(M0__0)
} 



*------------------------------------------------------------
* MODINTR: QUEL EST MODE DE COLLECTE ACTUELLE
*------------------------------------------------------------
