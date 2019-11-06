version 15
capture log close
log using "programming.log",replace

/* PhD Practicum */
/* Some simple demonstrations of macros and loops */
/* Will Doyle*/
/* LAST: 11/6/2019 */

clear

************************************
/* TOC */
/* Section 1: Recoding  */ 

local recoding=0

/* Section 2: Analysis */

local analysis=1
************************************

************************************
/* Declare Macros */
// set plot and table types
global gtype png
global ttype html
************************************

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

foreach myvar of varlist stu_id-f2ps1sec{ /* Start outer loop */
				foreach i of numlist -4 -8 -9 { /* Start inner loop */				
				di "Hi! I'm changing `myvar' to be missing if `myvar'=`i'  "
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End loop over variables */

 										  
foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */             
                     replace `myvar'=. if `myvar'== -4 | `myvar'==-8 | `myvar'==-9                            
                                          } /* End loop over variables */
				

								
local race_names amind asian black hispanic_unspecify hispanic_specify multiracial white

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
label variable hispanic_unspecify "Hispanic, No Race Specified"
label variable hispanic_specify "Hispanic, Race Specified"
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

local demog amind asian black hispanic_unspecify hispanic_specify  white  bysex

local pared bypared bymothed

bysort `demog': sum `y' 
bysort `pared': sum `y'


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

foreach myvar in `y'{ /*Begin loop over scores*/
				sum `myvar'
				scalar mean_`myvar'=r(mean)
				scalar sd_`myvar'=r(sd)
				gen stand_`myvar'= (`myvar'-mean_`myvar')/(2*sd_`myvar')
}/* End loop over scores */


/*Varlist  commands*/

local bydata by*

summarize `bydata'

local first_five stu_id-f1sch_id

local myses *ses*

summarize `myses'

sum *ed

sum by*ed

svyset psu [pw=bystuwt], strat(strat_id)

*Replace all missing data

 foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */

/* Number List */
										  
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




// NO
/*
foreach test of local mytest { sum `test'
}


// NO
foreach test of local mytest { 
sum `test'}

exit 

//NO
foreach test of local mytest { sum `test'}
*/

forvalues i =1(3)100{
di "I can count by threes, look! `i' "
}


*The while command
local i = 1
while `i' <10 {
    di "I have not yet reached 10, instead the counter is now `i' "
    local i=`i'+1
  }

  
  // Foreach
  
  foreach i of numlist 1/10{
 di "Foreach can count too, look: `i'"
  }
  
/*  
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
*/

*Nested loops
forvalues i =1/10 { /* Start outer loop */
  forvalues j = 1/10 { /* Start inner loop */
    di "This is outer loop `i', inner loop `j'"
                      } /* End inner loop */
                    } /* End outer loop */

					
/* Extended Example */
use plans2, clear

svyset psu [pw=bystuwt], strat(strat_id) singleunit(scaled)

// next new recoded student expectations
recode f1psepln (1/2 = 1) (3/4 = 2) (5 = 3) (6 = .) (. = .), gen(newpln)
label var newpln "PS Plans"
label define newpln 1 "No plans" 2 "VoTech/CC" 3 "4 yr"
label values newpln newpln

// first new recoded parental education level
recode bypared (1/2 = 1) (3/5 = 2) (6 = 3) (7/8 = 4) (. = .), gen(newpared)
label var newpared "Parental Education"
label define newpared 1 "HS or Less" 2 "Less than 4yr" 3 "4 yr" 4 "Advanced"
label values newpared newpared

local y newpln
local ivars byrace2 newpared bymothed

shell rm plan_tab.$ttype
	
//  cross table of categorical
foreach ivar of local ivars{
	estpost svy: tabulate `ivar' `y', row percent se
	
	eststo desc_`ivar'
	
esttab desc_`ivar' using plan_tab.$ttype, ///
    append ///
    nostar ///
    nostar ///
    unstack ///
    nonotes ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)') ///
	nomtitles ///
	nonumbers 
	
}

					
					
}/* End analysis section */
else{
di "Did not run analysis"
}
  
exit


