version 13
capture log close
log using "reg_basic.log",replace

/* PhD Practicum, Spring 2018 */
/* Getting Started with Regression */
/* Will Doyle*/
/* 1/15/19 */
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

/*First plot the data*/

graph twoway scatter `y' `x', msize(small) ytitle(`ytitle') xtitle(`xtitle')

graph export "simple_scatter.`gtype'", replace

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


 /*Linear fit to the data*/
    
graph twoway lfit `y' `x' || ///
      scatter `y' `x', ///
      msize(tiny) ///
      msymbol(cricle) ///
      ytitle(`ytitle') ///
      xtitle(`xtitle') ///
      legend( order(2 `xtitle' 1 "Linear fit") ) //
      

graph export "scatter_linear.`gtype'",replace

/*Get regression results */

reg `y' `x'

/*Extracting regression results */

/*What's Beta? */

mat betamat=e(b)

/*Where are the standard errors ?*/

mat vcmat=e(V)
 
scalar myb=betamat[1,1]


// NOOOOO
//scalar myb=e(b)[1,1]

scalar varbeta1=vcmat[1,1]

scalar sebeta1=sqrt(varbeta1)

/*Another way to get results back*/

scalar beta0=_b[_cons]

scalar li beta0

scalar li 

scalar se_beta0=_se[_cons]

scalar beta1=_b[`x']

scalar se_beta1=_se[`x']

scalar li beta1


/*Use different confidence intervals */
reg `y' `x', level(90)

/*How to get residual */
predict uhat, residuals

/*Residuals sum to 0 by definition */
tabstat uhat, stat(sum)



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

/*Do the same for another regressor */

/*Measures of fit */

ereturn list

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










