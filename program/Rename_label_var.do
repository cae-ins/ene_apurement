///////////////////////////////***************  LABELISATION DESZ VARIABLES BINAIRE ************ /////////////////////////////////////////////
use "$datain_brute/membres.dta",clear

// EF16E IM8 DIF3 EP24 EP31 WKI2 R4 C12b Q1_5 Q1_8 Q1_10 Q1_13 C12c DI4 CQ6 SRH12A RHE

foreach var of varlist EF16E__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}

***
foreach var of varlist IM8__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}

***
foreach var of varlist DIF3__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}

***
foreach var of varlist EP6__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}

foreach var of varlist EP31__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}

***
foreach var of varlist EP24__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}

***
foreach var of varlist WKI2__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist R4__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist C12b__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist Q1_5__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist Q1_8__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label	
}
***
foreach var of varlist Q1_10__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist Q1_13__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist C12c__* {
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist DI4__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist CQ6__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist SRH12A__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}
***
foreach var of varlist RHE__*{
	label define `var'_label 0 "Non" 1 "Oui",modify
	label values `var' `var'_label
}


*######
/*lobal var_Binary
foreach var of varlist *__* {
	di in red "---> `var'"
	global var_Binary $var_Binary `var'
}*/

save "$datain_brute/membres.dta", replace 