// Assignment 6? Followup


// Declare locals

local depvars bynelsm bynels2r 


// Create a switch

// TOC
local recode_data=1

local analysis=1 

if `recode_data'==1{
use ../../data/plans, clear

/* Do stuff to recode*/

// Recode for missing
foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End loop over variables */


// Recode for categorical
local race_names amind asian black hispanic_no_race hispanic_with_race multiracial white


tab(byrace), gen(race_)

// i is used as a counter
local i=1 // initializing 
foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

label variable byincome "Income"
label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable hispanic_no_race "Hispanic, no race specified"
label variable hispanic_with_race "Hispanic, race specified"
label variable white "White"
label variable multiracial "Multiracial"


save ../../data/plans_b, replace
}

else{
di "Not recoding data" 
use ../../data/plans_b, clear
}

if `analysis'==1{
sum `depvars' 
}
