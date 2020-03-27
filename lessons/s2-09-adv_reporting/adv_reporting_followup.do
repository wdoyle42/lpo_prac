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


// Grouping variable for test scores
egen ses_group=cut(byses1), group(4)

/* Set locals */

local y f2evratt

local x expect_college

local ses byses1

local race amind asian black hispanic multiracial white 

local sex bysex

local tests bynels2m bynels2r

local controls "`ses' `race' `sex' `tests'" 

local gtype pdf

local ttype rtf

local mysig=.001

bysort expect_college: sum amind if test_group==0

ttest amind if test_group==0, by(expect_college) 

// Balance test: how different is the key covariate (treatment variable) by levels of the control variables

foreach test_level of numlist 0(1)3{
    
//Counter variable
local counter=1

foreach race_var of local race{     
   
quietly reg `race_var' `x' if test_group==`test_level' // Proportion of indivduals who expect to go to college, by race and test score group

scalar my_diff = round(_b[`x'], `mysig')

scalar my_t =round(_b[`x']/_se[`x'],`mysig')

scalar my_n=e(N)
     
mat M= [my_diff\my_t\my_n]

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

matrix rownames results_tab="Native American" "t value" "N" ///
							"Asian"  "t value" "N" ///
							"African American" "t value" "N" ///
							"Hispanic" "t value" "N"  ///
							"Multiracial" "t value" "N" ///
							"White" "t value" "N" 

matrix colnames results_tab ="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 

    // Table
    
estout matrix(results_tab) using "baseline_tab.`ttype'", style(fixed) replace
 
  
// Regression results

foreach test_level of numlist 0(1)3{
    
quietly reg `y' `x' if test_group==`test_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))
    
mat M1= [my_coeff\my_se\my_n]
    
quietly reg `y' `x' `controls' if test_group==`test_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))
    
mat M2= [my_coeff\my_se\my_n]
    
mat M=(M1,M2)   

    if `test_level'==0{
        mat reg_results=M
    }
    else mat reg_results=(reg_results,M)
    
} // end loop over test levels    

    
matrix rownames reg_results= "Expect College" "SE" "N"
matrix colnames reg_results="Lowest Quartile"  "Lowest Quartile"  ///
								"2nd Quartile" 	"2nd Quartile" /// 
								"3rd Quartile" "3rd Quartile" ///
								"4th Quartile"  "4th Quartile"  

// Table
    
estout matrix(reg_results) using "reg_resuts.`ttype'", style(fixed) replace



// Regression results, SES

foreach ses_level of numlist 0(1)3{
    
quietly reg `y' `x' if ses_group==`ses_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))
    
mat M1= [my_coeff\my_se\my_n]
    
quietly reg `y' `x' `controls' if ses_group==`ses_level'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))
    
mat M2= [my_coeff\my_se\my_n]
    
mat M=(M1,M2)   

    if `ses_level'==0{
        mat reg_results_ses=M
    }
    else mat reg_results_ses=(reg_results_ses,M)
    
} // end loop over test levels    

    
matrix rownames reg_results_ses= "Expect College" "SE" "N"
matrix colnames reg_results_ses="Lowest Quartile "  "Lowest Quartile"  ///
								"2nd Quartile" 	"2nd Quartile" /// 
								"3rd Quartile" "3rd Quartile" ///
								"4th Quartile"  "4th Quartile"  

// Table
    
estout matrix(reg_results_ses) using "reg_resuts_ses.`ttype'", style(fixed) replace

    
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

//Create a graphic that shows attendance in college as a function of reading test scores, 
//for males and females, across four different SES levels.


    
// Complex Graphics

local ses_level=0
foreach ses_level of numlist 0(1)3{
local quartile=`ses_level'+1

graph twoway (scatter f2evratt bynels2r if ses_group==`ses_level' & bysex==1,msize(vtiny) color(red) mcolor(%10)) ///
             (lfit f2evratt bynels2r if ses_group==`ses_level' & bysex==1,lwidth(thin) lcolor(red)) /// 
             (scatter f2evratt bynels2r if ses_group==`ses_level' & bysex==2,msize(vtiny) color(blue)  mcolor(%10)) ///
          (lfit  f2evratt bynels2r if ses_group==`ses_level' & bysex==2,lwidth(thin) color(blue)), ///
legend(order(2 "Male" 4 "Female")) ytitle("Attend College?")  xtitle("Reading Scores") title("Quartile=`quartile'")

graph save "scatter_`quartile'.gph", replace
}    

// Combine  all levels

grc1leg2 scatter_1.gph scatter_2.gph scatter_3.gph scatter_4.gph, legendfrom("scatter_1.gph") rows(2) name(scatter,replace) xcommon ycommon

graph export scatter.eps, replace



exit 
