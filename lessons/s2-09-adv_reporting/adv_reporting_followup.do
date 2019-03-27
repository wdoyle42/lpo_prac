capture log close
// LPO Practicum
// Will Doyle
// Spring 2019
// Advanced Reporting: complex tables and graphics

log using adv_reporting.log, replace

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

// Grouping variable for test scores
egen test_group=cut(bynels2m), group(4)

// Grouping variable for SES
egen ses_group=cut(byses1), group(4)


gen female=bysex==2
replace female=. if bysex==. 

/* Set locals */

local y f2evratt

local x expect_college

local ses byses1

local table_rows amind asian black hispanic multiracial white female

local sex bysex

local tests bynels2m bynels2r

local controls "`ses' `race' `sex' `tests'" 

local gtype pdf

local ttype rtf

local mysig=.001

// Balance test: how different is the key covariate (treatment variable) by levels of the control variables

foreach test_level of numlist 0(1)4{
    
//Counter variable
local counter=1

foreach row of local table_rows{
     
	 if `test_level'<4{
     quietly reg `row' `x' if test_group==`test_level'
}
else quietly reg `row' `x'  

scalar my_diff = round(_b[`x'], `mysig')

scalar my_t =round(_b[`x']/_se[`x'],`mysig')
     
mat M= [my_diff\my_t]

mat li M

if `counter'==1{
    mat M_col=M
}
    else mat M_col=(M_col\M)
 local counter=`counter'+1 
 
 mat li M_col
} //end loop over race variables

    if `test_level'==0{
       mat results_tab=M_col
    }
    else mat results_tab=(results_tab,M_col)
	
mat li results_tab
} // End loop over test scores

matrix rownames results_tab="Native American" "t value" ///
							"Asian"  "t value" /// 
							"African American" "t value" /// 
							"Hispanic" "t value"  /// 
							"Multiracial" "t value"  ///
							"White" "t value" ///
							"Female" "t value"

matrix colnames results_tab ="Lowest Quartile" ///
							"2nd Quartile"  ///
							"3rd Quartile" ///
							"4th Quartile" ///
							"Full Sample" 

    // Table
    
estout matrix(results_tab) using "baseline_tab.`ttype'", style(fixed) replace
   

   
/***************************************/
/* THIS IS THE TEST SCORE TABLE */
/***************************************/ 
 
  
// Regression results

matrix drop _all

foreach test_level of numlist 0(1)3{
    
quietly reg `y' `x' if test_group==`test_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

mat M1= [my_coeff\my_se]
    
quietly reg `y' `x' `controls' if test_group==`test_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))
    
mat M2= [my_coeff\my_se\my_n]
    
mat M=(M1\M2)   

    if `test_level'==0{
        mat reg_results=M
    }
    else mat reg_results=(reg_results,M)
    
} // end loop over test levels    

    
matrix rownames reg_results= "Expect College" "SE" "Expect College" "SE" "N"
matrix colnames reg_results="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 




// Table
    
 estout matrix(reg_results) using "reg_resuts_test.`ttype'", style(fixed) replace

 mat drop _all
/***************************************/
/* THIS IS THE SES TABLE */
/***************************************/ 
 
foreach ses_level of numlist 0(1)3{
    
quietly reg `y' `x' if ses_group==`ses_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

mat M1= [my_coeff\my_se]
    
quietly reg `y' `x' `controls' if ses_group==`ses_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))
    
mat M2= [my_coeff\my_se\my_n]
    
mat M=(M1\M2)   

    if `ses_level'==0{
        mat reg_results=M
    }
    else mat reg_results=(reg_results,M)
    
} // end loop over test levels    

    
matrix rownames reg_results= "Expect College" "SE" "Expect College" "SE" "N"
matrix colnames reg_results="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 




// Table
    
 estout matrix(reg_results) using "reg_resuts_ses.`ttype'", style(fixed) replace

 

    
// Complex Graphics

local test_level=0
foreach test_level of numlist 0(1)3{
local quartile=`test_level'+1

graph twoway (scatter bynels2m byses1 if test_group==`test_level' & expect_college==0,msize(vtiny) color(red) mcolor(%10)) ///
             (lfit bynels2m byses1 if test_group==`test_level' & expect_college==0,lwidth(thin) lcolor(red)) /// 
             (scatter bynels2m byses1 if test_group==`test_level' & expect_college==1,msize(vtiny) color(blue)  mcolor(%10)) ///
			(lfit  bynels2m byses1 if test_group==`test_level' & expect_college==1,lwidth(thin) color(blue)), ///
legend(order(2 "Doesn't expect to go to college" 4 "Expects to go to college")) ytitle("Test Scores")  xtitle("SES") title("Quartile=`quartile'")

graph save "scatter_`quartile'.gph", replace
}    

// Combine  all levels

grc1leg2 scatter_1.gph scatter_2.gph scatter_3.gph scatter_4.gph, legendfrom("scatter_1.gph") rows(2) name(scatter,replace) xcommon ycommon

graph export scatter.eps, replace

egen pct_math=cut(bynels2m), group(100)

preserve
collapse (mean) f2evratt, by(pct_math)

graph twoway scatter f2evratt pct_math
restore

egen pct_read=cut(bynels2r), group(100)


foreach ses_level of numlist 0(1)3{

local quartile=`ses_level'+1

preserve

keep if ses_group==`ses_level'

collapse (mean) f2evratt, by(pct_read female)

graph twoway (scatter f2evratt pct_read  if female==0,msize(small) color(red) mcolor(%10)) ///
             (lfit f2evratt pct_read  if female==0,lwidth(thin) lcolor(red)) /// 
             (scatter f2evratt pct_read  if female==1,msize(small) color(blue)  mcolor(%10)) ///
			(lfit  f2evratt pct_read if female==1,lwidth(thin) color(blue)), ///
			legend(order(2 "Male" 4 "Female")) /// 
			ytitle("Pr(Attend)")  xtitle("Reading") ///
			title("SES Quartile=`quartile'") ///
			ylabel(0(.2)1, format(%9.1f))

graph save "scatter_`quartile'.gph", replace

restore
}    

// Combine  all levels

grc1leg2 scatter_1.gph scatter_2.gph scatter_3.gph scatter_4.gph, legendfrom("scatter_1.gph") rows(2) name(scatter,replace) xcommon ycommon


exit 
