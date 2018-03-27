capture log close 

version 14 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */
log using "panel.log", replace
    
/* Panel data */
/* Assignment 10 follow up*/
/* Will Doyle */
/* 2018-03-25 */
/* Practicum Folder */

clear
clear mata /* Clears any fluff that might be in mata */
estimates clear /* Clears any estimates hanging around */
set more off /*Get rid of annoying "more" feature */ 

graph drop _all

use diss, clear

order state year
sort state year


//1. Run a “pooled” regression, estimating the impact of percent of the population aged 18-24
//on appropriations, with appropriate controls

local y approps_i

local x perc1824

local controls  incpcp_i percpriv taxcpc_i  legcomp_i i.board 

reg `y'  `x' `controls'



//2. Run a separate regression for each year estimating the above relationship. Comment on
//any patterns you see.

sum year, detail
local mymin=r(min)
local mymax=r(max)
postfile buffer beta_1 se_beta_1 year using reg_year, replace 

foreach i of numlist `mymin'/`mymax'{

reg `y'  `x' `controls' if year==`i'

post buffer (_b[`x'])   (_se[`x']) (`i')

}
postclose buffer

use reg_year, clear

gen hi_ci=beta+(1.96*se_beta_1)
gen low_ci=beta-(1.96*se_beta_1)

graph twoway (rcap hi_ci low_ci year) ///
          (scatter beta_1 year)



//3. Run a separate regression for each state, estimating the above relationship. Comment on
//any patterns you see.

use diss, clear

sum state, detail
local mymin=r(min)
local mymax=r(max)
postfile buffer beta_1 se_beta_1 state using reg_state, replace 

foreach i of numlist `mymin'/`mymax'{

reg `y'  `x' `controls' if state==`i'

post buffer (_b[`x'])   (_se[`x']) (`i')

}
postclose buffer

use reg_state, clear

gen hi_ci=beta+(1.96*se_beta_1)
gen low_ci=beta-(1.96*se_beta_1)

graph twoway (rcap hi_ci low_ci state) ///
          (scatter beta_1 state)


//4. Run a model with state fixed effects, comment (in the do file) on the key estimate.
use diss, clear

xtset state year, yearly

/* Fixed Effects for Units (states) */

eststo state_fe:xtreg `y'  `x' `controls', fe

//5. Run a model with year fixed effects, comment (in the do file) on the key estimate.

eststo year_fe:reg `y' `x' `controls' i.year

// 6. Run a model with state and year fixed effects, comment on the key estimate.

eststo state_year_fe:xtreg `y'  `x' `controls' i.year, fe

//7. Run a model with state fixed effects and an appropriate adjustment for autocorrelation.

eststo fe_ar1: quietly xtpcse `y' `x' `controls' i.state i.year, correlation(psar1) independent

estimates table, keep(`x' `controls')

//8. Create a plot that demonstates the impact of percent of the population aged 18-24 on
//appropriations, based on your preferred estimate.

bysort state: sum `x'

// Biggest within unit change is ~4 percentage points

estimates restore fe_ar1

margins, predict(xb) at(`x'=(9(.05)13) )

marginsplot, recastci(rarea) recast(line)

exit 
