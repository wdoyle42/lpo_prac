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

/* Set locals */

local y f2evratt

local x expect_college

local ses byses1

local race amind asian black hispanic multiracial white 

local sex bysex

local tests bynels2m bynels2r

local controls "`ses' `race' `sex' `tests'" 

local gtype pdf

local ttype html

local mysig=.001

// Balance test: how different is the key covariate (treatment variable) by levels of the control variables



foreach test_level of numlist 0(1)3{
    
//Counter variable
local counter=1

foreach race_var of local race{        
     quietly reg `race_var' `x' if test_group==`test_level'

scalar my_diff = round(_b[`x'], `mysig')

scalar my_t =round(_b[`x']/_se[`x'],`mysig')
     
mat M= [my_diff\my_t]

desc `race_var'
local varlabel : var label `race_var'
mat rownames M = "`varlabel'" "t value"
//mat colnames M_col = "Quartile `test_level'"

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


//matrix rownames results_tab="Native American" "t value"  "Asian"  "t value" "African American" "t value" "Hispanic" "t value" "Multiracial" "t value" "White" "t value"

matrix colnames results_tab ="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 

// Table
    
estout matrix(results_tab) using "baseline_tab.`ttype'", style(fixed) replace
 

 
/*
 desc `race_var'
local varlabel : var label `race_var'
mat rownames M = "`varlabel'" "t value"
mat colnames M_col = "Quartile `test_level'"
*/

   

// Grouping variable for test scores
egen ses_group=cut(byses1), group(4)
   
 
// Balance test: how different is the key covariate (treatment variable) by levels of the control variables

foreach ses_level of numlist 0(1)3{
    
//Counter variable
local counter=1

foreach race_var of local race{        
     quietly reg `race_var' `x' if ses_group==`ses_level'

scalar my_diff = round(_b[`x'], `mysig')

scalar my_t =round(_b[`x']/_se[`x'],`mysig')
     
mat M= [my_diff\my_t]

desc `race_var'
local varlabel : var label `race_var'
mat rownames M = "`varlabel'" "t value"
mat colnames M_col = "Quartile `test_level'"

mat li M

if `counter'==1{
    mat M_col=M
}
    else mat M_col=(M_col\M)
 local counter=`counter'+1 
 
 mat li M_col
} //end loop over race variables

    if `ses_level'==0{
       mat results_tab=M_col
    }
    else mat results_tab=(results_tab,M_col)
	
mat li results_tab
} // End loop over test scores

matrix rownames results_tab="Native American" "t value"  "Asian"  "t value" "African American" "t value" "Hispanic" "t value" "Multiracial" "t value" "White" "t value"

matrix colnames results_tab ="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 

    // Table
    
estout matrix(results_tab) using "baseline_ses_tab.`ttype'", replace  
   
// Generate a similar table (differences by group for expect to go to college), but put parental education on the rows and SES quartiles on the columns

tab bypared

recode bypared (1=1 "Less than HS") (2=2 "HS") (3/5=3 "Some College") (6=4 "Bachelor's'") (7/8=5 "Advanced") , gen(bypared_r)


tab bypared_r, gen(pared_)

local ses_levels 0 1 2 3

local pared_levels pared_1 pared_2 pared_3 pared_4 pared_5



foreach ses_level of local ses_levels{

local counter=1

foreach pared_level of local pared_levels{

reg `pared_level' `x' if ses_group==`ses_level'

scalar my_diff = round(_b[`x'], `mysig')

scalar my_t =round(_b[`x']/_se[`x'],`mysig')
     
mat M= [my_diff\my_t]

local varlabel : var label `pared_level'
mat rownames M = "`varlabel'" "t value"
mat colnames M_col = "Quartile `ses_level'"

mat li M

if `counter'==1{
	mat M_col=M
}
else{
	mat M_col=M_col\M
}

mat li M_col

local counter=`counter'+1

} // Closes loop over parental education

if `ses_level'==0{
	mat results_tab=M_col
}
else{
	mat results_tab=[results_tab,M_col]
}

mat li results_tab

} // Closes loop over SES Levels

estout matrix(results_tab) using "ses_results.rtf" , style(fixed) replace

exit   
   
   
   
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
matrix colnames reg_results="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 

// Table
    
estout matrix(reg_results) using "reg_resuts.`ttype'", replace


   
// Regression results: Part 2

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

quietly reg `y' i.`x'##c.bynels2m `controls' if ses_group==`ses_level'

scalar my_coeff = round(_b[1.`x'], `mysig')

scalar my_se =round(_se[1.`x'],`mysig')

scalar my_coeff_int = round(_b[1.`x'#c.bynels2m], `mysig')

scalar my_se_int =round(_se[1.`x'#c.bynels2m],`mysig')

scalar my_n=round(e(N))
  
mat M3=[my_coeff\my_se\my_coeff_int\my_se_int\my_n] 

mat M=[M1\M2\M3]

mat li M 

    if `ses_level'==0{
        mat reg_results=M
    }
    else mat reg_results=(reg_results,M)
    
} // end loop over test levels    

   
matrix rownames reg_results= "Expect College (no controls)" "SE" "N" ///
								"Expect College (controls)" "SE" "N" ///
								"Expect College (main effect)" "SE" ///
								"Expect College X Math Test Score" "SE" "N"  
								
matrix colnames reg_results="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 

// Table
    
estout matrix(reg_results) using "reg_resuts_interaction.`ttype'", replace



    
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


xtile read_pctile=bynels2r, nq(25)

replace ses_group=ses_group+1

preserve

collapse (mean) probattend=f2evratt , by(read_pctile bysex ses_group)

format probattend %9.5f

foreach ses_level of numlist 1(1)4{
	
graph twoway (scatter probattend read_pctile if bysex==1 &ses_group==`ses_level', msize(tiny) color(red) mcolor(%10))	///
	         (scatter probattend read_pctile if bysex==2 &ses_group==`ses_level', msize(tiny) color(blue) mcolor(%10))
			 legend(order(1 "Males" 2 "Females"))
			 
graph save "scatter_ses_`ses_level'.gph", replace
}

grc1leg2 scatter_ses_1.gph scatter_ses_2.gph scatter_ses_3.gph scatter_ses_4.gph, legendfrom("scatter_ses_1.gph") rows(2) name(scatter,replace) xcommon ycommon


restore

exit 
