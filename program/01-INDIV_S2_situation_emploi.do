*=========================================================
* SITUATION D’EMPLOI (SE)
*
* DO-FILE STUB (Créé pour éviter le plantage du pipeline)
*========================================================

use "$datain_standard\INDIV_S2_situation_emploi.dta", clear

* Note: L'apurement métier de cette section est à compléter.
* Les variables de nomenclature (CITP/CIAP) sont préservées.

save "$standard_individu\INDIV_S2_situation_emploi.dta", replace
