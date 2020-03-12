version 12 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "simulation.log",replace /*Open up new log */

/* Simluation techniques */
/* Using simulation to understand and correct problems with regression*/
/* Will Doyle */
/* 200227 */
/* Practicum Folder */

clear

clear mata /* Clears any fluff that might be in mata */

clear matrix

graph drop _all
  
estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */
   

/**************************************************/
/* Outline */
/**************************************************/

/* 1. Recoding and data setup */

local recoding=0
  
/* 2. Analysis and output */

local analysis=1
  
/*3. Simulation */

local simulation=1

local complex_example=0



/**************************************************/
/* Globals */
/**************************************************/

global ddir "../../data/"

/**************************************************/
/* Locals */
/**************************************************/

// Graphics type
local gtype png

// Table type
local ttype rtf

/**************************************************/  
/* 1. Recoding and data Setup */
/**************************************************/  
if `recoding'==1{
    
    use ${ddir}plans.dta, clear

/*Replace missing data */
  
foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */


label variable byincome "Income"
                                              
 /* Recode race/ethnicity */
                                                                                            
local race_names amind asian black hispanic_norace hispanic_race multiracial white

tab(byrace), gen(race_)

 
local i=1

foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

gen hispanic=0
replace hispanic=1 if hispanic_no==1|hispanic_race==1
replace hispanic=. if byrace==.

label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable hispanic "Hispanic"
label variable white "White"
label variable multiracial "Multiracial"

/*Create var for underrrep minority */
    
gen urm=0
replace urm=1 if black==1 | hispanic==1
replace urm=. if byrace==.

label var urm "Underrepresented Minority"
  
local plan_names p_noplan p_dontknow p_votech p_cc p_fouryr p_earlygrad

tab(f1psepln), gen(plan_)

local i=1

foreach val of local plan_names{
  rename plan_`i' `val'
  local i=`i'+1
}


label variable p_noplan "Plans: No plans"
label variable p_dontknow "Plans: Don't know"
label variable p_votech "Plans: Voc/Tech School"
label variable p_cc "Plans: Comm Coll"
label variable p_fouryr "Four Year"
label variable p_earlygrad "Early Graduation"

  
local pareds bymothed byfathed bypared

local ed_names nohs hs attend2 grad2yr some4  4yrgrad masters phd

foreach pared of local pareds{

tab(`pared'), gen(`pared'_)

local i=1


foreach val of local ed_names{
  rename `pared'_`i' `pared'_`val'
  local i=`i'+1
}

label variable `pared'_nohs "Less than HS"
label variable `pared'_hs "HS/GED"
label variable `pared'_attend2 "Attended 2 yr"
label variable `pared'_grad2yr "Graduated 2yr"
label variable `pared'_some4 "Four year attend"
label variable `pared'_4yrgrad "Bachelor's"
label variable `pared'_masters "Master's"
label variable `pared'_phd "PhD"
}


gen pared_bin=0
replace pared_bin=1 if bypared_4yrgrad==1 | bypared_masters==1| bypared_phd==1
replace pared_bin=. if bypared==.

  
gen female=bysex==2
replace female=. if bysex==.

label variable female "Female"

/* y=50+(-2*fakefem)+(10*plans)+(-10*race)+(10*pared)+`effect'*counsel+e*/

save ${ddir}plans3, replace    
  
}/*End recoding section */

else di "No recoding"

/**************************************************/
/* 2. Locals */
/**************************************************/  

local female female
    
local ses byses1
    
local pared pared_bin 
    
local race urm 

local plans p_fouryr 

local y bynels2m 
/**************************************************/
/*3. Analysis and output*/
/**************************************************/

if `analysis==1'{

use ${ddir}plans3.dta, clear
    
/*Stuff we'll want later */

prop `female'

local prop_fem=_b[1]

prop `plans'

local prop_plans=_b[1]

prop `race'

local prop_race=_b[1]

prop `pared'

local prop_pared=_b[1]

corr `female' `plans' `race' `pared' `ses'

mat cormat=r(C)


/*Survey set */
svyset psu [pw=f1pnlwt],str(strat_id)

/*Run regression*/
    
svy: reg `y' `female' `plans' `race' `pared' `ses'

/*Grab coeffs*/

local int=_b[_cons]    

local fem_coeff=_b[`female']

di `fem_coeff'

local plans_coeff=_b[`plans']

local race_coeff=_b[`race']

local pared_coeff=_b[`pared']

local ses_coeff=_b[`ses']

eststo myresults

predict res, resid

sum(res)

#delimit;
quietly esttab * using sim_model.rtf,          /* estout command: * indicates all estimates in memory. csv specifies comma sep, best for excel */
               label                          /*Use labels for models and variables */
               nodepvars                      /* Use my model titles */
               b(2)                           /* b= coefficients , this gives two sig digits */
               not                            /* I don't want t statistics */
               se(2)                         /* I do want standard errors */
               nostar                       /* No stars */
               r2 (2)                      /* R squared */
               scalar(F  df_m df_r N)   /* select stats from the ereturn (list) */
               sfmt (2 0 0 0)                /* format for stats*/
               replace                   /* replace existing file */
               note("Linearized standard errors in parentheses.")
               ;
#delimit cr

} /*End Analysis Section*/


    
/**************************************************/
/* 4.Simulation */ 
/**************************************************/

if `simulation'==1{

clear
    
// TOC

set seed 0621

//1: Run CLT example
local xbar_example=0

//2: Run basic regression example
local reg_example_1=0

//3: Run multiple regression example
local reg_example_2=0

//4: Run complex example based on data
local complex_example=1
    
// Create a hypothetical situation

local mymean 5
local mysd 1
local pop_size 10000
local sample_size 100
local nreps 1000

// Is CLT a real thing?

if `xbar_example'==1{

// Create variable x based on values above
drawnorm x, means(`mymean') sds(`mysd') n(`pop_size')

save x, replace

// Population mean
mean x

scalar pop_mean=_b[x]

// Popoluation standard deviation
tabstat x, stat(sd) save

mat M=r(StatTotal)

scalar pop_sd=M[1,1]

preserve // Set return state
sample `sample_size', count // Take a sample 
mean x // Calculate mean 
tabstat x, stat(sd) // Calculate sds
restore //
 

		
// create a place in memory called buffer which will store a variable called xbar in a file called means.dta
postfile buffer xbar x_sd using means, replace 

forvalues i=1/`nreps'{
	preserve // Set return state
	quietly sample `sample_size', count // Keep only certain observations
	quietly mean x // get mean
	scalar sample_mean= _b[x] // post the first estimate to the buffer
	qui tabstat x, stat(sd) save //calc sd
	mat M=r(StatTotal) //get results
	scalar sample_sd=M[1,1] // grab result to store in scalar
	post buffer (sample_mean) (sample_sd) //post the first estimate to the buffer
	restore // Go back to full dataset
}

postclose buffer // Buffer can stop recording

use means, clear

kdensity xbar, xline(`mymean')

kdensity x_sd, xline(`mysd')

graph export clt.`gtype', replace

mean xbar

scalar simulate_mean=_b[xbar]

//Here's what SE should be:
scalar hypo_se=`mysd'/sqrt(`sample_size')

//Here's what SE is: 
tabstat xbar,stat(sd) save

mat M=r(StatTotal)

scalar simulate_se=M[1,1]

}

// Run this analysis, but include the standard deviation as an element of the
// monte carlo results

// Run MC study for basic regression
if `reg_example_1'==1{

local sample_size=1000

// Regression simulation: first example

clear

drawnorm x, n(10000)

// Generate error term
local error_sd 10

drawnorm e, means(0) sds(`error_sd')

// Set values for parameters
local beta_0=10

local beta_1=2

// Generate outcome
gen y=`beta_0'+`beta_1'*x + e

    // create a place in memory called buffer which will store a variable called xbar in a file called means.dta
postfile buffer beta_0 beta_1 using reg_1, replace 

forvalues i=1/`nreps'{
	preserve // Set return state
	quietly sample `sample_size', count // Keep only certain observations
	quietly reg y  x // get parameter estimates
	post buffer (_b[_cons]) (_b[x]) // post the estimate to the buffer
	restore // Go back to full dataset
}

postclose buffer // Buffer can stop recording

// Open up results of MC study for basic regression
use reg_1, clear

kdensity beta_0, xline(`beta_0')

graph export beta_0.`gtype', replace

kdensity beta_1, xline(`beta_1')

graph export beta_1.`gtype', replace

mean beta_0

mean beta_1

}


    
// Multiple regression example

if `reg_example_2'==1{

clear

local nreps=100

local pop_size=100000

local error_sd=10

local my_corr=-.1

local my_means 10 20 

local my_sds 5 10

// Create variable x based on values above
drawnorm x1 x2, ///
	means(`my_means')  ///
	sds(`my_sds') ///
	corr(1,`my_corr'\`my_corr',1) ///
	n(`pop_size') ///
	cstorage(lower)
	
drawnorm e, mean(0) sd(`error_sd')

local beta_0=10

local beta_1=2

local beta_2=4

gen y= `beta_0'+`beta_1'*x1 +`beta_2'*x2 + e
    
// create a place in memory called buffer which will store a variable called xbar in a file called means.dta
postfile buffer beta_0 beta_1 using reg_2, replace 

forvalues i=1/`nreps'{
	preserve // Set return state
	quietly sample `sample_size', count // Keep only certain observations
	quietly reg y  x1  // get parameter estimates
	post buffer (_b[_cons]) (_b[x1]) // post the estimate to the buffer
	restore // Go back to full dataset
}

postclose buffer // Buffer can stop recording

use reg_2, clear

kdensity beta_1, xline(`beta_1')

graph export ovb.`gtype', replace

}
}


    
/* Generating Random Variables */

if `complex_example'==1{
    
clear

set seed 0621

/*Continuous variables: uncorrelated*/

local popsize =1.6e5
drawnorm fakeses, n(`popsize')

drop fakeses

/*Continous variables: correlated */
drawnorm fakeses fakeincome, means(0 40)  sds(1 15) corr(1 .7\.7 1) n(`popsize') /*Need to specify means and size of correlation */

drop fakeses fakeincome
    
/*Binary variable: independent */

gen fakefem=rbinomial(1,.50) /* 1 trial, p=.50 */

drop fakefem
    
/*Binary variable correlated with a continous variable */

mat mymat=J(5,5,.7) /*Creates a diagonal matrix with .7 */
mat mymat[1,1]=1 /*Replace the first row, first column with 1 */
mat mymat[2,2]=1
mat mymat[3,3]=1
mat mymat[4,4]=1
mat mymat[5,5]=1

mat li cormat
    
drawnorm a b c d f, corr(mymat) n(`popsize')

drop a b c d f

/*Hypothetical structure for omitted variables*/

mat newcol=(0.01\.5\-.2\.5\.5) /*Adds a column */

mat cormat2=cormat,newcol

mat cormat2=cormat2\0.01,.5,-.2,.5,.5,1 /*Adds a row */

mat li cormat2

corr2data female_st plans_st race_st pared_st ses counsel_st, corr(cormat2) n(`popsize')

/*Specify cut in normal dist for proportion with and without characteristics*/

gen femcut=invnormal(`prop_fem')    
gen female=female_st>femcut

gen paredcut=invnormal(`prop_pared')
gen pared= pared_st>paredcut 

gen plancut=invnormal(`prop_plans') 
gen plans=plans_st>plancut 

local race_other=1-`prop_race'

gen racecut=invnormal(`race_other') 
gen race=race_st>racecut 

local prop_counsel=.95
    
gen counselcut=invnormal(`prop_counsel') 
gen counsel=counsel_st>counselcut

mat li cormat

corr female plans race pared ses


drawnorm e, sds(11)

local effect 2

gen y=`int'+(`fem_coeff'*female)+(`plans_coeff'*plans)+(`race_coeff'*race)+(`pared_coeff'*pared)+(`ses_coeff'*ses) + (`effect'*counsel)+e

keep y female plans race pared ses counsel e

preserve

sample 10

reg y female plans race pared ses counsel /* True regression */

reg y female plans race pared ses /*OVB regression */

restore


/*Monte Carlo Study */

drop y

local effect 10 /* Size of the effect of counseling, can vary with each iteration */

gen y=`int'+(`fem_coeff'*female)+(`plans_coeff'*plans)+(`race_coeff'*race)+(`pared_coeff'*pared)+(`ses_coeff'*ses) + (`effect'*counsel)+e
    
save counsel_universe_`effect', replace

tempname results_store
postfile `results_store' plans1 plans2  using results_file, replace
local j=1  
while `j'<=100{  

use counsel_universe_`effect',clear  
  
quietly sample 10

quietly reg y female plans race pared ses counsel /* True regression */

scalar plans1=_b[plans]

 /*Pulls coefficient, puts it into scalar */
quietly reg y female plans race pared ses /*OVB regression */

scalar plans2=_b[plans]

post `results_store' (plans1) (plans2)

di "Finishing iteration `j'"

local j=`j'+1
}
postclose `results_store'

use results_file, clear

kdensity plans1, xline(`plans_coeff', lcolor(blue) lstyle(dash)) /// 
addplot(kdensity plans2) legend(order(1 "True Model" 2 "OVB Model"))


/*Now vary effect size*/

local effect_size 5 10 15 20

foreach effect of local effect_size{

use counsel_universe_10, replace
    
drop y

gen y=`int'+(`fem_coeff'*female)+(`plans_coeff'*plans)+(`race_coeff'*race)+(`pared_coeff'*pared)+(`ses_coeff'*ses) + (`effect'*counsel)+e
    
save counsel_universe_`effect', replace

tempname results_store
postfile `results_store' plans1 plans2  using results_file_`effect', replace
local j=1  
while `j'<=100{  

use counsel_universe_`effect',clear  
  
quietly sample 10

quietly reg y female plans race pared ses counsel /*True model */

scalar plans1=_b[plans]

 /*Pulls coefficient, puts it into scalar */
quietly reg y female plans race pared ses /*OVB model*/

scalar plans2=_b[plans]

post `results_store' (plans1) (plans2)

di "Finishing iteration `j'"

local j=`j'+1
}

postclose `results_store'

use results_file_`effect', clear

kdensity plans1, xline(`plans_coeff', lcolor(black) lpattern(dash)) ///
	addplot(kdensity plans2,note("")) ///
	legend(order(1 "True Model" 2 "OVB Model")) ///
	xtitle("Coefficients for Plan") ///
	title("Coefficient for Counseling=`effect'") ///
	note("")

graph save monte_carlo_`effect'.gph, replace

}

/* Ends loop over effect sizes */

grc1leg monte_carlo_5.gph monte_carlo_10.gph monte_carlo_15.gph monte_carlo_20.gph , rows(2) cols(2)
}


 
/*Quick-ish Exercise Create a variable for the unobserved characteristic
 of motivation (oh fine, grit) which is uncorrelated with other variables
 in the model, except for plans. Loop through a series of correlations with plans
 of .1, .25, .5, and .75. Assume it's normally distributed, and set it to be
 standardized (mean 0 sd 1). Change its impact on math scores to range from
 1 to 10. What happens to your estimate of plans when this variable is excluded? 
 */
 
exit
