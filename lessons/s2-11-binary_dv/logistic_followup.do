capture log close
log using "logistic.log",replace

/* PhD Practicum, Spring 2020 */
/* Regression models for binary data*/
/* Will Doyle*/
/* 2021-04-22 */

clear

set more off

set scheme s1color

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
 

recode byrace (1=1 "Native American") ///
				(2=2 "Asian/ Pacific Islander") ///
				(3=3 "African-American") ///
				(4/5=4 "Hispanic") ///
				(6=5 "Multiracial") ///				
				(7=6 "White"), ///
gen(byrace2) 

recode bysex (1=0 "Non-Female") ///
			  (2=1 "Female"), ///
			  gen(female)


/* Set locals */

local y f2evratt

local ses byses1

local demog ib(freq).byrace2 ib(freq).female

local tests bynels2m bynels2r

local gtype pdf

/* Linear Probability Model */

reg `y' `ses' `demog' `tests'

graph twoway (scatter `y' `ses',jitter(.1)   msize(tiny) ) ///
			(lfit `y' `ses' )


			
predict e, resid

graph twoway scatter e byses1


// Can always use robust ses
reg `y' `ses' `demog' `tests', vce(robust)

// Save this for later
estimates store lpm


/* Generate predicted probabilites over range of ses*/

local x byses1

sum `x', detail

local no_steps=20

local mymin=r(min)
local mymax=r(max)
local diff=`mymax'-`mymin'
local step=`diff'/`no_steps'
    
margins , predict(xb) ///
    at((mean) _continuous ///
        (base) _factor ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///
      post

// Grab results for plotting    

marginsplot, name("uninspired")

marginsplot, recastci(rarea) ciopts(color(gray%10)) ///
			recast(line)  plotopts(color(blue)) ///
			xlabel(-2(.3)2) xtitle("SES") ytitle(Linear Prediction) title("") name(LPM)

			
graph export lpm.pdf, replace name("LPM")



/*Logistic Function*/

graph drop _all

local k=.25 /*Scale*/
local x0=0 /*Location*/


graph twoway function y=-log(1/x-1) ,range(0 1) xtitle("P") ytitle("Logit(p)")


/*Logistic Regression */

// Most general: glm
glm `y' `ses' `demog' `tests', family(binomial) link(logit) /*Logit model */

// Can also use probit, uses cdf of normal dist    
glm `y' `ses' `demog' `tests', family(binomial) link(probit) /*Probit Model */

// Simpler version of logit model 
logit `y' `ses' `demog' `tests' 

est store full_model

gen mysample=e(sample)

/* Generating marginal effects */

estimates restore full_model

margins, dydx(*) /*for all coefficients, default is to hold others at mean */

/*Margins for range of ses */

estimates restore full_model

margins , predict(pr) ///
    at((mean) _continuous ///
        (base) _factor ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///
      post
	  
//Marginsplot


marginsplot, recastci(rarea) ciopts(color(gray%10)) ///
			recast(line)  plotopts(color(blue)) ///
xlabel(-2(.3)2) xtitle("SES") ytitle(Linear Prediction) title("") name("logit_basic")


			
graph export logit_basic.pdf, replace name("logit_basic")

    
/* Margins for range of ses, all races */

estimates restore full_model

quietly margins , predict(pr) ///
    at((mean) _continuous ///
        (base) _factor ///
        `x'=(`mymin'(`step')`mymax') ///
        byrace2=(1(1)6) ///
       ) ///
      post


marginsplot, recastci(rarea) ciopts(color(%10)) ///
				recast(line) ///
              xlabel(-2(.3)2) xtitle("SES") ytitle("Pr(Attend)") title("") ///
              name("logit_race")
			  
			
graph export logit_race.pdf, replace name("logit_race")
	
estimates restore full_model			

quietly margins , predict(pr) ///
    at((mean) _continuous ///
        (base) _factor ///
        `x'=(`mymin'(`step')`mymax') ///
        byrace2=(3 4 6) ///
       ) ///
      post


marginsplot, recastci(rarea) ciopts(color(%10)) ///
				recast(line) ///
				xlabel(-2(.3)2) xtitle("SES") ytitle(Linear Prediction) title("") ///
				legend(cols(1))

				
	
estimates restore full_model	

	  
local x byses1

sum `x', detail

local no_steps=20

local mymin=r(min)
local mymax=r(max)
local diff=`mymax'-`mymin'
local step=`diff'/`no_steps'
    

sum bynels2r, detail	

local lo_test=r(p25)	

local mid_test=r(p50)

local hi_test=r(p75)

quietly margins , predict(pr) ///
    at((mean) _continuous ///
        (base) _factor ///
        `x'=(`mymin'(`step')`mymax') ///
		bynels2r=(`lo_test' `mid_test' `hi_test') ///
       ) ///
      post

	  
/*
estimates restore full_model


quietly margins , predict(pr) ///
    at((mean) _continuous ///
        (base) _factor ///
        `x'=(`mymin'(`step')`mymax') ///
		bynels2r=(p25 p50 p75) ///
       ) ///
      post
*/
	
	
marginsplot, recastci(rarea) ciopts(color(%10)) ///
				recast(line) ///
				xlabel(-2(.3)2) xtitle("SES") ytitle(Linear Prediction) title("") ///
				legend(cols(1))
	
				
				
// Another option
/*
estimates restore full_model

marginscontplot2 byses1, at1(-2(.2)2) ci				

mcp2 byses1, at1(-2(.1)2) ci

mcp2 byses1 byrace2, at1(-2(.1)2) ci				
*/

// Other functions

estimates restore full_model

// What are odds ratios (Q:would we ever care A:NO)?

mean f2evratt,over(female)

mat results=e(b)

scalar attend_not_female=results[1,1]

scalar not_attend_not_female=1-attend_not_female

scalar odds_not_female=attend_not_female/not_attend_not_female


scalar attend_female=results[1,2]

scalar not_attend_female=1-attend_female

scalar odds_female=attend_female/not_attend_female

scalar li odds_not_female odds_female


scalar or_female=odds_female/odds_not_female

scalar li or_female

logistic f2evratt female


logit f2evratt female


/* QE: or for parent with a bachelor's degree */


listcoef /*Display odds ratios from model in memory */

logistic `y' `ses' `demog' `tests'  /*Works too */

 
/* Measures of model fit: all imperfect */

// Built in methods

estimates restore full_model

fitstat

/* Likelihood ratio test for nested models */
quietly logit `y' `ses' if mysample==1

est store ses

lrtest full_model ses

quietly logit `y'  `demog' if mysample==1

est store demog

lrtest full_model demog

quietly logit `y' `tests' if mysample==1

est store tests

lrtest full_model tests

estimates restore full_model


/* Percent Correctly Predicted  */

estat classification

// Sensitivity/Specificity trafeoff

estimates restore full_model

lsens, genprob(pr) genspec(spec) gensens(sens) replace

browse pr spec sens

/*Area under Receiver/Operator Characteristic Curve */

lroc, name("lroc1")

/*comparing two models */

est restore ses

predict xb_ses, xb

est restore full_model

predict xb_full, xb
 
roccomp f2evratt xb_full xb_ses, graph summary name("roc2")

graph export roc_curve.pdf , replace name("roc2")  ///

exit
