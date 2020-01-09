capture log close                           // closes any logs, should they be open
log using "<name_of_log_file>.log", replace // open new log

// NAME: Assignment 4
// FILE: 04-assignment_followup.do
// AUTH: Will Doyle
// INIT: 2019-09-25
// LAST: 2019-09-25

clear all                      // clear memory
set more off                   // turn off annoying "__more__" feature


// CONTENT...

global ddir "../../data/"

//Subset the data on gender. Create one data file for males and 
//one for females (hint: use keep if or drop if).

use "${ddir}plans.dta", clear

preserve
keep if bysex==2
save plans_female, replace
restore

preserve
keep if bysex==1
save plans_male, replace
restore


//Merge the two datasets together, and tabulate the _merge variable.
// What are the results?

use plans_female, clear

merge 1:1 stu_id using plans_male, gen(_merge_a)

tab _merge_a

// Results: no variables matched, because no overlap between datasets. 


//Now split the dataset by variables. To do this you will need to
// either use the drop command or use the save command with a variable
// list. Make sure that in each dataset, you include the student id.


use "${ddir}plans.dta", clear

preserve
keep stu_id f1psepln
save just_plans, replace
restore


preserve
keep stu_id bypared
save just_pared, replace
restore

use just_plans, clear

merge 1:1 stu_id using just_pared, gen(_merge_b)

//Result: everything matched

//Add a new line to each dataset. Alter the id in the new observation 
//so that the two files do not match.

use just_plans, clear

set obs `=_N+1'

replace stu_id = 4 in 16161

save just_plans, replace

use just_pared, clear

set obs `=_N+1'

replace stu_id = 5 in 16161

save just_pared, replace

//Repeat the merge command again, but this time create a result where
// the two additional (fake) observations are dropped.

use just_plans, clear

merge 1:1 stu_id using just_pared , gen(_merge_a)

tab _merge_a 

keep if _merge_a==3


//Repeat the merge, but this time only keep the observations in the
 //master dataset.
 
 use just_plans, clear

merge 1:1 stu_id using just_pared , gen(_merge_a)

tab _merge_a 

drop if _merge_a==2

//Repeat the merge, but this time only keep the observations in the 
//using dataset.
use just_plans, clear

merge 1:1 stu_id using just_pared , gen(_merge_a)

tab _merge_a 

drop if _merge_a==1

// end file
log close                               // close log
exit                                    // exit script
