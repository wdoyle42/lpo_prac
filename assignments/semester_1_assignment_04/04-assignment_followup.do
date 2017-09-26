// Assignment 4 follow up

use ../../data/plans, clear

//Subset the data on gender. Create one data file for males and one
// for females (hint: use keep if or drop if).

tab bysex

preserve
keep if bysex ==1

save plans_male, replace

restore

keep if bysex==2

save plans_female, replace


//Merge the two datasets together, and tabulate the _merge variable. 
//What are the results?

merge 1:1 stu_id using plans_male

tab _merge

//Now split the dataset by variables. To do this you will need to either use the drop command or use the save command
// with a variable list. Make sure that in each dataset, you include the student id.

use ../../data/plans, clear

preserve
keep stu_id byrace
save race_only, replace
restore

keep stu_id byses1 
save ses_only, replace


//Add a new line to each dataset. Alter the id in the new observation 
//so that the two files do not match.
di _N

set obs 16161

replace stu_id=42 if _n==16161

save ses_only, replace

use race_only, clear

di _N

set obs 16161

replace stu_id=43 if _n==16161

save race_only, replace

//Repeat the merge command again, but this time create a 
//result where the two additional (fake) observations are dropped.

merge 1:1 stu_id using ses_only

keep if _merge==3

//Repeat the merge, but this time only keep the observations in the master dataset.

use race_only, clear

merge 1:1 stu_id using ses_only

drop if _merge==2

//Repeat the merge, but this time only keep the observations in the using dataset.

use race_only, clear

merge 1:1 stu_id using ses_only

drop if _merge==1


exit
//EOF
