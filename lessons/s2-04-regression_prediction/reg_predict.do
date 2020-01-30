version 14
capture log close
log using "reg_predictlog",replace

/* PhD Practicum, Spring 2018 */
/* Using Prediction to Interpret Regressions */
/* Will Doyle*/
/* 1/30/20 */

clear

clear mata

clear matrix

estimates clear

graph set ps logo off

graph drop _all

set scheme s1color

set more off

global gdir "../../data/"

use ${gdir}caschool, clear

/*******************************/
/*Recoding */
/*******************************/  

/*Changing Scale of Expenditures*/

gen  expn_stu_t=expn_stu/1000

save caschool_new, replace

/******************************/
/*Variable Labels */
/******************************/

label variable math_scr "Math Scores"
label variable str "Student Teacher Ratio"
label variable expn_stu_t "Expenditures per Student (1000s)"
label variable avginc "Average Income"
label variable el_pct "English Language Percent"
label variable meal_pct "Percent on Free/Reduced Meals"
label variable comp_stu "Computers per Student"

/**************************************************/
/* Locals */
/**************************************************/

//Graphics typae
local gtype pdf /*For Mac*/

//Bookmarks    
local first_part=1
local second_part=1

// DV
local y math_scr

// Key IV
local x str

// Controls
local controls expn_stu_t avginc el_pct meal_pct comp_stu

//alpha

local alpha=.05

local alpha_a=.1

//How many tails? TWO!

local alpha_2=`alpha'/2

local alpha_2a=`alpha_a'/2

/*******************************/  
/* Analysis */
/*******************************/    

reg `y' `x'

eststo  basic

reg `y' `x' `controls'

eststo basic_controls

#delimit ;
quietly esttab * using my_models.tex,          /* estout command: * indicates all estimates in memory. csv specifies comma sep, best for excel */
               label                          /*Use labels for models and variables */
               nodepvars                      /* Use my model titles */
               b(2)                           /* b= coefficients , this gives two sig digits */
               not                            /* I don't want t statistics */
               se(2)                         /* I do want standard errors */
               nostar                       /* No stars */
               r2 (2)                      /* R squared */
               ar2 (2)                     /* Adj R squared */
               scalar(F  "df_m D.F. Model" "df_r D.F. Residual" N)   /* select stats from the ereturn (list) */
               sfmt (2 0 0 0)               /* format for stats*/
               replace                   /* replace existing file */
               nomtitles
               ;
#delimit cr

local df_r=e(df_r)

//Get correct t value
local myt=invttail(`df_r',`alpha_2')

scalar myt=`myt'

local myt2=invttail(`df_r',`alpha_2a')
scalar myt2=`myt2'

if `first_part'==1{

estimates restore basic

// Predict using data in memory
predict yhat, xb

//Get SE of prediction
predict yhat_se,stdp

// Generate Prediction interval 
gen low_ci=yhat-(`myt'*yhat_se)
gen hi_ci=yhat+(`myt'*yhat_se)

gen low_ci_90=yhat-(`myt2'*yhat_se)
gen hi_ci_90=yhat+(`myt2'*yhat_se)


sort `x'

graph twoway scatter `y' `x',msize(small) mcolor(blue)  ///
  || line yhat `x',lcolor(red) ///
  || line low_ci `x', lcolor(red) lpattern(dash) ///
  || line hi_ci `x', lcolor(red) lpattern(dash) ///
  || line low_ci_90 `x', lcolor(yellow) lpattern(dash) ///
  || line hi_ci_90 `x', lcolor(yellow) lpattern(dash) ///
      legend( order(1 "Math score" 2 "Prediction" 3 "95% Confidence Interval" 5 "90% Confidence Interval")) ///
      name(basic_predict)

graph export basic_predict.`gtype', replace

/*Making use of the margins command*/

// Use summary to get min and max of key IV    
sum `x', detail

local mymin=r(min)
local mymax=r(max)

estimates restore basic_controls

local dfr=e(df_r)

#delimit ;
margins , /* init margins */
    predict(xb) /* Type of prediction */
    nose /* Don't give SE */
    at( (mean) /* Prediction at mean of all variables */
    `controls' /* Set controls at mean */
    `x'=(`mymin'(.1)`mymax'))  /*range from min to max of x in steps of .1 */
     post  /* Post results in matrix form */
         ;
#delimit cr

// Pull results
mat xb=e(b)

// store x values used to generate predictions
mat allx=e(at)

// store just x values from that matrix
matrix myx=allx[1...,1]'

// Bring back in regression results
estimates restore basic_controls

// Run margins again, but this time get standard error of prediction as output
margins , predict(stdp) nose at(`x'=(`mymin'(.1)`mymax') (mean) `controls') post

//Grab standard error of prediction
mat stdp=e(b)

//Put three matrices together: standard error, prediction, and values of x: transpose 
mat pred1=[stdp \ xb\ myx]'

//Put matrix in data 
svmat pred1

//Generate
generate lb = pred12 - (`myt' * pred11) /*Prediction minus t value times SE */
generate ub = pred12 + (`myt'* pred11) /*Prediction plus t value times SE */

/*Plot Simple Prediction */

graph twoway line pred12 pred13, ///
    xtitle("Hypothetical Values of Student-Teacher Ratio") ///
    ytitle("Predicted Values of Math Test Scores") ///
    name(basic_predict_margins)

graph export basic_predict.`gtype', replace 

/*Plot Prediction with CI*/

graph twoway line pred12 pred13 || ///
    line lb pred13,lcolor(red) || ///
    line ub pred13,lcolor(red) ///
    xtitle("Hypothetical Values of Student Teacher Ratio ") ///
    ytitle("Predicted Values of Math Test Scores") ///
    legend(order(1 "Predicted Value" 2 "Lower/Upper Bound 95% CI" )) ///
    name(ci_predict95) 

graph export ci_predict95.`gtype', replace 

drop pred11 pred12 pred13

/*Or: Marginsplot */

estimates restore basic_controls

local dfr=e(df_r)

#delimit ;
margins , /* init margins */
    predict(xb) /* Type of prediction */
    at( (mean) /* Precition at mean of all variables */
    `controls' /* Set controls at mean */
    `x'=(`mymin'(.1)`mymax'))  /*range from min to max of x in steps of .1 */
     post  /* Post results in matrix form */
         ;
#delimit cr

marginsplot , recast(line) plotopts(lcolor(black)) recastci(rarea)  

}/* End first part */

if `second_part'==1{

/*Prediction vs. forecasting*/

    drop yhat* *ci
             
    
estimates restore basic
predict yhat, xb
predict yhat_se,stdp
predict yhat_fse,stdf

gen low_ci=yhat-(myt*yhat_se)
gen hi_ci=yhat+(myt*yhat_se)

gen low_ci_f=yhat-(myt*yhat_fse)
gen hi_ci_f=yhat+(myt*yhat_fse)

sort `x'

graph twoway scatter `y' `x',msize(small) mcolor(blue)  ///
  || line yhat `x',lcolor(red) ///
  || line low_ci `x', lcolor(red) lpattern(dash) ///
  || line hi_ci `x', lcolor(red) lpattern(dash) ///
  || line low_ci_f `x', lcolor(green) lpattern(dash) ///
  || line hi_ci_f `x', lcolor(green) lpattern (dash) ///
    legend( order(1 "Math score" 2 "Prediction" 3 "95% Confidence Interval, Prediction" 5 "95% Confidence Interval, Forecast"))

graph export predictvforecast.`gtype', replace

gen outside=`y' < low_ci_f | `y' >hi_ci_f

egen total_out=sum(outside)

sum total_out

scalar my_out=r(mean)

scalar myn=_N

scalar pct_out=my_out/myn

scalar li pct_out

estimates restore basic_controls

/*Then with margins */ 

sum `x', detail
    
local mymin=0
local mymax=100
local diff=`mymax'-`mymin'
local step=`diff'/100

estimates restore basic_controls

local dfr=e(df_r)

// All of this, same as before

margins , predict(xb) nose at( (mean) `controls' `x'=(`mymin'(`step')`mymax')) post

mat xb=e(b)

mat allx=e(at)

matrix myx=allx[1...,1]'

estimates restore basic_controls

//But now instead of stdp use stdf for forecast

margins , predict(stdf) nose at(`x'=(`mymin'(`step')`mymax') (mean) `controls') post

mat stdf=e(b)

mat pred1=[stdf \ xb\ myx]'

svmat pred1

generate lb = pred12 - (`myt' * pred11) /*Prediction minus t value times SE */
generate ub = pred12 +  (`myt' * pred11) /*Prediction plus t value times SE */

/*Plot Prediction with CI*/
    
graph twoway line pred12 pred13 || ///
    line lb pred13,lcolor(red) || ///
    line ub pred13,lcolor(red) ///
    xtitle("Hypothetical Values of Student-Teacher Ratio") ///
    ytitle("Predicted Values of Math Test Scores") ///
    legend(order(1 "Predicted Value" 2 "Lower/Upper Bound 95% CI" )) ///
    name(ci_predict95)

graph export ci_predict95_forecast.`gtype', replace 
    
} /* End part 2 */
