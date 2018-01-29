capture log close                       // closes any logs, should they be open
set linesize 90
log using "validation.log", replace    // open new log

// NAME: Data cleaning
// FILE: validation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 22 October 2014
// LAST: 15 October 2017
     
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

// show estimates
estimates replay expect_tab

// put estimates back in memory
estimates restore expect_tab

//one line version

eststo expect_tab: svy: proportion bystexp


// save as table using esttab
esttab expect_tab using expect_tab.rtf, b(3) se(4) nostar ///
    varlabels(_prop_1 "Unsure" ///
              _prop_2 "Less than HS" ///
              _prop_3 "HS or GED" ///
              _prop_4 "AA/AS" ///
              _prop_5 "Some college" ///
              _prop_6 "BA/BS" ///
              _prop_7 "MA/MS" ///
              _prop_8 "PhD or Prof") ///
   replace
   
eststo expect_tab: svy: proportion bystexp if byses1<-.25
// save as table using esttab
esttab expect_tab using expect_tab.rtf, b(3) se(4) nostar ///
    varlabels(_prop_1 "Unsure" ///
              _prop_2 "Less than HS" ///
              _prop_3 "HS or GED" ///
              _prop_4 "AA/AS" ///
              _prop_5 "Some college" ///
              _prop_6 "BA/BS" ///
              _prop_7 "MA/MS" ///
              _prop_8 "PhD or Prof") ///
				append 

	
	
// Tabulate racial/ethnic categories
svy: proportion byrace

estimates store race_tab

// save as table using esttab
esttab race_tab using race_tab.rtf, b(3) se(4) nostar ///
    varlabels(_prop_1 "American Indian/Alaskan Native" ///
              _prop_2 "Asian/ Pacific Islander" ///
              _prop_3 "African American" ///
              _prop_4 "Hispanic, no race specifided" ///
              _prop_5 "Hispanic, race specified" ///
              _prop_6 "Multiracial" ///
              _prop_7 "White, non-Hispanic") ///
    replace	

svy: tabulate byrace bystexp, row percent	
ereturn list 
	
estpost svy: tabulate byrace bystexp, row percent
estimates store expect_tab2
// What's stored in e()?
ereturn list 
	
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
			  

egen composite=rowmean(bynels2m bynels2r) 

//Standardize by mean and sd 

mean composite [pw=bystuwt]

tabstat composite, stat(sd)			  

_pctile std_composite [pw=bystuwt]
			  
// end file     
log close
exit
