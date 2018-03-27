capture log close
log using "logistic.log",replace

/* PhD Practicum, Spring 2018 */
/* Regression models for binary data*/
/* Will Doyle*/
/* 3/16/18 */

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


/* Set locals */

local y f2evratt

local ses byses1

local demog amind asian black hispanic multiracial bysex

local tests bynels2m bynels2r

local gtype pdf

/* Linear Probability Model */

reg `y' `ses' `demog' `tests'

graph twoway scatter `y' `ses' , msize(tiny) 

predict e, resid

// Scatterplot of residuaals: holy heteroscedastic
graph twoway scatter  `ses' e, msize(tiny)

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
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///
      post

// Grab results for plotting    

// Predicted values
mat yhat=e(b)

mat li yhat

mat yhat=yhat'

// Key independent variable
mat allx=e(at)

mat myx=allx[1...,1]

//put key iv in memory
svmat myx


// Put predicted values in memory
svmat yhat, names("yhat_lpm")

// Plot results
graph twoway line yhat_lpm myx1, name("LPM") ytitle("Pr(Attend)") xtitle("SES") 

graph export lpm.pdf, replace name("LPM")

/*Logistic Function*/

graph drop _all

local k=.25 /*Scale*/
local x0=0 /*Location*/

graph twoway function y=1/(1+exp((-`k')*(x-`x0'))),range(-2 2) name("Logit")

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

margins, dydx(*) /*for all coefficients, default is to hold others at mean */

/*Margins for range of ses */

estimates restore full_model
    
margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///
      post

// Get predictions    
mat yhat=e(b)

mat yhat=yhat'

svmat yhat, names(yhat_logit)

graph twoway line yhat_lpm yhat_logit myx1, ///
    name("Logistic") ///
    ytitle("Pr(Attend)") ///
    xtitle("SES") ///
    legend(order(1 "LPM" 2 "Logit") )

estimates restore full_model
	  
graph export logit_basic.pdf, replace name("Logistic")

drop yhat_*

// What about marginsplot? <sigh> <eyeroll>    

estimates restore full_model

margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///
           post

marginsplot, recastci(rarea) recast(line)

// By Math scores

logit `y' bynels2m

predict yhat, pr

graph twoway line yhat bynels2m
    	
drop yhat
		
/* Margins for range of ses, all races */

foreach myrace of local race{
drop myx1

estimates restore full_model

margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///
        `myrace'=1 ///
       ) ///
      post
    
mat yhat=e(b)

mat yhat=yhat'

svmat yhat, names("yhat_`myrace'")

// Key independent variable
mat allx=e(at)

mat myx=allx[1...,1]

//put key iv in memory
svmat myx

}

graph twoway line yhat_* myx, ///
    name("All_Races") ///
    ytitle("Pr(Attend)") ///
    xtitle("SES") ///
    legend(order(1 "Native American" ///
    2 "Asian" ///
    3 "Black" ///
    4 "Hispanic" ///
    5 "Multiracial") )
    
graph export logit_race.pdf, replace name("All_Races")

estimates restore full_model

drop yhat_*

/* Margins for range of ses, all races */
sum bynels2m, detail 

foreach myscore of num 35(10)55{

drop myx1

estimates restore full_model

margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///
		bysex=2 ///
        bynels2m=`myscore' ///
       ) ///
      post
    
mat yhat=e(b)

mat yhat=yhat'

svmat yhat, names("yhat_`myscore'")

// Key independent variable
mat allx=e(at)

mat myx=allx[1...,1]

//put key iv in memory
svmat myx

}

graph twoway line yhat_* myx, ///
    name("test_scores") ///
    ytitle("Pr(Attend)") ///
    xtitle("SES") ///
    legend(order(1 "Low Math Scores" ///
    2 "Median Test Scores" ///
    3 "High Test Scores"))
 
exit 
// Other functions

listcoef /*Display odds ratios from model in memory */

listcoef, reverse /* Reveres interpretation, helps with negative coefs */

logistic `y' `ses' `demog' `tests'  /*Works too */
  
estimates restore full_model

/* Measures of model fit: all imperfect */

// Built in methods

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
