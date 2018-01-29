
// BASIC DESCRIPTIVE TABLE

use plans2, clear

// set plot and table types
global gtype eps
global ttype html

// use svyset to account for survey design
svyset psu [pw = f1pnlwt], strat(strat_id) singleunit(scaled)

// get mean estimates using svy
svy: mean bynels2m bynels2r byses1 byses2 amind asian black hispanic white female

// Store it
estimates store my_mean

// store the estimates in a nice table using esttab
esttab my_mean using means_se.$ttype, /// 
		replace ///
		nostar ///                           // no significance tests 
		label ///                            // use variable labels 
    main(b)  ///                          // main = means 
    aux(se) ///                          // aux = standard errors 
    nonotes ///                          // no standard table notes 
    nonumbers ///                        // no column/model numbers
    addnotes("Linearized estimates of standard errors in parentheses")


// first new recoded parental education level
recode bypared (1/2 = 1) (3/5 = 2) (6 = 3) (7/8 = 4) (. = .), gen(newpared)
label var newpared "Parental Education"
label define newpared 1 "HS or Less" 2 "Less than 4yr" 3 "4 yr" 4 "Advanced"
label values newpared newpared

// next new recoded student expectations
recode f1psepln (1/2 = 1) (3/4 = 2) (5 = 3) (6 = .) (. = .), gen(newpln)
label var newpln "PS Plans"
label define newpln 1 "No plans" 2 "VoTech/CC" 3 "4 yr"
label values newpln newpln	
	
//  cross table of categorical
estpost svy: tabulate byrace2 newpln, row percent se

eststo racetab

esttab racetab using race_tab.$ttype, ///
    replace ///
    nostar ///
    nostar ///
    unstack ///
    nonotes ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)')
	
	
exit 
