capture log close                       // closes any logs, should they be open
log using "dataset_manipulation.log", replace    // open new log

// NAME: Dataset manipulation
// FILE: dataset_manipulation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 9 September 2012
// LAST: 18 Sep 2017

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

//Data import

import delimited "https://stats.idre.ucla.edu/wp-content/uploads/2016/02/hsb2-2.csv", clear
 
// Excel

import excel "tabn304.10.xls", cellrange(A5:L64) clear

// set globals for url data link and local data path
global urldata "https://stats.idre.ucla.edu/stat/stata/seminars/svy_stata_intro/apipop"

// read web data into memory
use $urldata, clear


// split into three datasets: elementary, middle, and high school

// -1- preserve dataset in memory
// -2- subset to keep only school type that we want
// -3- save new subset dataset
// -4- restore old dataset

// elementary schools
preserve
keep if stype == 1    
tab stype 
                 
save elem, replace
restore

// high schools
preserve
keep if stype == 2                      
save hs, replace
restore

// middle schools (keep this one in memory so no preserve/restore needed)
keep if stype == 3                      
save middle, replace


// merging via the append command
append using elem   
append using hs

/* Quick Exercise: Create a dataset that has just middle and elementary schools.
 Do this using first the append command and then the merge command.*/
 
 // Elementary schools in memory
 use elem, clear
 
 append using middle
 
 use elem, clear
 
 merge 1:1 snum using middle, nogen
 
// merging via the merge command

use elem, clear

merge 1:1 snum using hs, gen(_merge_a)

merge 1:1 snum using middle, gen(_merge_b)

// show merge stats for each merge
tab _merge_a
tab _merge_b

// split dataset by variables
use $urldata, clear

preserve
keep snum api00 api99 ell meals         // variable set 1
save api_1, replace
restore
keep snum full emer                     // variable set 2
save api_2, replace

// merging back together (api_2 in memory)
merge 1:1 snum using api_1

// view merge stats
tab _merge


/* Quick Exercise: Create a dataset that has only mobility and percent tested. Next create another dataset that has only the year round and percent responding variables. 
Now merge these two datasets together using a one-to-one merge.*/


use $urldata, clear

preserve
keep snum mobility pcttest
save api_a, replace
restore

preserve
keep snum yr_rnd pct_resp
save api_b, replace
restore

use api_a, clear

merge 1:1 snum using api_b, nogen

// collapsing data

// reload main dataset, since we didn't preserve it before
use $urldata, clear

// count of unique counties in dataset
unique cnum

preserve
// mean of pcttest and mobility within countyr
collapse (mean) pcttest mobility, by (cnum)
restore

// Total enrollment by district

collapse (sum) district_enroll=enroll, by(dnum)

save district_enroll, replace

use $urldata, clear

merge m:1 dnum using district_enroll
 
// give count of number of observations (should be number of unique counties)
count

/* Quick Exercise: Create a district level dataset that contains district 
level averages for the following variables:apioo api99 ell meals*/


use $urldata, clear
preserve
collapse (mean) /// 
	mean_api00=api00 /// 
	mean_api99=api99 ///
	mean_ell=ell ///
	mean_meals=meals ///
	(median) ///
	med_api00=api00 /// 
	med_api99=api99 ///
	med_ell=ell ///
	med_meals=meals ///
	, by(dnum)
	
save district_stuff, replace

restore

merge m:1 dnum using district_stuff



/* QE: then do the same thing using medians*/


/* Merge both into main dataset? */



// end file
log close                               // close log
exit                                    // exit script
