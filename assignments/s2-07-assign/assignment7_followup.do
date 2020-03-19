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

drawnorm e, sd(`sd_error')

exit 

///Create the outcome variable (math scores) as a function of SES, 
///planning to go to college and parental education. Make this flexible such 
//that the impact of parental education can vary.

//Repeatedly sample from the population data you generated above, 
//then run two regressions for each sample, one which includes parental 
//education and one which does not. Create a graphic that shows the sampling 
//distribution for your coeffiicent for planning to go college when you do and
// don't control for both SES AND parental education.

///Now allow the impact of parental education on math scores to vary in 
//the population. Run a Monte Carlo study that shows what happens to the 
//sampling distribution of coefficients for planning to go college when do and 
///don't control for both SES and parental education when parental education
// has differing impacts on math scores.
