/*
Protections contre les ecrasements croises des copies de travail brutes.

Chaque sauvegarde verifie des variables sentinelles propres au fichier cible.
Le pipeline s'arrete si le dataset charge ne correspond pas au schema attendu.
*/

capture program drop save_brute_membres_safe
program define save_brute_membres_safe
    capture confirm variable interview__key
    if _rc {
        display as error "Sauvegarde membres refusee: interview__key absente."
        exit 459
    }
    capture confirm variable membres__id
    if _rc {
        display as error "Sauvegarde membres refusee: membres__id absente."
        exit 459
    }
    capture confirm variable hha_COMP
    if _rc {
        display as error "Sauvegarde membres refusee: hha_COMP absente. Dataset membres attendu."
        exit 459
    }
    capture confirm variable r_activite_s__id
    if !_rc {
        display as error "Sauvegarde membres refusee: roster r_activite_s charge en memoire."
        exit 459
    }
    save "$datain_brute\membres.dta", replace
end

capture program drop save_brute_r_activite_s_safe
program define save_brute_r_activite_s_safe
    capture confirm variable interview__key
    if _rc {
        display as error "Sauvegarde r_activite_s refusee: interview__key absente."
        exit 459
    }
    capture confirm variable membres__id
    if _rc {
        display as error "Sauvegarde r_activite_s refusee: membres__id absente."
        exit 459
    }
    capture confirm variable r_activite_s__id
    if _rc {
        display as error "Sauvegarde r_activite_s refusee: r_activite_s__id absente."
        exit 459
    }
    capture confirm variable PL3_G
    if _rc {
        display as error "Sauvegarde r_activite_s refusee: PL3_G absente."
        exit 459
    }
    save "$datain_brute\r_activite_s.dta", replace
end

capture program drop save_brute_menage_work_safe
program define save_brute_menage_work_safe
    capture confirm variable interview__key
    if _rc {
        display as error "Sauvegarde menage refusee: interview__key absente."
        exit 459
    }
    capture confirm variable HH2
    if _rc {
        display as error "Sauvegarde menage refusee: HH2 absente."
        exit 459
    }
    capture confirm variable L1
    if _rc {
        display as error "Sauvegarde menage refusee: L1 absente."
        exit 459
    }
    capture confirm variable membres__id
    if !_rc {
        display as error "Sauvegarde menage refusee: dataset individuel charge en memoire."
        exit 459
    }
    save "$brute_menage_work", replace
end

capture program drop save_brute_emigration_safe
program define save_brute_emigration_safe
    capture confirm variable interview__key
    if _rc {
        display as error "Sauvegarde emigration refusee: interview__key absente."
        exit 459
    }
    capture confirm variable ME3
    if _rc {
        display as error "Sauvegarde emigration refusee: variable ME3 (Sexe) absente."
        exit 459
    }
    save "$datain_brute\emigration.dta", replace
end
