capture log close

log using "excerpta_statistica.log", replace

// TI:Recap of topics
// AU: Will Doyle
// DESC: Recap of topics from previously in the year
// Init:5/9/2018



clear

set more off

graph drop _all

global ddir "../../data/"

global ttype rtf

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



// next new recoded student expectations
recode f1psepln (1/2 = 1) (3/4 = 2) (5 = 3) (6 = .) (. = .), gen(newpln)
label var newpln "PS Plans"
label define newpln 1 "No plans" 2 "VoTech/CC" 3 "4 yr"
label values newpln newpln

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


// Conditional Means: Tables and Plots

// bar plots 

graph hbar f2evratt [pw=bystuwt], ///
		over(byinc) ///
		ytitle("College Attendance") ///
		legend(order(1 "Math Scores" 2 "Reading Scores"))  ///
		blabel(bar,format(%9.2f)) ///
		bar(1, color(orange*.5)) bar(2, color(blue*.5))
 		
//		, sort(bynels2m) descending)


//  cross table of categorical

svyset psu [pw=bystuwt],strat(strat_id) singleunit(scaled)

estpost svy: tabulate byrace newpln, row percent se 

eststo racetab

esttab racetab using race_tab.$ttype, ///
    replace ///
    nostar ///
    nostar ///
    unstack ///
    nonotes ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)')

	

		
// Interactions: how to interpret, table and plot

/// Margins after interactions


ssc install nnest

bcuse wage2, clear

label variable wage "Wages from work in last month"

label variable hours "Weekly hours"

label variable IQ "IQ test"

label variable KWW "Knowledge of world of work"

label variable educ "Years of education"

label variable tenure "Months in current job"

label variable age "Age"

label variable married "Married"

label variable black "African-American"

label variable south "South"

label variable urban "Urban"

label variable sibs "No. Siblings"

label variable brthord "Birth order"

label variable meduc "Mother's years of school"

label variable feduc "Father's years of education"

label variable lwage "ln Wage"

renvars *, lower

save wage2, replace

gen black_marry=black*married
  
eststo black_marry: reg lwage hours age educ i.black##i.married iq meduc south urban

estimates replay black_marry 

estimates restore black_marry

local mydf=e(df_r)

margins , predict(xb) at(black=(1 0) married=(0 1) south=1 urban=1 (mean) hours age educ iq meduc ) post

mat mypred=e(b)'

// Exponentiate the results using mata
mata: st_matrix("mypred", exp(st_matrix("mypred")))

// Save as data
svmat mypred

mat mypred1=e(b)'

svmat mypred1

local no_predict=rowsof(mypred)

di "no of preds is `no_predict'"

egen mycount=fill(1(1)`no_predict')

graph twoway bar mypred1 mycount in 1/4, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000) 
  

estimates restore black_marry

margins , predict(stdp) at((mean) _all black=(1 0) married=(0 1) south=1 urban=1) post nose

mat mystdp=e(b)'

svmat mystdp

local sigtail .025

gen ub_log=mypred11+ (invttail(`mydf',`sigtail')*mystdp)
gen lb_log=mypred11- (invttail(`mydf',`sigtail')*mystdp)

gen ub=exp(ub_log)
gen lb=exp(lb_log)

graph twoway (bar mypred1 mycount if mycount==1, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
              (bar mypred1 mycount if mycount==2, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
               (bar mypred1 mycount if mycount==3, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
                (bar mypred1 mycount if mycount==4, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
                    (rcap ub lb mycount in 1/`no_predict'), ///
                        xlabel(1 "Unmarried, Black" 2 "Married, Black" 3 "Unmarried, White" 4 "Married, White") ytitle("Predicted Wages")   xtitle("") legend(off)

						
/* Clear out prediction variables */    
drop mypred*
drop mystdp*
drop ub*
drop lb*
drop mycount    

eststo age_educ : reg lwage hours c.age##c.educ black married iq meduc south urban 
						
/* Working with continuous vs. Continuous interactions */
sum age, detail

local mymin=r(min)
local mymax=r(max)

/*Step through education in 2 year intervals, get predictions across range of age*/

foreach myeduc of numlist 10(2)16{

estimates restore age_educ
    
margins, predict(xb) at((mean) _all age=(`mymin'(1)`mymax') educ=`myeduc') post
mat pred_ed`myeduc'=e(b)'
mat li pred_ed`myeduc'
svmat pred_ed`myeduc'

estimates restore age_educ

margins, predict(stdp) at((mean) _all age=(`mymin'(1)`mymax') educ=`myeduc') nose post
mat pred_se_ed`myeduc'=e(b)'
mat li pred_se_ed`myeduc'
svmat pred_se_ed`myeduc'
}

foreach myeduc of numlist 10(2)16{
    gen exp_pred`myeduc'=exp(pred_ed`myeduc'1)
    gen ub`myeduc'=exp(pred_ed`myeduc'+(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
    gen lb`myeduc'=exp(pred_ed`myeduc'-(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
}

/* Need my at values */

egen age_levels=fill(`mymin'(1)`mymax')    

twoway line exp_pred10 exp_pred12 exp_pred14 exp_pred16 age_levels in 1/11, ///
       legend(order(1 "10 Years" 2 "12 Years" 3 "14 Years" 4 "16 Years"))  ytitle("Wages") xtitle("Age") name(educ_mult)
 
	   
/* Plot at different levels with confidence intervals */
twoway (rarea ub10 lb10 age_levels in 1/11, color(gs14)) ///
    (rarea ub16 lb16 age_levels in 1/11, color(gs14)) ///
        (line exp_pred10 age_levels in 1/11, lcolor(blue) ) ///
            (line lb10 age_levels in 1/11, lcolor(blue) lwidth(thin) lpattern(dash)) ///
                (line ub10 age_levels in 1/11, lcolor(blue) lwidth(thin) lpattern(dash)) ///
                    (line exp_pred16 age_levels in 1/11, lcolor(red) ) ///
                        (line ub16 age_levels in 1/11, lcolor(red) lwidth(thin) lpattern(dash)) ///
                            (line lb16 age_levels in 1/11, lcolor(red) lwidth(thin) lpattern(dash)) , ///
                                legend(order( 3 "Less than HS" 6 "College Grad"))  xtitle("Age") name(educ_ci)

								
drop lb* ub* exp_pred* pred* pred_ed* pred_se_ed*



// Loops


foreach test_level of numlist 0(1)3{
    
//Counter variable
local counter=1

foreach race_var of local race{        
     quietly reg `race_var' `x' if test_group==`test_level'

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

matrix rownames results_tab="Native American" "t value"  "Asian"  "t value" "African American" "t value" "Hispanic" "t value" "Multiracial" "t value" "White" "t value"

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
matrix colnames reg_results="Lowest Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile" 

   

// Differences/ Lags



// Matching and Missing Data




exit 
log close
