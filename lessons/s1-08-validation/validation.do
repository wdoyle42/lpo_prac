capture log close                       // closes any logs, should they be open
set linesize 90
log using "lecture10_validation.log", replace    // open new log

// NAME: Data cleaning
// FILE: lecture10_validation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 22 October 2014
// LAST: 29 October 2016
     
clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature


// load plans data
use plans.dta

// set up data for survey commands 
svyset psu [pw = bystuwt], str(strat_id) singleunit(scaled)

// set up local to hold variables we wish to recode 
local allvar bystexp bysex byrace byses1 f1psepln

// change values for vars in local that in (-4,-8,-9) to missing
foreach myvar in `allvar' {
    replace `myvar' = . if `myvar' == -4   
    replace `myvar' = . if `myvar' == -8 
    replace `myvar' = . if `myvar' == -9 
} 

// student expectations for education 
tab bystexp
svy: proportion bystexp

// store estimates
estimates store expect_tab

// save as table using esttab
esttab expect_tab using expect_tab.rtf, b(3) se(4) ///
    varlabels(_prop_1 "Unsure" ///
              _prop_2 "Less than HS" ///
              _prop_3 "HS or GED" ///
              _prop_4 "AA/AS" ///
              _prop_5 "Some college" ///
              _prop_6 "BA/BS" ///
              _prop_7 "MA/MS" ///
              _prop_8 "PhD or Prof") ///
    replace

	
estpost svy: tabulate byrace bystexp, row percent
estimates store expect_tab2
	
esttab expect_tab2 using expect_tab2.rtf, se  nostar replace unstack ///	
	varlabels(`e(labels)') eqlabels(`e(eqlabels)')

// post clean table to output window
esttab expect_tab, b(3) se(4) ///
    varlabels(_prop_1 "Unsure" ///
              _prop_2 "Less than HS" ///
              _prop_3 "HS or GED" ///
              _prop_4 "AA/AS" ///
              _prop_5 "Some college" ///
              _prop_6 "BA/BS" ///
              _prop_7 "MA/MS" ///
              _prop_8 "PhD or Prof")
			  

// end file     
log close
exit
