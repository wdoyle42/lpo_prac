capture log close

log using "03-assignment-followup.do", replace

//Assignment 3
// Simple merges and understanding results
// Will Doyle
// 2020-09-23

global ddir "../../data/"


use "${ddir}plans.dta", clear


//Subset the data on gender. Create one data file for males and one for females (hint: use keep if or drop if). If you don't have this variable choose another categorical variable with which to subset.

preserve

keep if bysex==1

save  plans_males, replace

restore

preserve

keep if bysex==2

save plans_females, replace

restore


//Merge the two datasets together, and tabulate the _merge variable. What are the results?

use plans_males, clear

merge 1:1 stu_id using plans_females


//Now split the dataset by variables. To do this you will need to either use the drop command or use the save command with a variable list. Make sure that in each dataset, you include the student id.

preserve

keep stu_id bysex byrace bydob_p

save plans_demo, replace

restore

preserve

keep stu_id bynels2m bynels2r

save plans_tests, replace

restore


//Add a new line to each dataset. Alter the id in the new observation so that the two files do not match.

use plans_demo, clear

local obs=_N

local obs=`obs'+1

set obs `obs'

replace stu_id=424242 if stu_id==.

save plans_demo, replace


use plans_tests, clear

local obs=_N

local obs=`obs'+1

set obs `obs'

replace stu_id=252525 if stu_id==.

save plans_tests, replace
 

//Repeat the merge command again, but this time create a result where the two additional (fake) observations are dropped.

use plans_tests, clear

merge 1:1 stu_id using plans_demo, keep(3)

//Repeat the merge, but this time only keep the observations in the in-memory dataset.


use plans_tests, clear

merge 1:1 stu_id using plans_demo, keep(1)


//Repeat the merge, but this time only keep the observations in the using dataset.

use plans_tests, clear

merge 1:1 stu_id using plans_demo, keep(2)

exit 
