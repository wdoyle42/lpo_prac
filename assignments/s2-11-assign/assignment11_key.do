capture log close 

version 14 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */
log using "panel.log", replace

graph drop _all

/* Binary outcomes */
/* Assignment 11 follow up*/
/* Will Doyle */
/* 2018-03-25 */
/* Practicum Folder */


/* Use the Mroz data to answer the following questions about female employment. */

use ../../data/mroz.dta, clear

tab inlf

tab inlf kidslt6, row

local y inlf

local x c.educ

local w_chars age repwage exper

local h_chars c.huswage

local kids kidslt6 kidsge6

/* 1. Run a logit model predicting labor force participation based on characteristics of the woman and of the children. */


eststo basic_model:logit `y' `x' `w_chars' `h_chars' `kids'
                                            

/* 1. Generate the marginal effects for all of the variables, holding other predictors at their means. */

estimates restore basic_model

margins, dydx(*)


/* 1. In comments in the do file, explain why the estimates of an independent variable’s relationship to the outcome are not constant across population. */



/* 1. Generate the predicted probability of working for a range of mother’s years of education. Create a plot or table for these predicted probabilities. */

sum `x', detail

local mymin=r(min)
local mymax=r(max)
local step=1

estimates restore basic_model


margins , predict(pr) ///
    at((mean) _continuous ///
              kidslt6=1 ///
       kidsge6=1 ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) ///

    
marginsplot, recastci(rarea) recast(line)
    

/* 1. Generated the predicted probability of working for range of mother’s years of education interacted with husband’s wage. Create a plot or table to explain the relationship you observe. */

eststo int_model:logit `y' `x' `x'#`h_chars' `w_chars' `kids'

sum huswage, detail

local huswages 4.8 7 9.2
local j 1

foreach wagelevel of local huswages{

estimates restore int_model
    
margins , predict(pr) ///
    at((mean) _continuous ///
         kidslt6=1 ///
         kidsge6=1 ///
         huswage=`wagelevel' ///
        `x'=(`mymin'(`step')`mymax') ///          
       ) post 


    mat yhat=e(b)'

    svmat yhat,names(pred`j')

    if `j'==1{
        mat allx=e(at)
        mat myx=allx[1...,1]
        svmat myx
        }

    mat drop yhat
    
    local j=`j'+1
}

graph twoway line pred* myx , ///
    xtitle("Woman's Years of Education") ///
    ytitle("Pr(in Labor Force)") ///
    legend(order( 1 "Husband w/ Low Wage" 2 "Husband Median Wage" 3 "Husband High Wage"))




/* 1. Does including characteristics related to the husband’s education significantly increase model fit from your preferred model? Compare predictions of these two models graphically using the ROC. */

eststo full_model:logit `y' `x' `x'#`h_chars' `w_chars' `kids' huseduc  


est restore int_model

predict xb_int, xb

est restore full_model

predict xb_full, xb
 
roccomp inlf xb_full xb_int, graph summary name("roc2")


exit
