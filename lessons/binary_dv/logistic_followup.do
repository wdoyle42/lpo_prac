capture log close
log using "logistic.log",replace

/* PhD Practicum, Spring 2017 */
/* Regression models for binary data*/
/* Will Doyle*/
/* 3/28/17 */

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

local demog  amind asian black hispanic multiracial bysex

local tests bynels2m bynels2r

local gtype pdf

/* Linear Probability Model */

reg `y' `ses' `demog' `tests'

graph twoway scatter `y' `ses' , msize(tiny) 

predict e, resid

graph twoway scatter  `ses' e, msize(tiny)

reg `y' `ses' `demog' `tests', vce(robust)

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

    
mat yhat=e(b)

mat li yhat

mat yhat=yhat'

mat allx=e(at)

mat li allx

mat myx=allx[1...,1]

svmat yhat, names("yhat_lpm")

svmat myx

graph twoway line yhat_lpm myx1, name("LPM") ytitle("Pr(Attend)") xtitle("SES") 

graph export lpm.pdf, replace name("LPM")
 
/*Logistic Function*/

graph drop _all

local k=.25 /*Scale*/
local x0=0 /*Location*/

graph twoway function y=1/(1+exp((-`k')*(x-`x0'))),range(-2 2) name("Logit")
 
/*Logistic Regression */

glm `y' `ses' `demog' `tests', family(binomial) link(logit) /*Logit model */

glm `y' `ses' `demog' `tests', family(binomial) link(probit) /*Probit Model */

logit `y' `ses' `demog' `tests' /*Simpler version of logit model */

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

marginsplot, recastci(rarea) recast(line)		  
    
mat yhat=e(b)

mat yhat=yhat'

svmat yhat, names(yhat_logit)

graph twoway line yhat_lpm yhat_logit myx1, ///
    name("Logistic") ///
    ytitle("Pr(Attend)") ///
    xtitle("SES") ///
    legend(order(1 "LPM" 2 "Logit") )

	
estimates restore full_model
    
    
margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(-1(1)1) ///          
       ) ///
      post
	  
	  
local x bynels2m 

sum `x', detail

local no_steps=20

local mymin=r(min)
local mymax=r(max)
local diff=`mymax'-`mymin'
local step=`diff'/`no_steps'

estimates restore full_model
    
margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///
      post

marginsplot, recastci(rarea) recast(line)	  

	  
mat yhat=e(b)

mat li yhat

mat yhat=yhat'

mat allx=e(at)

mat li allx

mat myx=allx[1...,8]

svmat yhat, names("yhat_math")

svmat myx,names("myx_math") 

graph twoway line yhat_math myx_math,  ytitle("Pr(Attend)") xtitle("NELS Math Score") 	  
	  
graph export logit_basic.pdf, replace name("Logistic")

drop yhat_*

    estimates restore full_model


margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///
           post

marginsplot, recastci(rarea) recast(line)
    
/* Margins for range of ses, all races */

foreach myrace of local race{

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
    
}

estimates restore full_model

margins , predict(pr) ///
    at((mean) _continuous ///
        (min) `demog' ///
        `x'=(`mymin'(`step')`mymax') ///
       ) ///
      post

    
mat yhat=e(b)

mat yhat=yhat'

svmat yhat, names("yhat_white")



graph twoway line yhat_* myx1, ///
    name("All_Races") ///
    ytitle("Pr(Attend)") ///
    xtitle("SES") ///
    legend(order(1 "Native American" ///
    2 "Asian" ///
    3 "Black" ///
    4 "Hispanic" ///
    5 "Multiracial" ///
	6 "White") )

    
graph export logit_race.pdf, replace name("All_Races")

estimates restore full_model

listcoef /*Display odds ratios from model in memory */

listcoef, reverse /* Reveres interpretation, helps with negative coefs */

logistic `y' `ses' `demog' `tests'  /*Works too */
     
estimates restore full_model

/* Measures of model fit: all imperfect */

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
