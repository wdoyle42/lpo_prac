capture log close                       // closes any logs, should they be open
log using "dataset_manipulation.log", replace    // open new log

// NAME: Dataset manipulatin
// FILE: lecture4_dataset_manipulation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 9 September 2012
// LAST: 19 Sep 2016

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

//Data import

import delimited "http://www.ats.ucla.edu/stat/r/modules/hsb2.csv", clear

// Excel

import excel "https://nces.ed.gov/programs/digest/d14/tables/xls/tabn304.10.xls", cellrange(A5:L64) clear


// set globals for url data link and local data path
global urldata "http://www.ats.ucla.edu/stat/stata/library/apipop"

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

// collapsing data

// reload main dataset, since we didn't preserve it before
use $urldata, clear

// count of unique counties in dataset
unique cnum

// mean of pcttest and mobility within countyr
collapse (mean) pcttest mobility, by (cnum)

// give count of number of observations (should be number of unique counties)
count

// end file
log close                               // close log
exit                                    // exit script
