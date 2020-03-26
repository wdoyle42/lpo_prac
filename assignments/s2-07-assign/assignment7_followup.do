capture log close

version 15 

// Assignment 6 Followup
// Will Doyle
// Using simulation to understand model specification
// On github

global ddir "../../data/"

local female female
    
local ses byses1
    
local pared mothed
    
local race urm 

local plans p_fouryr 

local y bynels2m 

local popsize =1.6e5

local nreps 1000

use "${ddir}plans3.dta", clear


// Recoding

gen mothed =inlist(bymothed, 6,7,8)
replace mothed =. if bymothed==. 

// Proportions for binary variables
prop `plans'

local prop_plans=_b[1]

prop `pared'

local prop_pared=_b[1]


// Correlation matrix to preserve relationships
corr  `plans' `pared' `ses'

mat cormat=r(C)

reg `y' `plans' `pared' `ses'

estimates store plan_reg

local sd_error=e(rmse)

/*Grab coeffs*/

local int=_b[_cons]    

local plans_coeff=_b[`plans']

local pared_coeff=_b[`pared']

local ses_coeff=_b[`ses']


///Create a simulated binary variable for planning to go to college.
/// Ensure that the same proportion of your population wants to go to college 
///as in the sample. Also make sure that this variable is correlated with SES 
//and parental education in the same magnitude and direction as in your sample.


/// Create another binary variable for whether the respondent's mother graduated
/// from college. Make this also have the same proportion of your sample is in 
//the plans dataset, and has the same correlation with SES and planning to go 
// to college.

clear 

corr2data  plans_st pared_st ses , corr(cormat) n(`popsize')

display "`prop_plans'"

gen plancut=invnormal(1-`prop_plans') 
gen plans=plans_st>plancut 

gen paredcut=invnormal(1-`prop_pared')
gen pared= pared_st>paredcut 

// Generate Error Term
drawnorm e, sd(`sd_error')

///Create the outcome variable (math scores) as a function of SES, 
///planning to go to college and parental education. Make this flexible such 
//that the impact of parental education can vary.

gen y=`int' + `plans_coeff'*plans +`pared_coeff'*pared+`ses_coeff'*ses+e

save simulated_data, replace

//Repeatedly sample from the population data you generated above, 
//then run two regressions for each sample, one which includes parental 
//education and one which does not. 

tempname results_store
postfile `results_store' plans1 plans2  using results_file, replace
local j=1  
while `j'<=100{  

preserve 
  
quietly sample 10

quietly reg y plans pared ses  /* True regression */

scalar plans1=_b[plans]

 /*Pulls coefficient, puts it into scalar */
quietly reg y plans ses /*OVB regression */

scalar plans2=_b[plans]

post `results_store' (plans1) (plans2)

di "Finishing iteration `j'"

restore

local j=`j'+1
}
postclose `results_store'

// Create a graphic that shows the sampling 
// distribution for your coeffiicent for planning to go college when you do and
// don't control for both SES AND parental education.

use results_file, clear

kdensity plans1, addplot(kdensity plans2) 


///Now allow the impact of parental education on math scores to vary in 
//the population. Run a Monte Carlo study that shows what happens to the 
//sampling distribution of coefficients for planning to go college when do and 
///don't control for both SES and parental education when parental education
// has differing impacts on math scores.


/*Now vary effect size*/

local effect_size -.1 -.05 .05 1

local k=1

foreach effect of local effect_size{

use simulated_data, clear

drop y

gen y=`int' + `plans_coeff'*plans +`effect'*pared+`ses_coeff'*ses+e

tempname results_store

postfile `results_store' plans1 plans2  using results_file_`k', replace
local j=1  
while `j'<=100{  

preserve 
  
quietly sample 10

quietly reg y plans pared ses  /* True regression */

scalar plans1=_b[plans]

 /*Pulls coefficient, puts it into scalar */
quietly reg y plans ses /*OVB regression */

scalar plans2=_b[plans]

post `results_store' (plans1) (plans2)

di "Finishing iteration `j'"

restore

local j=`j'+1
}
postclose `results_store'

use results_file_`k', clear

kdensity plans1, xline(`plans_coeff', lcolor(black) lpattern(dash)) ///
	addplot(kdensity plans2,note("")) ///
	legend(order(1 "True Model" 2 "OVB Model")) ///
	xtitle("Coefficients for Plan") ///
	title("Coefficient for Plans, when Pared=`effect'") ///
	note("")

graph save monte_carlo_`k'.gph, replace

local k=`k'+1

} // Close loop over effect sizes



grc1leg monte_carlo_1.gph ///
monte_carlo_2.gph ///
 monte_carlo_3.gph ///
 monte_carlo_4.gph , rows(2) cols(2)

