version 14
capture log close
log using "diagnose.log",replace

/* PhD Practicum, Spring 2017 */
/* Diagnosing Problems with Regression */
/* Will Doyle*/
/* 2/27/2018 */
/* On github repo */

clear

graph drop _all

set scheme s1color

use griliches76

*local filetype rtf

local filetype tex

*local gtype png

local gtype pdf

/**************************************************/
/*Recode  Data*/
/* NB: doing this just to "screw things up" in interesting ways */
/**************************************************/  

gen w=exp(lw)

gen expr2=expr*expr

drawnorm noise2,means(10) sds(2)

gen lw_het=lw

sum lw

drawnorm mynoise3, mean(0) sd(3)

drawnorm mynoise4, mean(0) sd(4)

drawnorm mynoise5, mean(0) sd(5)

drawnorm mynoise6, mean(0) sd(6)

replace lw_het=4.4+.09*s+mynoise3 if s==10

replace lw_het=4.4+.09*s+mynoise4 if s==12

replace lw_het=4.4+.09*s+mynoise5 if s==14

replace lw_het=4.4+.09*s+mynoise6 if s==16

gen test3=iq+noise2

gen w_influence=w

replace w_influence=2000 if s==18& w>750 

local y lw 

local x s

local controls kww iq expr tenure rns smsa med test3

/**************************************************/
/* Basic descriptives and regression results */
/**************************************************/
  
eststo descriptives: mean `y' `x' `controls'

#delimit;
esttab descriptives using  "esttab_means.`filetype'",
        label /* Use variable labels */
        replace /*Replace file if it exists */
        nostar /* No sig tests */
        cells(b(fmt(2) label("Mean")) se(fmt(2) label("S.E.") ))
        title("Descriptive Statistics for Variables in Analysis")
        nonumbers
        nomtitles
        ;
#delimit cr

estimates clear

/* Run the basic regression */
reg `y' `x'
eststo basic_model, title("Model 1")

reg `y' `x' `controls'
eststo full_model, title("Model 2")

#delimit ;
quietly esttab * using `y'_models.`filetype',          /* estout command: * indicates all estimates in memory */
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
               mtitles ("No Controls" "Student Controls" "Students and Finance" "Full Model")  /*  Model titles */
               ;


#delimit cr

/**************************************************/
/*Collinearity*/
/**************************************************/  
estimates restore full_model

estat vif

test test3 iq /* Combined these two need to be in the model */

local controls kww iq expr tenure rns smsa med 

reg `y' `x' `controls'

eststo full_model_a, title("Model 2:No Test 3")

estat vif

/**************************************************/
/*Heteroskedasticity*/
/**************************************************/  

reg lw_het  `x' `controls'

estimates store het_model

predict e, resid

graph twoway scatter e s, yline(0) name(residplot1)

graph export het_results.`gtype', replace

/*Breusch-Pagen Test */
est restore het_model

//No options, yhat is used as the covariate

estat hettest , iid 

//BP with subsets of covariates

estat hettest `controls', iid

estat hettest s expr

/*White Test */
  
estat imtest, white

/*Robust s.e.'s*/
reg lw_het `x' `controls', robust
eststo full_model_robust, title("Model 2: Robust SE")

reg lw_het `x' `controls', vce(robust)

/*Clustered se.'s*/
reg `y' `x' `controls', cluster(med)
eststo full_model_cluster, title("Model 2: Cluster SE")

  
/*Data Scaling*/

reg `y' `x' `controls'
  
reg `y' `x' `controls', beta


eststo full_model_beta, title("Model 2: Standardized Coefficients")

gen expr_new=1+2*s

local x expr_new

reg `y' `x' `controls', beta

local x s

/**************************************************/
/*Functional Form */
/**************************************************/

graph twoway scatter w s, msize(tiny)||lowess w s ,name(lowess_plot)

graph export lowess1.`gtype', replace

graph twoway scatter w s, msize(tiny)||lowess w s ||lfit w s ,name(lfit_plot)

graph export lfit1.`gtype', replace

/* Basic scatterplot */
graph twoway scatter lw expr, msize(tiny)

graph save basic_scatter, replace

/* Add lowess */
graph twoway scatter lw expr, msize(tiny)  ///
  ||lowess lw expr ||, legend (order(2 "Lowess"))
graph save lowess_add, replace

/* Add linear fit */
graph twoway scatter lw expr, msize(tiny) ///
  ||lowess lw expr ///
  || lfit lw expr, ///
  legend(order(2 "Lowess" 3 "Linear Fit"))
   
graph save lfit_add, replace

/* Add quadratic fit */
graph twoway scatter lw expr, msize(tiny) ///
  ||lowess lw expr ///
  || lfit lw expr ///
  || qfit lw expr, ///
  legend(order(2 "Lowess" 3 "Linear Fit" 4 "Quadratic Fit"))

graph save qfit_add, replace 

graph combine basic_scatter.gph lowess_add.gph lfit_add.gph qfit_add.gph, rows(2)


graph export logfit.`gtype', replace

reg lw s expr expr2

test expr expr2




/**************************************************/
/* Influential Observiations*/
/**************************************************/  

reg  w_influence s expr expr2

scalar reg_n=e(N)

/* leverage plot */

lvr2plot, msize(tiny) name(leverage_plot)

graph export levplot.`gtype', replace

/* Leverage and outliers  */
  
predict lev if e(sample), leverage

predict resid if e(sample), resid

gen  resid2=resid^2

gsort -lev

list w_influence s lev resid2 in 1/20

/* Dfits measure */

predict  dfits if e(sample), dfits

gsort -dfits

generate cutoff =abs(dfits)> 2*sqrt((e(df_m)+1)/e(N)) & e(sample)

list w_influence s dfits if cutoff


/* Cook's D */

predict cooksd1 if e(sample), cooksd

generate cutoff2=4/reg_n

gsort -cooksd1

li w_influence resid2 lev cooksd if cooksd1>cutoff2

  
/*DfBeta*/
dfbeta

scalar dfbeta_cutoff=2/sqrt(reg_n)

li _dfbeta_1 if _dfbeta_1>dfbeta_cutoff
  
log close

exit

