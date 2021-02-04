/***
Basics of Regression in Stata
================
LPO 9952 | Spring 2021

Intro
-----

Stata was made for regression. It has the most advanced suite of regression functions and the easiest to use interface of any statistical programming environment. This session will get you started with how to estimate parameters for the simple regression model in STATA.

We'll be using data from the National Longitudinal Survey of Youth, 1997. For more information about the NLSY 97 sample, click [here](https://www.nlsinfo.org/content/cohorts/nlsy97/intro-to-the-sample/nlsy97-sample-introduction-0).

Simple regression model
-----------------------

We'll be working with the same regression model as Wooldridge, with *y* as a linear function of *x*.

*y*<sub>*i*</sub> = *β*<sub>*o*</sub> + *β*<sub>1</sub>*x*<sub>*i*</sub> + *u*<sub>*i*</sub>

We're interested in coming up with estimates of the unknown population parameters *β*<sub>0</sub> and *β*<sub>1</sub>.

Since we'll be doing OLS, we'll make all of the standard assumptions:

-   The function *y*<sub>*i*</sub> = *β*<sub>*o*</sub> + *β*<sub>1</sub>*x*<sub>*i*</sub> + *u* is linear in parameters

-   Our sample, including data *y*<sub>*i*</sub> and *x*<sub>*i*</sub> has been drawn randomly.

-   There's variation in *x*

-   The expected value of the error given the covariate is 0: *E*(*u*|*x*)=0, and the same is true in the sample, *E*(*u*<sub>*i*</sub>|*x*<sub>*i*</sub>)=0, meaning that *x* is fixed in repeated samples

The estimators $\\hat{\\beta\_0}$, $\\hat{\\beta\_1}$ are unbiased given the above assumptions hold. This means that $E(\\hat{\\beta\_1}=\\beta\_1)$ in repeated sampling.

Let's figure out how income and postsecondary attainment are related. Using the NLSY97 data set, we will get estimates for the following population regression model:

***/


version 15
capture log close

/* PhD Practicum, Spring 2020 */
/* Getting Started with Regression */
/* Will Doyle*/
/* 2/4/21 */
/* Github Repo */

 /*Graph type postscript */
// local gtype ps

/* Graph type: pdf */
//local gtype pdf

/* Graph type: eps */
local gtype eps

clear

capture

use nlsy97, clear

set seed 070328

sample 10

local y yinc

local x ccol 

local ytitle "Income"

local xtitle "Months of College"


/***

Plotting Data
-------------

Before we do this, let's do a scatterplot. The scatterplot is the most fundamental graphical tool for regression. As a starting rule, never run a regression before looking at a scatterplot. In the accompanying do file, I've included the macros for setting this up in terms of *x* and *y*.

First, let's just plot *y* as a function of *x*:

***/

/*First plot the data*/

graph twoway scatter `y' `x', msize(small) ytitle(`ytitle') xtitle(`xtitle')

graph export "simple_scatter.`gtype'", replace


/***


We can than add a lowess fit to see what the shape of the relationship between *x* and *y* looks like.

There are a variety of ways to check on the pattern on the data. A lowess regression gives you a local average estimate, which is sensitive to the patterns in the data:

***/

/* Add a lowess fit */

graph twoway lowess `y' `x', msize(small) ytitle(`ytitle') xtitle(`xtitle')

graph export "simple_lowess.`gtype'", replace

graph twoway lowess `y' `x' || ///
      scatter `y' `x', ///
      msize(tiny) ///
      msymbol(smcircle) ///
      ytitle(`ytitle') ///
      xtitle(`xtitle') ///
      legend( order(2 "`xtitle'" 1 "Lowess fit") )
      
graph export "scatter_lowess.`gtype'", replace

/*Exercise: do the same with another covariate*/

/***

Our next step is to plot a linear fit to the data.

***/

 /*Linear fit to the data*/
    
graph twoway lfit `y' `x' || ///
      scatter `y' `x', ///
      msize(tiny) ///
      msymbol(circle) ///
      ytitle(`ytitle') ///
      xtitle(`xtitle') ///
      legend( order(2 `xtitle' 1 "Linear fit") ) //
      

graph export "scatter_linear.`gtype'",replace


/***

Estimating Regression in Stata
------------------------------

We start with a basic regression of income on months of postsecondary education. There are a couple of ways of describing this, one is just to say we estimate a regression predicting income as a function of postseconcary attendance. Another way is to say we regress income on postsecondary attendance.

***/

/*Get regression results */

reg `y' `x'


/***

*Quick Exercise*

Run a regression with same dependent variable but a different independent variable. Interpret the results in one sentence. Write this sentence down.


***/


/***

Extracting Results
------------------

One key skill for today is being able to extract individual parts of the regression estimates from what Stata stores in memory. You need to build a map from the equations we'll be discussing to what can be accessed in Stata. Below, we start by extracting the regression coefficients.

***/

/*Extracting regression results */

/*What's Beta? */

mat betamat=e(b)

/***

The standard errors are stored as a variance-covariance matrix. To get a standard error, we need to take the square root of the elements of the diagonal of this matrix.

***/

/*Where are the standard errors ?*/

mat vcmat=e(V)
 
scalar myb=betamat[1,1]


// NOOOOO
//scalar myb=e(b)[1,1]

scalar varbeta1=vcmat[1,1]

scalar sebeta1=sqrt(varbeta1)

/*Another way to get results back*/


/***

We can use a different approach to get the same scalars. In Stata, referencing `_b[<varname>]` will pull the scalar for the coefficient asscoiated with the variable name. Similarly, referencing `_se[<varname>]` will get the standard error for that coefficient.

***/

scalar beta0=_b[_cons]

scalar li beta0

scalar li 

scalar se_beta0=_se[_cons]

scalar beta1=_b[`x']

scalar se_beta1=_se[`x']

scalar li beta1

/***
*Quick exercise: using both of the above methods, extract the estimate for the intercept*
***/

/***
Confidence Intervals
--------------------

By default, Stata gives 95% confidence intervals. To get confidence intervals at a different level, use the following code:

***/

/*Use different confidence intervals */
reg `y' `x', level(90)


/***

*Quick exercise: run the regression again, but this time get 80% CI*

***/

/***

Residuals and Predictions
-------------------------

Residuals are not stored as part of the estimation results, but can be generated through the `predict` command. Below, I use the `predict` command to get residuals for this estimation.

***/

/*How to get residual */
predict uhat, residuals

/*Residuals sum to 0 by definition */
tabstat uhat, stat(sum)

/***

These residuals can then be plotted as a function of *x*.

***/

/*Plot residuals by x*/
graph twoway scatter uhat `x',yline(0) msize(tiny)
graph export "residplot.`gtype'",replace

/*More complex graph*/
graph twoway scatter uhat `x', ///
      msize(tiny) ///
      msymbol(circle) ///
          || ///
     scatter `y' `x', ///
     msize(tiny) ///
     msymbol(triangle) 


	 
	 
/*Putting the pieces together*/
graph twoway scatter uhat `x', ///
      msize(tiny) ///
      msymbol(circle) ///
          || ///
       scatter `y' `x', ///
       msize(tiny) ///
       msymbol(triangle) ///
           || ///
      lfit `y' `x', ///
      lwidth(thin) ///
      yline(0, lpattern(dash) lwidth(thin)) ///
      legend(order(1 2 "Actual `ytitle'" 3))


graph export "residplot_fancy.`gtype'",replace

/***

The predicted value of y is also generated via the `predict` command.

***/

/*Predictions */
predict yhat 

/*Actual vs. predicted plot*/
graph twoway scatter yhat `x', ///
      msize(tiny) ///
      msymbol(circle) ///
      || ///
      scatter `y' `x', ///
      msize(tiny) ///
      msymbol(triangle) 


graph export "predict.`gtype'",replace

/***

These predicted values can be plotted relative to the actual data.

***/

/*Do the same for another regressor */


/***

Measures of Model Fit
---------------------

The first measure of model fit we consider is the *F* statistic. There are several ways to think about the *F* statistic. For now, I'm going to suggest that you think of it as the ratio of two measures. The first measure is the difference between the predicted value and the mean, or how different are your predictions than what would be predicted using the unconditional mean. The second measure is the difference between the predicted value and the actual value. We'll discuss this in class, but you should have an intuitive sense as to why the former should be large relative to the latter.

***/

/*Measures of fit */

ereturn list

/***
Below, I conduct a test of statistical significance "by hand" to show how this is done in Stata.
***/

// Sample size
scalar myN=e(N)

// Number of estimated parameters
scalar myk=colsof(betamat)

/// What's the residual sum of squares? 

scalar residss=e(rss)

gen diff=`y'-yhat

gen diff_sq=diff*diff

tabstat diff_sq,stat(sum) save

mat mymat=r(StatTotal)

scalar my_rss=mymat[1,1]

scalar li residss my_rss


///What's the model sum of squares?

scalar modss=e(mss)

tabstat `y', stat(mean) save

mat mymat=r(StatTotal)

scalar ybar=mymat[1,1]

gen diff2=yhat-ybar

gen diff2_sq=diff2*diff2

tabstat diff2_sq, stat(sum) save

mat mymat=r(StatTotal)

scalar my_mss=mymat[1,1]

scalar li modss my_mss

/*Calculate F */

scalar df_resid=myN-myk

scalar df_m=myk-1

scalar modss_std=my_mss/df_m

scalar residss_std=my_rss/df_resid

scalar myf=modss_std/residss_std

scalar fstat=e(F)

scalar li myf fstat

/*What is R squared?*/

corr yhat `y'

scalar rsquare= e(r2)

/*What is adjusted r squared? */

scalar adj_rsquare= 1-((1-rsquare)*((myN-1)/(myN-myk)))
           
/*Tests of statistical significance */

scalar my_df=myN-myk

// Observed t value 
scalar myt=beta1/sebeta1 

scalar my_pval=.05

scalar req_t=invttail(my_df,(my_pval/2))

scalar test=cond(abs(myt)>=req_t,"Significant","Not significant")

// p value 
scalar stat_sig=(2*ttail(my_df,myt))



exit










