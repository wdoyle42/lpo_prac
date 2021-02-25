/***
Using Prediction to Understand Regression
=====================
LPO 9952
======================



Too often, analysts consider the analysis done when they’ve run a regression and then re- ported some tables. You should consider reporting your parameter estimates as the start of your report, not the end. In particular, you should think about what your results predict. The point of almost all policy analysis is to predict what would happen to the dependent variable if the independent variable changed. This is the essence of prediction.

You’ll want to use prediction for several different purposes, each of which we’ll go through.

* To show how well the model predicts the data used to estimate parameters

* To make out-ofsample predictions using the regression line

* To forecast results for individuals in sample

* To forecast results for individuals out of sample

## A bit of theory

The standard estimated equation is:

$$  \hat{y}=\hat{\beta}_0+\hat{\beta}_1 x_1+ \hat{\beta}_2 x_2 \ldots \hat{\beta}_k x_k$$


Our parameter for the prediction is $\theta$:

$$ 
\begin{aligned}
\theta_0&=\beta_0+\beta_1 c_1+ \beta_2 c_2 \ldots +\beta_k c_k 
         &=E(y|x_1=c_1,x_2=c_2 . . .x_k=c_k) 
\end{aligned}		 
$$
		 

The estimate of $\theta$ is therefore


$$ \hat{\theta_0}=\hat{\beta_0}+\hat{\beta_1} c_1+ \hat{\beta_2} c_2 \ldots  \hat{\beta_k} c_k   $$


Of course, $\theta_0$ is not measured without error. Instead, we need
to make use of the uncertainty surrounding our estimates
$\hat{\beta}_k$ which go into the estimate. 

To accomplish this, we can plug the definition of $\beta_0$ from above
into the population model: 

$$ \beta_0=\theta_0-\beta_1 c_1- \beta_2 c_2 \ldots  -\beta_k c_k  $$

$$
\begin{aligned}
  y&=\beta_0+\beta_1 x_1+ \beta_2 x_2 \ldots \beta_k x_k+u\\
   &=\theta_0-\beta_1 c_1- \beta_2 c_2 \ldots  \beta_k c_k +\beta_1x_1+ \\ &\beta_2 x_2 \ldots \beta_k x_k\\
   &=\theta_0 +\beta_1(x_1-c_1)+\beta_2(x_2-c_2) \ldots +\beta_2(x_k-c_k)
\end{aligned}   
$$


In effect, we subtract the specific values $c_j$ from each value of
$x_j$ and regress $y_i$ on the result, we'll get a set of estimates
where the intercept and error term are the predicted value of $y$ for
the linear combination of values of $x_j$ contained in $x_c$


		 
***/

/***
## Predicting data in sample

We're using the `caschool.dta` data again. We'll run two
regressions, a basic one with no controls showing the impact of
student teacher ratios on math test scores, then another again
estimating the relationship after controlling for other
characteristics of the school districts. 

***/

version 14
capture log close
log using "reg_predictlog",replace

/* PhD Practicum, Spring 2018 */
/* Using Prediction to Interpret Regressions */
/* Will Doyle*/
/* 2/25/21 */

clear

clear mata

clear matrix

estimates clear

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
local first_part=0
local second_part=1

// DV
local y math_scr

// Key IV
local x str

// Controls
local controls  expn_stu_t avginc el_pct meal_pct comp_stu

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
esttab * using my_models.rtf,          /* estout command: * indicates all estimates in memory. csv specifies comma sep, best for excel */
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


/***


What we want to do is to first show the overall relationship between
student teacher ratios and test scores and to indicate our uncertainty
for the regression line. This is when prediction comes in handy. 

***/

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



/***

Remember that the prediction interval does not tell us where we can
expect any individual unit to be located. Instead, the prediction
interval tells us the likely range of \emph{lines} that would be
generated in repeated samples. 

***/

/***
## Hypothetical Values


Many times, we'd also like to think about how the dependent variable
would increase or decrease as a function of hypothetical values of x.
Using only Stata's `predict`' command, we're stuck with just
using the data in memory. The `margins` command can help us to
make predictions for hypothetical values of the independent variable. 

There are two steps to using margins. First, we need to generate
values of $\hat{y}$ across levels of x, then we need to generate the
standard error of $\hat{y}$ across those same levels of x. With those
estimates in hand, we can save them in memory and plot them. 

***/

/*Making use of the margins command*/

// Use summary to get min and max of key IV    
sum `x', detail

local mymin=r(min)
local mymax=r(max)
local n_steps=100
local diff =`mymax'-`mymin'
local step=`diff'/`n_steps'

estimates restore basic_controls

local dfr=e(df_r)

#delimit ;
margins , /* init margins */
    predict(xb) /* Type of prediction */
    nose /* Don't give SE */
    at( (mean) /* Prediction at mean of all variables */
    `controls' /* Set controls at mean */
    `x'=(`mymin'(`step')`mymax'))  /*range from min to max of x in steps of .1 */
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
margins , predict(stdp) nose at(`x'=(`mymin'(`step')`mymax') (mean) `controls') post

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
    `x'=(`mymin'(`step')`mymax'))  /*range from min to max of x in steps of .1 */
     post  /* Post results in matrix form */
         ;
#delimit cr

marginsplot , recast(line) plotopts(lcolor(black)) ///
				recastci(rarea) ciopts(lcolor(0) fcolor(blue%50)) ///
				name(preferred, replace)

marginsplot ,name(definitely_not_preferred, replace)

}/* End first part */

if `second_part'==1{

/***

## Forecasting

Forecasting is distinct from prediction in the parlance of
regression. The prediction interval is all about how different the
regression line is likely to be in repeated samples. The forecast
interval is all about how well the model predicts the location of
individual points. A 95\% confidence interval around the regression
line says: ``In 95 percent of repeated samples, an interval calculated
in this way will include the true value of the regression line.'' A
95\% forecast interval around the regression line says ``In 95 percent
of repeated samples, an interval calculated in this way will include
all but 5 percent of observations.'' 

The process for generating these lines is very similar to the one we
just went through, with the exception that we'll be using
\texttt{stdf}, the standard error of the forecast, as opposed to
\texttt{stdp}, the standard error of the prediction. 

Here's what the forecast interval looks like for us, when predicting
using available data:

***/


/*Prediction vs. forecasting*/

//drop yhat* *ci
             
    
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

/***

With hypothetical data, we're forecasting out of range, and so the
intervals are going to be quite wide. 

***/


/*Then with margins */ 

sum `x', detail
    
local mymin=r(min)
local mymax=r(max)
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

//drop lb ub

generate lb = pred12 - (`myt' * pred11) /*Prediction minus t value times SE */
generate ub = pred12 +  (`myt' * pred11) /*Prediction plus t value times SE */


estimates restore basic_controls


/*Plot Prediction with CI*/
    
graph twoway line pred12 pred13 || ///
    line lb pred13,lcolor(red) || ///
    line ub pred13,lcolor(red) ///
    xtitle("Hypothetical Values of Student-Teacher Ratio") ///
    ytitle("Predicted Values of Math Test Scores") ///
    legend(order(1 "Predicted Value" 2 "Lower/Upper Bound 95% CI" )) ///
    name(ci_predict95_b)

graph export ci_predict95_forecast.`gtype', replace 
  

#delimit ;
margins , /* init margins */
    predict(xb) /* Type of prediction */
    at( (mean) /* Prediction at mean of all variables */
    `controls' /* Set controls at mean */
    `x'=(`mymin'(`step')`mymax'))  /*range from min to max of x in steps of .1 */
     post  /* Post results in matrix form */
         ;
#delimit cr

marginsplot , recast(line) plotopts(lcolor(black)) recastci(rarea) ///
				ciopts(fcolor(blue%25))  name(forecast_interval, replace) ///
				addplot(line lb ub pred13, lcolor(yellow%25))

   
  
  exit 
/***

The point is that we should approach these results with some
humility. Too often, we don't take forecast intervals very
seriously. Predictions are made on ``average'' using the conditional
expectation function. If you're going to forecast for an individual
unit--- a person, a school, a state--- you need to acknowledge that
the uncertainty is likely to be large. 

***/	
	
} /* End part 2 */
