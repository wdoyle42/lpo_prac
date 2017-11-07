version 13
capture log close
log using "programming.log",replace

/* PhD Practicum */
/* Some simple demonstrations of macros and loops */
/* Will Doyle*/
/* LAST: 11/6/2017 */
/* Saved on OAK */

clear

/* TOC */

/* Section 1: REcoding */

local recoding=0 /*Homer*/

/* Section 2: Analysis */

local analysis=0 /*Marge*/


clear matrix

use ../../data/plans

svyset psu [pw=bystuwt], strat(strat_id)

/*Generating macros*/

local tests bynels2m bynels2r 

*summarize tests /* Won't work */

summarize `tests' /*Will work */

local ses byses1 byses2

summarize `ses'


/**********************/
/* Recoding Section Begin*/
/**********************/

if `recoding'==1{
/* Difference between globals and locals */

foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End loop over variables */

  
 /*
foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */             
                     replace `myvar'=. if `myvar'== -4| `myvar'==-8 | `myvar'==-9                            
                                          } /* End loop over variables */
 */
  
local race_names amind asian black hispanic multiracial white

tab(byrace), gen(race_)

local i=1
foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

label variable byincome "Income"
label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable hispanic "Hispanic"
label variable white "White"
label variable multiracial "Multiracial"

save plans_b, replace
}/*end recoding section conditional*/
else{
use plans_b, clear
}/* end else */

/**********************/
/* Recoding Section End */
/**********************/



/**********************/
/* Analysis Section */
/**********************/
if `analysis'==1{

local y bynels2m bynels2r

local demog amind asian black hispanic white  bysex

local pared bypared bymothed

bysort `demog': sum `y' 
bysort `pared': sum `y'


sum bynels2m 

sum `y' 


 /* Scalar commands*/
scalar pi=3.14159
 display "`pi'"

summarize bynels2m

scalar mean_math=r(mean)

scalar sd_math=r(sd)

scalar sum_math=r(sum)

scalar units_math=r(N)

scalar math_mean=sum_math/units_math

gen stand_math= (bynels2m-mean_math)/(2*sd_math)

/*Varlist  commands*/

local bydata by*

local first_five stu_id-f1sch_id

local myses *ses?

sum *ed

sum by*ed

svyset psu [pw=bystuwt], strat(strat_id)

*Replace all missing data

 foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */


*Simple forvalues command

forvalues i= 1/10{
 di "This is number `i'"
}


forvalues i= 1(2)100{
 di "This is number `i'"
}


*Use nsplit command to separate out birth year and day

nsplit bydob_p, digits (4 2) gen (newdobyr newdobm)

gen myage= 2002-newdobyr

forvalues i = 14/18{
gen age`i'=0
replace age`i'=1 if myage==`i'
replace age`i'=. if myage==.
}


*Simple foreach command

local mytest *nels*

foreach test of local mytest {
  sum `test'
}

/*
// NO
foreach test of local mytest { sum `test'
}


// NO
foreach test of local mytest { 
sum `test'}

//NO
foreach test of local mytest { sum `test'}

*/

forvalues i =1(3)100{
di "I can count by threes, look! `i' "
}


*The while command
local i = 1
while `i' < 10 {
    di "I have not yet reached 10, instead the counter is now `i' "
    local i=`i'+1
  }
  
  
  // Foreach
  
  foreach i of numlist 1/10{
 di "Foreach can count too, look: `i'"
  }
  
  
*Standardizing continous variables by 2 sd
foreach test of varlist *nels*{
 sum `test'
 gen stand_`test'=(`test'-r(mean))/(2*r(sd))
}


local by_select bysex byrace bypared-byincome bystexp

foreach myvar of local by_select{
tab1 `myvar'
}

foreach myvar in `by_select'{
tab1 `myvar'
}

foreach myvar of varlist bysex-byincome{
tab `myvar'
}


*Nested loops
forvalues i =1/10 { /* Start outer loop */
  forvalues j = 1/10 { /* Start inner loop */
    di "This is outer loop `i', inner loop `j'"
                      } /* End inner loop */
                    } /* End outer loop */

}/* End analysis section */
else{
di "Did not run analysis"
}
  
exit


