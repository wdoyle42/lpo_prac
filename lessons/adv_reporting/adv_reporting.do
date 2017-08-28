capture log close
// LPO Practicum
// Will Doyle
// Spring 2017
// Advanced Reporting: complex tables and graphics

clear

set more off

graph drop _all

global ddir "../../data/"

use ${ddir}attend, clear

describe

/* Missing data*/

foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -3 -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */


/* Recodes */
  
local race_names amind asian black hispanic_race hispanic_norace multiracial white

tab(byrace), gen(race_)

local i=1

foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

gen hispanic=hispanic_race==1|hispanic_norace==1

label variable byincome "Income"
label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable hispanic "Hispanic"
label variable white "White"
label variable multiracial "Multiracial"

local race amind asian black hispanic multiracial 

gen expect_college=.

replace expect_college=1 if bystexp>=5 & bystexp <.
replace expect_college=0 if bystexp>0 &bystexp <5

recode bypared (1/2=1 "No College") (3/5=2 "Some College") (6/8=3 "College Grad"), gen(pared2) 

/* Set locals */

local y f2evratt

local x expect_college

local ses byses1

local race  amind asian black hispanic multiracial

local sex  bysex

local tests bynels2m bynels2r

local controls "`ses' `race' `sex'  `pared' `tests'" 

local rownames "SES" ///
    "Native American" ///       
        "Asian" ///
            "Black" ///
                "Hispanic" ///
                    "Multiracial" ///
                        "Female" ///
                            "Math Scores" ///
                                "Reading Scores" 

local gtype pdf

local my_sig .001

// Balance test

//Start with the basics

local test_var bynels2m

quietly reg `test_var' `x' 

scalar my_diff = round(_b[`x'],`my_sig')

scalar my_t =round(_b[`x']/_se[`x'],`my_sig')

mat diffs=my_diff
mat tstats=my_t

mat li diffs
mat li tstats


// Get a bit more complicated
local i=1

foreach test_var of local controls{
    
reg `test_var' `x' 

scalar my_diff = round(_b[`x'],`my_sig')

scalar my_t =round(_b[`x']/_se[`x'],`my_sig')

if `i'==1{
    mat diffs=my_diff
    mat tstats=my_t
}


else{
    mat diffs=(diffs,my_diff)
    mat tstats=(tstats,my_t)
}

mat li diffs
mat li tstats

local i=`i'+1

} // End loop over variables 



// Now full table

local level_var pared2

levelsof `level_var', local(mylevels)

local j=1

foreach mylevel of local mylevels{ 

di "Results for level `mylevel' of `level_var'" 
    
local i=1

foreach test_var of local controls{

quietly ///    
eststo results_`mylevel':reg `test_var' `x' if `level_var'==`mylevel'

scalar my_diff = round(_b[`x'],`my_sig')

scalar my_t =round(_b[`x']/_se[`x'],`my_sig')

if `i'==1{
    mat diffs=my_diff
    mat tstats=my_t
}

else{
    mat diffs=(diffs,my_diff)
    mat tstats=(tstats,my_t)
}

local i=`i'+1

    estadd matrix diffs
    estadd matrix tstats

} //End loop over variables

local j= `j'+1
} // End loop over parental education levels


// Use estout to report 
esttab results_* using balance.rtf,cells(diffs(fmt(2)) tstats(par fmt(2)))  replace

// Regression results

local level_var pared2

levelsof `level_var', local(mylevels)

local quant_var bynels2m

egen quant_levels=cut(bynels2m), group(4)

levelsof quant_levels, local(quant_levels) 

local j=1

foreach level of local mylevels{

local i=1
    foreach quant_level of local quant_levels{

        quietly ///
        eststo reg_results_`level': ///
            reg `y' `x' `controls' ///
                if quant_levels==`quant_level' & `level_var'==`level'

        scalar my_beta=_b[`x']
        scalar my_se=_se[`x']
        scalar my_N=e(N)
		scalar my_rsq=e(r2)

        if `i'==1{
            mat betas=my_beta
            mat stderrs=my_se
            mat samples=my_N
			mat rsquares=my_rsq
        }
        
        else{
            mat betas=(betas,my_beta)
            mat stderrs=(stderrs,my_se)
            mat samples=(samples,my_N)
			mat rsquares=(rsquares,my_rsq)
        }
        
    local i=`i'+1
   
   if `i'==5{
	 eststo reg_results_`level': ///
            reg `y' `x' `controls' ///
                if `level_var'==`level'
		
		scalar my_beta=_b[`x']
        scalar my_se=_se[`x']
        scalar my_N=e(N)
		scalar my_rsq=e(r2)
		
		mat betas=(betas,my_beta)
		mat stderrs=(stderrs,my_se)
        mat samples=(samples,my_N)
		mat rsquares=(rsquares,my_rsq)
								
	} 
	
	    estadd matrix betas
        estadd matrix stderrs
        estadd matrix samples
		estadd matrix rsquares
	
    } // End loop over quant levels
local j=`j'+1

if `j'==4{
reg `y' `x' `controls' 

		scalar my_beta=_b[`x']
        scalar my_se=_se[`x']
        scalar my_N=e(N)
		scalar my_rsq=e(r2)
		
		mat betas=(betas,my_beta)
		mat stderrs=(stderrs,my_se)
        mat samples=(samples,my_N)
		mat rsquares=(rsquares,my_rsq)
       
	    estadd matrix betas, replace
        estadd matrix stderrs, replace
        estadd matrix samples, replace
		estadd matrix rsquares, replace
}
	
} // End loop over level variable


esttab reg_results_* using reg_results.rtf, ///
    cells(betas(fmt(2)) stderrs(par fmt(2)) rsquares(fmt(2)) samples(fmt(0))) ///
    noobs ///
    replace
	
exit 
	
  quietly ///
        eststo reg_results_test: ///
            reg `y' `x' `controls' 
         
		 
        scalar my_beta=_b[`x']
        scalar my_se=_se[`x']
        scalar my_N=e(N)
		scalar my_rsq=e(r2)
		
		
		mat betas=my_beta
        mat stderrs=my_se
        mat samples=my_N
		mat rsquares=my_rsq

		estadd matrix betas
        estadd matrix stderrs
        estadd matrix samples
		estadd matrix rsquares
		
	esttab reg_results_test, cells("stderrs rsquares samples")
	
exit 
