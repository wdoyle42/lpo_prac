// Grab Bag
// Au: Will Doyle
// Rev: 11/28/17


// Acad presentation



// Tables, tables tables


clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// set link for data, plot, and table directories
global datadir "../data/"
global plotdir "../plots/"
global tabsdir "../tables/"

// set plot and table types
global gtype pdf
global ttype html

// theme for graphics
set scheme s1color

// open up modified plans data
use plans2, clear


// next new recoded student expectations
recode f1psepln (1/2 = 1) (3/4 = 2) (5 = 3) (6 = .) (. = .), gen(newpln)
label var newpln "PS Plans"
label define newpln 1 "No plans" 2 "VoTech/CC" 3 "4 yr"
label values newpln newpln

// use svyset to account for survey design
svyset psu [pw = f1pnlwt], strat(strat_id) singleunit(scaled)

//  cross table of categorical
estpost svy: tabulate byrace2 newpln, row percent se

eststo racetab

esttab racetab using race_tab.$ttype, ///
    replace ///
    nostar ///
    unstack ///
    nonotes ///
	se(2) ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)')

tab newpln, gen(newpln_)

rename newpln_3 fouryr_pln

rename newpln_2 twoyr_pln

tab fouryr_pln

tab newpln
	
//tabstat fouryr_pln , by(bypared) stat(mean) save

//Four year plans
svy: mean fouryr_pln, over(bypared)

estpost

eststo plans_tab_1
 
// Two year plans 
svy: mean twoyr_pln, over(bypared)

estpost

eststo plans_tab_2

 
esttab plans_tab_* using plans_tab.$ttype, ///
    replace ///
    nostar ///
    unstack ///
    nonotes ///
	se(2) ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)')
		
// Math scores 
svy: mean bynels2m, over(bypared)

estpost

eststo math_pared
	
// Reading score
svy: mean bynels2r, over(bypared)

estpost

eststo read_pared

 
esttab *_pared using pared_summary.$ttype, ///
    replace ///
    nostar ///
    unstack ///
    nonotes ///
	se(2) ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)')

_pctile bynels2m [pw=bystuwt]

scalar math_median=r(r1)

_pctile bynels2r [pw=bystuwt]

scalar read_median=r(r1)

// Useless regression 
eststo reg1: reg bynels2m bynels2r	

// Add scalars to regression results 
estadd scalar math_median 
	
estadd scalar read_median 

// Run esttab, dropping main results 
esttab reg1, drop(bynels2r _cons) scalar(math_median read_median)
	

	

// Exporting graphics


graph hbar bynels2m bynels2r [pw=bystuwt], ///
		over(bystexp, sort(bynels2m) descending) ///
		ytitle("Test Scores") ///
		legend(order(1 "Math Scores" 2 "Reading Scores"))  ///
		blabel(bar,format(%9.2f)) ///
		bar(1, color(orange*.5)) bar(2, color(blue*.5)) ///
		name(scores_expectations, replace)

		
		
graph hbar bynels2m bynels2r [pw=bystuwt], ///
		over(byincome,reverse) ///
		ytitle("Test Scores") ///
		legend(order(1 "Math Scores" 2 "Reading Scores"))  ///
		blabel(bar,format(%9.2f)) ///
		bar(1, color(orange*.5)) bar(2, color(blue*.5))	///	
        name(scores_income, replace)

// Saving as gph files 
graph save scores_expectations score_expect, replace
				
graph save scores_income score_income, replace
		
graph combine score_expect.gph score_income.gph, rows(1) name(combined)		

graph export combined.$gtype 

exit 

graph save combined, replace
		
// What's a codebook? I want one . . .



