Using Prediction to Understand Regression
=========================================

LPO 9952
========

Too often, analysts consider the analysis done when they’ve run a
regression and then re- ported some tables. You should consider
reporting your parameter estimates as the start of your report, not the
end. In particular, you should think about what you r results predict.
The point of almost all policy analysis is to predict what would happen
to the dependent variable if the independent variable changed. This is
the essence of prediction.

You’ll want to use prediction for several different purposes, each of
which we’ll go through.

-   To show how well the model predicts the data used to estimate
    parameters

-   To make out-ofsample predictions using the regression line

-   To forecast results for individuals in sample

-   To forecast results for individuals out of sample

A bit of theory
---------------

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

Of course, $\theta_0$ is not measured without error. Instead, we need to
make use of the uncertainty surrounding our estimates $\hat{\beta}_k$
which go into the estimate.

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

Predicting data in sample
-------------------------

We're using the `caschool.dta` data again. We'll run two regressions, a
basic one with no controls showing the impact of student teacher ratios
on math test scores, then another again estimating the relationship
after controlling for other characteristics of the school districts.

          . version 14

          . capture log close

          . log using "reg_predictlog",replace
          ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                name:  <unnamed>
                 log:  /Users/doylewr/lpo_prac/lessons/s2-04-regression_prediction/reg_predictlog.smcl
            log type:  smcl
           opened on:  25 Feb 2021, 08:49:20

          . clear

          . clear mata

          . clear matrix

          . estimates clear

          . graph drop _all

          . set scheme s1color

          . set more off

          . global gdir "../../data/"

          . use ${gdir}caschool, clear

          . gen  expn_stu_t=expn_stu/1000

          . save caschool_new, replace
          file caschool_new.dta saved

          . label variable math_scr "Math Scores"

          . label variable str "Student Teacher Ratio"

          . label variable expn_stu_t "Expenditures per Student (1000s)"

          . label variable avginc "Average Income"

          . label variable el_pct "English Language Percent"

          . label variable meal_pct "Percent on Free/Reduced Meals"

          . label variable comp_stu "Computers per Student"

          . local gtype pdf /*For Mac*/

          . local first_part=1

          . local second_part=1

          . local y math_scr

          . local x str

          . local controls expn_stu_t avginc el_pct meal_pct comp_stu

          . local alpha=.05

          . local alpha_a=.1

          . local alpha_2=`alpha'/2

          . local alpha_2a=`alpha_a'/2

          . reg `y' `x'

                Source |       SS           df       MS      Number of obs   =       420
          -------------+----------------------------------   F(1, 418)       =     16.62
                 Model |  5635.62443         1  5635.62443   Prob > F        =    0.0001
              Residual |  141735.097       418   339.07918   R-squared       =    0.0382
          -------------+----------------------------------   Adj R-squared   =    0.0359
                 Total |  147370.722       419  351.720099   Root MSE        =    18.414

          ------------------------------------------------------------------------------
              math_scr |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
          -------------+----------------------------------------------------------------
                   str |  -1.938591   .4755165    -4.08   0.000    -2.873292   -1.003889
                 _cons |   691.4174   9.382469    73.69   0.000     672.9747    709.8601
          ------------------------------------------------------------------------------


          . eststo  basic

          . reg `y' `x' `controls'

                Source |       SS           df       MS      Number of obs   =       420
          -------------+----------------------------------   F(6, 413)       =    180.29
                 Model |  106651.228         6  17775.2047   Prob > F        =    0.0000
              Residual |  40719.4931       413  98.5944143   R-squared       =    0.7237
          -------------+----------------------------------   Adj R-squared   =    0.7197
                 Total |  147370.722       419  351.720099   Root MSE        =    9.9295

          ------------------------------------------------------------------------------
              math_scr |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
          -------------+----------------------------------------------------------------
                   str |  -.2217831   .3355029    -0.66   0.509    -.8812893    .4377232
            expn_stu_t |  -.0070057   1.044094    -0.01   0.995    -2.059407    2.045395
                avginc |   .7093258   .1037914     6.83   0.000     .5053005    .9133511
                el_pct |  -.1097502   .0372649    -2.95   0.003    -.1830028   -.0364976
              meal_pct |  -.3824315   .0330651   -11.57   0.000    -.4474284   -.3174346
              comp_stu |   14.11309   8.116897     1.74   0.083     -1.84249    30.06868
                 _cons |   663.7802   10.64377    62.36   0.000     642.8575    684.7029
          ------------------------------------------------------------------------------


          . eststo basic_controls

          . #delimit ;
          delimiter now ;
          . quietly esttab * using my_models.tex,          /* estout command: * indicates all estimates in memory. csv specifies comma sep, best for excel */               label                          /*Use labels for models and variables */               nodepvars                      /* Use my model titles */               b(2)                           /* b= coefficients , this gives two sig digits */               not                            /* I don't want t statistics */               se(2)                         /* I do want standard errors */               nostar                       /* No stars */               r2 (2)                      /* R squared */               ar2 (2)                     /* Adj R squared */               scalar(F  "df_m D.F. Model" "df_r D.F. Residual" N)   /* select stats from the ereturn (list) */               sfmt (2 0 0 0)               /* format for stats*/               replace                   /* replace existing file */               nomtitles               ;


          . #delimit cr
          delimiter now cr
          . local df_r=e(df_r)

          . local myt=invttail(`df_r',`alpha_2')

          . scalar myt=`myt'

          . local myt2=invttail(`df_r',`alpha_2a')

          . scalar myt2=`myt2'

          . if `first_part'==1{
          . estimates restore basic
          (results basic are active now)

What we want to do is to first show the overall relationship between
student teacher ratios and test scores and to indicate our uncertainty
for the regression line. This is when prediction comes in handy.

          . predict yhat, xb
          . predict yhat_se,stdp
          . gen low_ci=yhat-(`myt'*yhat_se)
          . gen hi_ci=yhat+(`myt'*yhat_se)
          . gen low_ci_90=yhat-(`myt2'*yhat_se)
          . gen hi_ci_90=yhat+(`myt2'*yhat_se)
          . sort `x'
          . graph twoway scatter `y' `x',msize(small) mcolor(blue)  ///
             || line yhat `x',lcolor(red) ///
             || line low_ci `x', lcolor(red) lpattern(dash) ///
             || line hi_ci `x', lcolor(red) lpattern(dash) ///
             || line low_ci_90 `x', lcolor(yellow) lpattern(dash) ///
             || line hi_ci_90 `x', lcolor(yellow) lpattern(dash) ///
                 legend( order(1 "Math score" 2 "Prediction" 3 "95% Confidence Interval" 5 "90% Confidence Interval")) ///
                 name(basic_predict)

          . 

          . graph export basic_predict.`gtype', replace
          (file /Users/doylewr/lpo_prac/lessons/s2-04-regression_prediction/basic_predict.pdf written in PDF format)

Remember that the prediction interval does not tell us where we can
expect any individual unit to be located. Instead, the prediction
interval tells us the likely range of \emph{lines} that would be
generated in repeated samples.

Hypothetical Values
-------------------

Many times, we'd also like to think about how the dependent variable
would increase or decrease as a function of hypothetical values of x.
Using only Stata's `predict`' command, we're stuck with just using the
data in memory. The `margins` command can help us to make predictions
for hypothetical values of the independent variable.

There are two steps to using margins. First, we need to generate values
of $\hat{y}$ across levels of x, then we need to generate the standard
error of $\hat{y}$ across those same levels of x. With those estimates
in hand, we can save them in memory and plot them.

          . sum `x', detail

                              Student Teacher Ratio
          -------------------------------------------------------------
                Percentiles      Smallest
           1%     15.13898             14
           5%     16.41658       14.20176
          10%     17.34573       14.54214       Obs                 420
          25%     18.58179       14.70588       Sum of Wgt.         420

          50%     19.72321                      Mean           19.64043
                                  Largest       Std. Dev.      1.891812
          75%     20.87183          24.95
          90%     21.87561       25.05263       Variance       3.578952
          95%     22.64514       25.78512       Skewness      -.0253655
          99%     24.88889           25.8       Kurtosis       3.609597
          . local mymin=r(min)
          . local mymax=r(max)
          . estimates restore basic_controls
          (results basic_controls are active now)
          . local dfr=e(df_r)
          . #delimit ;
          delimiter now ;
          . margins , /* init margins */    predict(xb) /* Type of prediction */    nose /* Don't give SE */    at( (mean) /* Prediction at mean of all variables */    `controls' /* Set controls at mean */    `x'=(`mymin'(.1)`mymax'))  /*range from min to max of x in steps of .1 */     post  /* Post results in matrix form */         ;


          Adjusted predictions                            Number of obs     =        420

          Expression   : Linear prediction, predict(xb)

          1._at        : str             =          14
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          2._at        : str             =        14.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          3._at        : str             =        14.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          4._at        : str             =        14.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          5._at        : str             =        14.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          6._at        : str             =        14.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          7._at        : str             =        14.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          8._at        : str             =        14.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          9._at        : str             =        14.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          10._at       : str             =        14.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          11._at       : str             =          15
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          12._at       : str             =        15.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          13._at       : str             =        15.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          14._at       : str             =        15.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          15._at       : str             =        15.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          16._at       : str             =        15.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          17._at       : str             =        15.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          18._at       : str             =        15.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          19._at       : str             =        15.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          20._at       : str             =        15.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          21._at       : str             =          16
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          22._at       : str             =        16.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          23._at       : str             =        16.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          24._at       : str             =        16.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          25._at       : str             =        16.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          26._at       : str             =        16.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          27._at       : str             =        16.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          28._at       : str             =        16.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          29._at       : str             =        16.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          30._at       : str             =        16.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          31._at       : str             =          17
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          32._at       : str             =        17.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          33._at       : str             =        17.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          34._at       : str             =        17.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          35._at       : str             =        17.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          36._at       : str             =        17.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          37._at       : str             =        17.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          38._at       : str             =        17.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          39._at       : str             =        17.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          40._at       : str             =        17.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          41._at       : str             =          18
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          42._at       : str             =        18.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          43._at       : str             =        18.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          44._at       : str             =        18.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          45._at       : str             =        18.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          46._at       : str             =        18.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          47._at       : str             =        18.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          48._at       : str             =        18.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          49._at       : str             =        18.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          50._at       : str             =        18.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          51._at       : str             =          19
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          52._at       : str             =        19.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          53._at       : str             =        19.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          54._at       : str             =        19.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          55._at       : str             =        19.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          56._at       : str             =        19.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          57._at       : str             =        19.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          58._at       : str             =        19.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          59._at       : str             =        19.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          60._at       : str             =        19.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          61._at       : str             =          20
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          62._at       : str             =        20.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          63._at       : str             =        20.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          64._at       : str             =        20.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          65._at       : str             =        20.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          66._at       : str             =        20.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          67._at       : str             =        20.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          68._at       : str             =        20.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          69._at       : str             =        20.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          70._at       : str             =        20.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          71._at       : str             =          21
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          72._at       : str             =        21.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          73._at       : str             =        21.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          74._at       : str             =        21.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          75._at       : str             =        21.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          76._at       : str             =        21.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          77._at       : str             =        21.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          78._at       : str             =        21.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          79._at       : str             =        21.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          80._at       : str             =        21.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          81._at       : str             =          22
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          82._at       : str             =        22.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          83._at       : str             =        22.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          84._at       : str             =        22.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          85._at       : str             =        22.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          86._at       : str             =        22.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          87._at       : str             =        22.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          88._at       : str             =        22.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          89._at       : str             =        22.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          90._at       : str             =        22.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          91._at       : str             =          23
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          92._at       : str             =        23.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          93._at       : str             =        23.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          94._at       : str             =        23.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          95._at       : str             =        23.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          96._at       : str             =        23.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          97._at       : str             =        23.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          98._at       : str             =        23.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          99._at       : str             =        23.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          100._at      : str             =        23.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          101._at      : str             =          24
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          102._at      : str             =        24.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          103._at      : str             =        24.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          104._at      : str             =        24.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          105._at      : str             =        24.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          106._at      : str             =        24.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          107._at      : str             =        24.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          108._at      : str             =        24.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          109._at      : str             =        24.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          110._at      : str             =        24.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          111._at      : str             =          25
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          112._at      : str             =        25.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          113._at      : str             =        25.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          114._at      : str             =        25.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          115._at      : str             =        25.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          116._at      : str             =        25.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          117._at      : str             =        25.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          118._at      : str             =        25.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          ------------------------------------------------------------------------------
                       |     Margin
          -------------+----------------------------------------------------------------
                   _at |
                    1  |   654.5936
                    2  |   654.5714
                    3  |   654.5492
                    4  |    654.527
                    5  |   654.5049
                    6  |   654.4827
                    7  |   654.4605
                    8  |   654.4383
                    9  |   654.4161
                   10  |    654.394
                   11  |   654.3718
                   12  |   654.3496
                   13  |   654.3274
                   14  |   654.3053
                   15  |   654.2831
                   16  |   654.2609
                   17  |   654.2387
                   18  |   654.2165
                   19  |   654.1944
                   20  |   654.1722
                   21  |     654.15
                   22  |   654.1278
                   23  |   654.1056
                   24  |   654.0835
                   25  |   654.0613
                   26  |   654.0391
                   27  |   654.0169
                   28  |   653.9948
                   29  |   653.9726
                   30  |   653.9504
                   31  |   653.9282
                   32  |    653.906
                   33  |   653.8839
                   34  |   653.8617
                   35  |   653.8395
                   36  |   653.8173
                   37  |   653.7951
                   38  |    653.773
                   39  |   653.7508
                   40  |   653.7286
                   41  |   653.7064
                   42  |   653.6843
                   43  |   653.6621
                   44  |   653.6399
                   45  |   653.6177
                   46  |   653.5955
                   47  |   653.5734
                   48  |   653.5512
                   49  |    653.529
                   50  |   653.5068
                   51  |   653.4847
                   52  |   653.4625
                   53  |   653.4403
                   54  |   653.4181
                   55  |   653.3959
                   56  |   653.3738
                   57  |   653.3516
                   58  |   653.3294
                   59  |   653.3072
                   60  |    653.285
                   61  |   653.2629
                   62  |   653.2407
                   63  |   653.2185
                   64  |   653.1963
                   65  |   653.1742
                   66  |    653.152
                   67  |   653.1298
                   68  |   653.1076
                   69  |   653.0854
                   70  |   653.0633
                   71  |   653.0411
                   72  |   653.0189
                   73  |   652.9967
                   74  |   652.9746
                   75  |   652.9524
                   76  |   652.9302
                   77  |    652.908
                   78  |   652.8858
                   79  |   652.8637
                   80  |   652.8415
                   81  |   652.8193
                   82  |   652.7971
                   83  |   652.7749
                   84  |   652.7528
                   85  |   652.7306
                   86  |   652.7084
                   87  |   652.6862
                   88  |   652.6641
                   89  |   652.6419
                   90  |   652.6197
                   91  |   652.5975
                   92  |   652.5753
                   93  |   652.5532
                   94  |    652.531
                   95  |   652.5088
                   96  |   652.4866
                   97  |   652.4645
                   98  |   652.4423
                   99  |   652.4201
                  100  |   652.3979
                  101  |   652.3757
                  102  |   652.3536
                  103  |   652.3314
                  104  |   652.3092
                  105  |    652.287
                  106  |   652.2648
                  107  |   652.2427
                  108  |   652.2205
                  109  |   652.1983
                  110  |   652.1761
                  111  |    652.154
                  112  |   652.1318
                  113  |   652.1096
                  114  |   652.0874
                  115  |   652.0652
                  116  |   652.0431
                  117  |   652.0209
                  118  |   651.9987
          ------------------------------------------------------------------------------
          . #delimit cr
          delimiter now cr
          . mat xb=e(b)
          . mat allx=e(at)
          . matrix myx=allx[1...,1]'
          . estimates restore basic_controls
          (results basic_controls are active now)
          . margins , predict(stdp) nose at(`x'=(`mymin'(.1)`mymax') (mean) `controls') post

          Adjusted predictions                            Number of obs     =        420

          Expression   : S.E. of the prediction, predict(stdp)

          1._at        : str             =          14
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          2._at        : str             =        14.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          3._at        : str             =        14.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          4._at        : str             =        14.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          5._at        : str             =        14.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          6._at        : str             =        14.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          7._at        : str             =        14.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          8._at        : str             =        14.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          9._at        : str             =        14.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          10._at       : str             =        14.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          11._at       : str             =          15
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          12._at       : str             =        15.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          13._at       : str             =        15.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          14._at       : str             =        15.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          15._at       : str             =        15.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          16._at       : str             =        15.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          17._at       : str             =        15.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          18._at       : str             =        15.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          19._at       : str             =        15.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          20._at       : str             =        15.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          21._at       : str             =          16
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          22._at       : str             =        16.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          23._at       : str             =        16.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          24._at       : str             =        16.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          25._at       : str             =        16.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          26._at       : str             =        16.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          27._at       : str             =        16.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          28._at       : str             =        16.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          29._at       : str             =        16.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          30._at       : str             =        16.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          31._at       : str             =          17
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          32._at       : str             =        17.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          33._at       : str             =        17.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          34._at       : str             =        17.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          35._at       : str             =        17.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          36._at       : str             =        17.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          37._at       : str             =        17.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          38._at       : str             =        17.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          39._at       : str             =        17.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          40._at       : str             =        17.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          41._at       : str             =          18
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          42._at       : str             =        18.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          43._at       : str             =        18.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          44._at       : str             =        18.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          45._at       : str             =        18.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          46._at       : str             =        18.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          47._at       : str             =        18.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          48._at       : str             =        18.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          49._at       : str             =        18.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          50._at       : str             =        18.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          51._at       : str             =          19
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          52._at       : str             =        19.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          53._at       : str             =        19.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          54._at       : str             =        19.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          55._at       : str             =        19.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          56._at       : str             =        19.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          57._at       : str             =        19.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          58._at       : str             =        19.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          59._at       : str             =        19.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          60._at       : str             =        19.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          61._at       : str             =          20
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          62._at       : str             =        20.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          63._at       : str             =        20.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          64._at       : str             =        20.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          65._at       : str             =        20.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          66._at       : str             =        20.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          67._at       : str             =        20.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          68._at       : str             =        20.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          69._at       : str             =        20.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          70._at       : str             =        20.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          71._at       : str             =          21
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          72._at       : str             =        21.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          73._at       : str             =        21.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          74._at       : str             =        21.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          75._at       : str             =        21.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          76._at       : str             =        21.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          77._at       : str             =        21.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          78._at       : str             =        21.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          79._at       : str             =        21.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          80._at       : str             =        21.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          81._at       : str             =          22
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          82._at       : str             =        22.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          83._at       : str             =        22.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          84._at       : str             =        22.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          85._at       : str             =        22.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          86._at       : str             =        22.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          87._at       : str             =        22.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          88._at       : str             =        22.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          89._at       : str             =        22.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          90._at       : str             =        22.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          91._at       : str             =          23
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          92._at       : str             =        23.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          93._at       : str             =        23.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          94._at       : str             =        23.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          95._at       : str             =        23.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          96._at       : str             =        23.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          97._at       : str             =        23.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          98._at       : str             =        23.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          99._at       : str             =        23.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          100._at      : str             =        23.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          101._at      : str             =          24
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          102._at      : str             =        24.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          103._at      : str             =        24.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          104._at      : str             =        24.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          105._at      : str             =        24.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          106._at      : str             =        24.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          107._at      : str             =        24.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          108._at      : str             =        24.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          109._at      : str             =        24.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          110._at      : str             =        24.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          111._at      : str             =          25
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          112._at      : str             =        25.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          113._at      : str             =        25.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          114._at      : str             =        25.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          115._at      : str             =        25.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          116._at      : str             =        25.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          117._at      : str             =        25.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          118._at      : str             =        25.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          ------------------------------------------------------------------------------
                       |     Margin
          -------------+----------------------------------------------------------------
                   _at |
                    1  |   1.953419
                    2  |   1.920935
                    3  |   1.888489
                    4  |   1.856081
                    5  |   1.823715
                    6  |   1.791393
                    7  |   1.759116
                    8  |   1.726889
                    9  |   1.694712
                   10  |    1.66259
                   11  |   1.630525
                   12  |   1.598521
                   13  |   1.566582
                   14  |   1.534712
                   15  |   1.502915
                   16  |   1.471195
                   17  |   1.439559
                   18  |   1.408011
                   19  |   1.376558
                   20  |   1.345207
                   21  |   1.313964
                   22  |   1.282837
                   23  |   1.251836
                   24  |    1.22097
                   25  |   1.190249
                   26  |   1.159684
                   27  |   1.129289
                   28  |   1.099078
                   29  |   1.069066
                   30  |    1.03927
                   31  |    1.00971
                   32  |   .9804069
                   33  |   .9513842
                   34  |   .9226692
                   35  |   .8942904
                   36  |   .8662813
                   37  |    .838679
                   38  |   .8115251
                   39  |   .7848666
                   40  |   .7587546
                   41  |   .7332482
                   42  |   .7084126
                   43  |    .684321
                   44  |   .6610551
                   45  |   .6387042
                   46  |   .6173683
                   47  |   .5971561
                   48  |   .5781854
                   49  |   .5605828
                   50  |   .5444801
                   51  |   .5300145
                   52  |   .5173233
                   53  |   .5065399
                   54  |   .4977885
                   55  |   .4911774
                   56  |   .4867938
                   57  |   .4846984
                   58  |   .4849207
                   59  |   .4874576
                   60  |   .4922732
                   61  |   .4993017
                   62  |   .5084513
                   63  |     .51961
                   64  |   .5326513
                   65  |    .547441
                   66  |   .5638415
                   67  |   .5817165
                   68  |   .6009344
                   69  |   .6213703
                   70  |   .6429087
                   71  |   .6654422
                   72  |   .6888733
                   73  |   .7131135
                   74  |   .7380824
                   75  |   .7637097
                   76  |   .7899308
                   77  |   .8166884
                   78  |   .8439316
                   79  |   .8716143
                   80  |   .8996969
                   81  |   .9281427
                   82  |   .9569193
                   83  |   .9859976
                   84  |   1.015351
                   85  |   1.044958
                   86  |   1.074797
                   87  |   1.104848
                   88  |   1.135096
                   89  |   1.165524
                   90  |    1.19612
                   91  |   1.226869
                   92  |   1.257763
                   93  |   1.288789
                   94  |   1.319938
                   95  |   1.351202
                   96  |   1.382574
                   97  |   1.414045
                   98  |   1.445611
                   99  |   1.477263
                  100  |   1.508998
                  101  |   1.540809
                  102  |   1.572693
                  103  |   1.604645
                  104  |    1.63666
                  105  |   1.668736
                  106  |   1.700869
                  107  |   1.733056
                  108  |   1.765294
                  109  |   1.797579
                  110  |    1.82991
                  111  |   1.862284
                  112  |   1.894699
                  113  |   1.927153
                  114  |   1.959643
                  115  |   1.992169
                  116  |   2.024729
                  117  |    2.05732
                  118  |   2.089942
          ------------------------------------------------------------------------------
          . 

          . mat stdp=e(b)
          . mat pred1=[stdp \ xb\ myx]'
          . svmat pred1
          . generate lb = pred12 - (`myt' * pred11) /*Prediction minus t value times SE */
          (302 missing values generated)
          . generate ub = pred12 + (`myt'* pred11) /*Prediction plus t value times SE */
          (302 missing values generated)
          . graph twoway line pred12 pred13, ///
               xtitle("Hypothetical Values of Student-Teacher Ratio") ///
               ytitle("Predicted Values of Math Test Scores") ///
               name(basic_predict_margins)

          . 

          . graph export basic_predict.`gtype', replace 
          (file /Users/doylewr/lpo_prac/lessons/s2-04-regression_prediction/basic_predict.pdf written in PDF format)
          . graph twoway line pred12 pred13 || ///
               line lb pred13,lcolor(red) || ///
               line ub pred13,lcolor(red) ///
               xtitle("Hypothetical Values of Student Teacher Ratio ") ///
               ytitle("Predicted Values of Math Test Scores") ///
               legend(order(1 "Predicted Value" 2 "Lower/Upper Bound 95% CI" )) ///
               name(ci_predict95) 

          . 

          . graph export ci_predict95.`gtype', replace 
          (file /Users/doylewr/lpo_prac/lessons/s2-04-regression_prediction/ci_predict95.pdf written in PDF format)
          . drop pred11 pred12 pred13
          . estimates restore basic_controls
          (results basic_controls are active now)
          . local dfr=e(df_r)
          . #delimit ;
          delimiter now ;
          . margins , /* init margins */    predict(xb) /* Type of prediction */    at( (mean) /* Precition at mean of all variables */    `controls' /* Set controls at mean */    `x'=(`mymin'(.1)`mymax'))  /*range from min to max of x in steps of .1 */     post  /* Post results in matrix form */         ;


          Adjusted predictions                            Number of obs     =        420
          Model VCE    : OLS

          Expression   : Linear prediction, predict(xb)

          1._at        : str             =          14
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          2._at        : str             =        14.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          3._at        : str             =        14.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          4._at        : str             =        14.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          5._at        : str             =        14.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          6._at        : str             =        14.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          7._at        : str             =        14.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          8._at        : str             =        14.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          9._at        : str             =        14.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          10._at       : str             =        14.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          11._at       : str             =          15
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          12._at       : str             =        15.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          13._at       : str             =        15.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          14._at       : str             =        15.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          15._at       : str             =        15.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          16._at       : str             =        15.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          17._at       : str             =        15.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          18._at       : str             =        15.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          19._at       : str             =        15.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          20._at       : str             =        15.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          21._at       : str             =          16
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          22._at       : str             =        16.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          23._at       : str             =        16.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          24._at       : str             =        16.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          25._at       : str             =        16.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          26._at       : str             =        16.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          27._at       : str             =        16.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          28._at       : str             =        16.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          29._at       : str             =        16.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          30._at       : str             =        16.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          31._at       : str             =          17
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          32._at       : str             =        17.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          33._at       : str             =        17.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          34._at       : str             =        17.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          35._at       : str             =        17.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          36._at       : str             =        17.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          37._at       : str             =        17.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          38._at       : str             =        17.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          39._at       : str             =        17.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          40._at       : str             =        17.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          41._at       : str             =          18
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          42._at       : str             =        18.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          43._at       : str             =        18.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          44._at       : str             =        18.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          45._at       : str             =        18.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          46._at       : str             =        18.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          47._at       : str             =        18.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          48._at       : str             =        18.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          49._at       : str             =        18.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          50._at       : str             =        18.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          51._at       : str             =          19
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          52._at       : str             =        19.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          53._at       : str             =        19.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          54._at       : str             =        19.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          55._at       : str             =        19.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          56._at       : str             =        19.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          57._at       : str             =        19.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          58._at       : str             =        19.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          59._at       : str             =        19.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          60._at       : str             =        19.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          61._at       : str             =          20
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          62._at       : str             =        20.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          63._at       : str             =        20.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          64._at       : str             =        20.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          65._at       : str             =        20.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          66._at       : str             =        20.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          67._at       : str             =        20.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          68._at       : str             =        20.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          69._at       : str             =        20.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          70._at       : str             =        20.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          71._at       : str             =          21
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          72._at       : str             =        21.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          73._at       : str             =        21.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          74._at       : str             =        21.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          75._at       : str             =        21.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          76._at       : str             =        21.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          77._at       : str             =        21.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          78._at       : str             =        21.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          79._at       : str             =        21.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          80._at       : str             =        21.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          81._at       : str             =          22
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          82._at       : str             =        22.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          83._at       : str             =        22.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          84._at       : str             =        22.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          85._at       : str             =        22.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          86._at       : str             =        22.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          87._at       : str             =        22.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          88._at       : str             =        22.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          89._at       : str             =        22.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          90._at       : str             =        22.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          91._at       : str             =          23
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          92._at       : str             =        23.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          93._at       : str             =        23.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          94._at       : str             =        23.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          95._at       : str             =        23.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          96._at       : str             =        23.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          97._at       : str             =        23.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          98._at       : str             =        23.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          99._at       : str             =        23.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          100._at      : str             =        23.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          101._at      : str             =          24
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          102._at      : str             =        24.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          103._at      : str             =        24.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          104._at      : str             =        24.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          105._at      : str             =        24.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          106._at      : str             =        24.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          107._at      : str             =        24.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          108._at      : str             =        24.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          109._at      : str             =        24.8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          110._at      : str             =        24.9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          111._at      : str             =          25
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          112._at      : str             =        25.1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          113._at      : str             =        25.2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          114._at      : str             =        25.3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          115._at      : str             =        25.4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          116._at      : str             =        25.5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          117._at      : str             =        25.6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          118._at      : str             =        25.7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          ------------------------------------------------------------------------------
                       |            Delta-method
                       |     Margin   Std. Err.      t    P>|t|     [95% Conf. Interval]
          -------------+----------------------------------------------------------------
                   _at |
                    1  |   654.5936   1.953419   335.10   0.000     650.7537    658.4335
                    2  |   654.5714   1.920935   340.76   0.000     650.7954    658.3474
                    3  |   654.5492   1.888489   346.60   0.000      650.837    658.2615
                    4  |    654.527   1.856081   352.64   0.000     650.8785    658.1756
                    5  |   654.5049   1.823715   358.89   0.000     650.9199    658.0898
                    6  |   654.4827   1.791393   365.35   0.000     650.9613    658.0041
                    7  |   654.4605   1.759116   372.04   0.000     651.0026    657.9184
                    8  |   654.4383   1.726889   378.97   0.000     651.0437    657.8329
                    9  |   654.4161   1.694712   386.15   0.000     651.0848    657.7475
                   10  |    654.394    1.66259   393.60   0.000     651.1258    657.6622
                   11  |   654.3718   1.630525   401.33   0.000     651.1666    657.5769
                   12  |   654.3496   1.598521   409.35   0.000     651.2074    657.4919
                   13  |   654.3274   1.566582   417.68   0.000      651.248    657.4069
                   14  |   654.3053   1.534712   426.34   0.000     651.2884    657.3221
                   15  |   654.2831   1.502915   435.34   0.000     651.3288    657.2374
                   16  |   654.2609   1.471195   444.71   0.000     651.3689    657.1529
                   17  |   654.2387   1.439559   454.47   0.000     651.4089    657.0685
                   18  |   654.2165   1.408011   464.64   0.000     651.4488    656.9843
                   19  |   654.1944   1.376558   475.24   0.000     651.4884    656.9003
                   20  |   654.1722   1.345207   486.30   0.000     651.5279    656.8165
                   21  |     654.15   1.313964   497.84   0.000     651.5671    656.7329
                   22  |   654.1278   1.282837   509.91   0.000     651.6061    656.6495
                   23  |   654.1056   1.251836   522.52   0.000     651.6449    656.5664
                   24  |   654.0835    1.22097   535.71   0.000     651.6834    656.4836
                   25  |   654.0613   1.190249   549.52   0.000     651.7216     656.401
                   26  |   654.0391   1.159684   563.98   0.000     651.7595    656.3187
                   27  |   654.0169   1.129289   579.14   0.000     651.7971    656.2368
                   28  |   653.9948   1.099078   595.04   0.000     651.8343    656.1552
                   29  |   653.9726   1.069066   611.72   0.000     651.8711    656.0741
                   30  |   653.9504    1.03927   629.24   0.000     651.9075    655.9933
                   31  |   653.9282    1.00971   647.64   0.000     651.9434     655.913
                   32  |    653.906   .9804069   666.97   0.000     651.9788    655.8333
                   33  |   653.8839   .9513842   687.30   0.000     652.0137     655.754
                   34  |   653.8617   .9226692   708.66   0.000      652.048    655.6754
                   35  |   653.8395   .8942904   731.13   0.000     652.0816    655.5974
                   36  |   653.8173   .8662813   754.74   0.000     652.1145    655.5202
                   37  |   653.7951    .838679   779.55   0.000     652.1465    655.4438
                   38  |    653.773   .8115251   805.61   0.000     652.1777    655.3682
                   39  |   653.7508   .7848666   832.95   0.000      652.208    655.2936
                   40  |   653.7286   .7587546   861.58   0.000     652.2371    655.2201
                   41  |   653.7064   .7332482   891.52   0.000     652.2651    655.1478
                   42  |   653.6843   .7084126   922.75   0.000     652.2917    655.0768
                   43  |   653.6621    .684321   955.20   0.000     652.3169    655.0073
                   44  |   653.6399   .6610551   988.78   0.000     652.3404    654.9394
                   45  |   653.6177   .6387042  1023.35   0.000     652.3622    654.8732
                   46  |   653.5955   .6173683  1058.68   0.000      652.382    654.8091
                   47  |   653.5734   .5971561  1094.48   0.000     652.3995    654.7472
                   48  |   653.5512   .5781854  1130.35   0.000     652.4146    654.6877
                   49  |    653.529   .5605828  1165.80   0.000     652.4271     654.631
                   50  |   653.5068   .5444801  1200.24   0.000     652.4365    654.5771
                   51  |   653.4847   .5300145  1232.96   0.000     652.4428    654.5265
                   52  |   653.4625   .5173233  1263.16   0.000     652.4456    654.4794
                   53  |   653.4403   .5065399  1290.01   0.000     652.4446     654.436
                   54  |   653.4181   .4977885  1312.64   0.000     652.4396    654.3966
                   55  |   653.3959   .4911774  1330.26   0.000     652.4304    654.3615
                   56  |   653.3738   .4867938  1342.20   0.000     652.4169    654.3307
                   57  |   653.3516   .4846984  1347.95   0.000     652.3988    654.3044
                   58  |   653.3294   .4849207  1347.29   0.000     652.3762    654.2826
                   59  |   653.3072   .4874576  1340.23   0.000      652.349    654.2654
                   60  |    653.285   .4922732  1327.08   0.000     652.3174    654.2527
                   61  |   653.2629   .4993017  1308.35   0.000     652.2814    654.2444
                   62  |   653.2407   .5084513  1284.77   0.000     652.2412    654.2402
                   63  |   653.2185     .51961  1257.13   0.000     652.1971    654.2399
                   64  |   653.1963   .5326513  1226.31   0.000     652.1493    654.2434
                   65  |   653.1742    .547441  1193.14   0.000      652.098    654.2503
                   66  |    653.152   .5638415  1158.40   0.000     652.0436    654.2603
                   67  |   653.1298   .5817165  1122.76   0.000     651.9863    654.2733
                   68  |   653.1076   .6009344  1086.82   0.000     651.9264    654.2889
                   69  |   653.0854   .6213703  1051.04   0.000      651.864    654.3069
                   70  |   653.0633   .6429087  1015.79   0.000     651.7995     654.327
                   71  |   653.0411   .6654422   981.36   0.000      651.733    654.3492
                   72  |   653.0189   .6888733   947.95   0.000     651.6648     654.373
                   73  |   652.9967   .7131135   915.70   0.000     651.5949    654.3985
                   74  |   652.9746   .7380824   884.69   0.000     651.5237    654.4254
                   75  |   652.9524   .7637097   854.97   0.000     651.4511    654.4536
                   76  |   652.9302   .7899308   826.57   0.000     651.3774     654.483
                   77  |    652.908   .8166884   799.46   0.000     651.3026    654.5134
                   78  |   652.8858   .8439316   773.62   0.000     651.2269    654.5448
                   79  |   652.8637   .8716143   749.03   0.000     651.1503     654.577
                   80  |   652.8415   .8996969   725.62   0.000     651.0729      654.61
                   81  |   652.8193   .9281427   703.36   0.000     650.9948    654.6438
                   82  |   652.7971   .9569193   682.19   0.000     650.9161    654.6782
                   83  |   652.7749   .9859976   662.05   0.000     650.8367    654.7131
                   84  |   652.7528   1.015351   642.88   0.000     650.7569    654.7487
                   85  |   652.7306   1.044958   624.65   0.000     650.6765    654.7847
                   86  |   652.7084   1.074797   607.29   0.000     650.5957    654.8212
                   87  |   652.6862   1.104848   590.75   0.000     650.5144    654.8581
                   88  |   652.6641   1.135096   574.99   0.000     650.4328    654.8953
                   89  |   652.6419   1.165524   559.96   0.000     650.3508     654.933
                   90  |   652.6197    1.19612   545.61   0.000     650.2685    654.9709
                   91  |   652.5975   1.226869   531.92   0.000     650.1858    655.0092
                   92  |   652.5753   1.257763   518.84   0.000     650.1029    655.0478
                   93  |   652.5532   1.288789   506.33   0.000     650.0198    655.0866
                   94  |    652.531   1.319938   494.37   0.000     649.9364    655.1256
                   95  |   652.5088   1.351202   482.91   0.000     649.8527    655.1649
                   96  |   652.4866   1.382574   471.94   0.000     649.7689    655.2044
                   97  |   652.4645   1.414045   461.42   0.000     649.6848    655.2441
                   98  |   652.4423   1.445611   451.33   0.000     649.6006    655.2839
                   99  |   652.4201   1.477263   441.64   0.000     649.5162     655.324
                  100  |   652.3979   1.508998   432.34   0.000     649.4316    655.3642
                  101  |   652.3757   1.540809   423.40   0.000     649.3469    655.4045
                  102  |   652.3536   1.572693   414.80   0.000     649.2621     655.445
                  103  |   652.3314   1.604645   406.53   0.000     649.1771    655.4857
                  104  |   652.3092    1.63666   398.56   0.000      649.092    655.5264
                  105  |    652.287   1.668736   390.89   0.000     649.0067    655.5673
                  106  |   652.2648   1.700869   383.49   0.000     648.9214    655.6083
                  107  |   652.2427   1.733056   376.35   0.000      648.836    655.6494
                  108  |   652.2205   1.765294   369.47   0.000     648.7504    655.6906
                  109  |   652.1983   1.797579   362.82   0.000     648.6648    655.7319
                  110  |   652.1761    1.82991   356.40   0.000      648.579    655.7732
                  111  |    652.154   1.862284   350.19   0.000     648.4932    655.8147
                  112  |   652.1318   1.894699   344.19   0.000     648.4073    655.8562
                  113  |   652.1096   1.927153   338.38   0.000     648.3213    655.8979
                  114  |   652.0874   1.959643   332.76   0.000     648.2353    655.9395
                  115  |   652.0652   1.992169   327.31   0.000     648.1492    655.9813
                  116  |   652.0431   2.024729   322.04   0.000      648.063    656.0231
                  117  |   652.0209    2.05732   316.93   0.000     647.9768     656.065
                  118  |   651.9987   2.089942   311.97   0.000     647.8905     656.107
          ------------------------------------------------------------------------------
          . #delimit cr
          delimiter now cr
          . marginsplot , recast(line) plotopts(lcolor(black)) recastci(rarea)  

            Variables that uniquely identify margins: str
          . 

          . }/* End first part */

          . if `second_part'==1{

Forecasting
-----------

Forecasting is distinct from prediction in the parlance of regression.
The prediction interval is all about how different the regression line
is likely to be in repeated samples. The forecast interval is all about
how well the model predicts the location of individual points. A 95%
confidence interval around the regression line says:
`In 95 percent of repeated samples, an interval calculated in this way will include the true value of the regression line.'' A 95\% forecast interval around the regression line says`In
95 percent of repeated samples, an interval calculated in this way will
include all but 5 percent of observations.''

The process for generating these lines is very similar to the one we
just went through, with the exception that we'll be using \texttt{stdf},
the standrad error of the forecast, as opposed to \texttt{stdp}, the
standard error of the prediction.

Here's what the forecast interval looks like for us, when predicting
using available data:

          . drop yhat* *ci
          . estimates restore basic
          (results basic are active now)
          . predict yhat, xb
          . predict yhat_se,stdp
          . predict yhat_fse,stdf
          . gen low_ci=yhat-(myt*yhat_se)
          . gen hi_ci=yhat+(myt*yhat_se)
          . gen low_ci_f=yhat-(myt*yhat_fse)
          . gen hi_ci_f=yhat+(myt*yhat_fse)
          . sort `x'
          . graph twoway scatter `y' `x',msize(small) mcolor(blue)  ///
             || line yhat `x',lcolor(red) ///
             || line low_ci `x', lcolor(red) lpattern(dash) ///
             || line hi_ci `x', lcolor(red) lpattern(dash) ///
             || line low_ci_f `x', lcolor(green) lpattern(dash) ///
             || line hi_ci_f `x', lcolor(green) lpattern (dash) ///
               legend( order(1 "Math score" 2 "Prediction" 3 "95% Confidence Interval, Prediction" 5 "95% Confidence Interval, Forecast"))

          . 

          . graph export predictvforecast.`gtype', replace
          (file /Users/doylewr/lpo_prac/lessons/s2-04-regression_prediction/predictvforecast.pdf written in PDF format)
          . gen outside=`y' < low_ci_f | `y' >hi_ci_f
          . egen total_out=sum(outside)
          . sum total_out

              Variable |        Obs        Mean    Std. Dev.       Min        Max
          -------------+---------------------------------------------------------
             total_out |        420          20           0         20         20
          . scalar my_out=r(mean)
          . scalar myn=_N
          . scalar pct_out=my_out/myn
          . scalar li pct_out
             pct_out =  .04761905
          . estimates restore basic_controls
          (results basic_controls are active now)

With hypothetical data, we're forecasting out of range, and so the
intervals are going to be quite wide.

          . sum `x', detail

                              Student Teacher Ratio
          -------------------------------------------------------------
                Percentiles      Smallest
           1%     15.13898             14
           5%     16.41658       14.20176
          10%     17.34573       14.54214       Obs                 420
          25%     18.58179       14.70588       Sum of Wgt.         420

          50%     19.72321                      Mean           19.64043
                                  Largest       Std. Dev.      1.891812
          75%     20.87183          24.95
          90%     21.87561       25.05263       Variance       3.578952
          95%     22.64514       25.78512       Skewness      -.0253655
          99%     24.88889           25.8       Kurtosis       3.609597
          . local mymin=0
          . local mymax=100
          . local diff=`mymax'-`mymin'
          . local step=`diff'/100
          . estimates restore basic_controls
          (results basic_controls are active now)
          . local dfr=e(df_r)
          . margins , predict(xb) nose at( (mean) `controls' `x'=(`mymin'(`step')`mymax')) post

          Adjusted predictions                            Number of obs     =        420

          Expression   : Linear prediction, predict(xb)

          1._at        : str             =           0
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          2._at        : str             =           1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          3._at        : str             =           2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          4._at        : str             =           3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          5._at        : str             =           4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          6._at        : str             =           5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          7._at        : str             =           6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          8._at        : str             =           7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          9._at        : str             =           8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          10._at       : str             =           9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          11._at       : str             =          10
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          12._at       : str             =          11
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          13._at       : str             =          12
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          14._at       : str             =          13
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          15._at       : str             =          14
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          16._at       : str             =          15
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          17._at       : str             =          16
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          18._at       : str             =          17
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          19._at       : str             =          18
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          20._at       : str             =          19
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          21._at       : str             =          20
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          22._at       : str             =          21
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          23._at       : str             =          22
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          24._at       : str             =          23
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          25._at       : str             =          24
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          26._at       : str             =          25
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          27._at       : str             =          26
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          28._at       : str             =          27
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          29._at       : str             =          28
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          30._at       : str             =          29
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          31._at       : str             =          30
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          32._at       : str             =          31
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          33._at       : str             =          32
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          34._at       : str             =          33
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          35._at       : str             =          34
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          36._at       : str             =          35
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          37._at       : str             =          36
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          38._at       : str             =          37
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          39._at       : str             =          38
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          40._at       : str             =          39
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          41._at       : str             =          40
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          42._at       : str             =          41
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          43._at       : str             =          42
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          44._at       : str             =          43
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          45._at       : str             =          44
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          46._at       : str             =          45
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          47._at       : str             =          46
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          48._at       : str             =          47
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          49._at       : str             =          48
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          50._at       : str             =          49
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          51._at       : str             =          50
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          52._at       : str             =          51
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          53._at       : str             =          52
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          54._at       : str             =          53
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          55._at       : str             =          54
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          56._at       : str             =          55
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          57._at       : str             =          56
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          58._at       : str             =          57
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          59._at       : str             =          58
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          60._at       : str             =          59
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          61._at       : str             =          60
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          62._at       : str             =          61
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          63._at       : str             =          62
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          64._at       : str             =          63
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          65._at       : str             =          64
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          66._at       : str             =          65
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          67._at       : str             =          66
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          68._at       : str             =          67
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          69._at       : str             =          68
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          70._at       : str             =          69
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          71._at       : str             =          70
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          72._at       : str             =          71
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          73._at       : str             =          72
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          74._at       : str             =          73
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          75._at       : str             =          74
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          76._at       : str             =          75
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          77._at       : str             =          76
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          78._at       : str             =          77
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          79._at       : str             =          78
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          80._at       : str             =          79
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          81._at       : str             =          80
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          82._at       : str             =          81
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          83._at       : str             =          82
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          84._at       : str             =          83
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          85._at       : str             =          84
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          86._at       : str             =          85
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          87._at       : str             =          86
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          88._at       : str             =          87
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          89._at       : str             =          88
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          90._at       : str             =          89
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          91._at       : str             =          90
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          92._at       : str             =          91
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          93._at       : str             =          92
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          94._at       : str             =          93
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          95._at       : str             =          94
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          96._at       : str             =          95
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          97._at       : str             =          96
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          98._at       : str             =          97
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          99._at       : str             =          98
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          100._at      : str             =          99
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          101._at      : str             =         100
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          ------------------------------------------------------------------------------
                       |     Margin
          -------------+----------------------------------------------------------------
                   _at |
                    1  |   657.6985
                    2  |   657.4767
                    3  |    657.255
                    4  |   657.0332
                    5  |   656.8114
                    6  |   656.5896
                    7  |   656.3678
                    8  |   656.1461
                    9  |   655.9243
                   10  |   655.7025
                   11  |   655.4807
                   12  |   655.2589
                   13  |   655.0371
                   14  |   654.8154
                   15  |   654.5936
                   16  |   654.3718
                   17  |     654.15
                   18  |   653.9282
                   19  |   653.7064
                   20  |   653.4847
                   21  |   653.2629
                   22  |   653.0411
                   23  |   652.8193
                   24  |   652.5975
                   25  |   652.3757
                   26  |    652.154
                   27  |   651.9322
                   28  |   651.7104
                   29  |   651.4886
                   30  |   651.2668
                   31  |    651.045
                   32  |   650.8233
                   33  |   650.6015
                   34  |   650.3797
                   35  |   650.1579
                   36  |   649.9361
                   37  |   649.7143
                   38  |   649.4926
                   39  |   649.2708
                   40  |    649.049
                   41  |   648.8272
                   42  |   648.6054
                   43  |   648.3836
                   44  |   648.1619
                   45  |   647.9401
                   46  |   647.7183
                   47  |   647.4965
                   48  |   647.2747
                   49  |   647.0529
                   50  |   646.8312
                   51  |   646.6094
                   52  |   646.3876
                   53  |   646.1658
                   54  |    645.944
                   55  |   645.7222
                   56  |   645.5005
                   57  |   645.2787
                   58  |   645.0569
                   59  |   644.8351
                   60  |   644.6133
                   61  |   644.3915
                   62  |   644.1698
                   63  |    643.948
                   64  |   643.7262
                   65  |   643.5044
                   66  |   643.2826
                   67  |   643.0609
                   68  |   642.8391
                   69  |   642.6173
                   70  |   642.3955
                   71  |   642.1737
                   72  |   641.9519
                   73  |   641.7302
                   74  |   641.5084
                   75  |   641.2866
                   76  |   641.0648
                   77  |    640.843
                   78  |   640.6212
                   79  |   640.3995
                   80  |   640.1777
                   81  |   639.9559
                   82  |   639.7341
                   83  |   639.5123
                   84  |   639.2905
                   85  |   639.0688
                   86  |    638.847
                   87  |   638.6252
                   88  |   638.4034
                   89  |   638.1816
                   90  |   637.9598
                   91  |   637.7381
                   92  |   637.5163
                   93  |   637.2945
                   94  |   637.0727
                   95  |   636.8509
                   96  |   636.6291
                   97  |   636.4074
                   98  |   636.1856
                   99  |   635.9638
                  100  |    635.742
                  101  |   635.5202
          ------------------------------------------------------------------------------
          . 

          . mat xb=e(b)
          . mat allx=e(at)
          . matrix myx=allx[1...,1]'
          . estimates restore basic_controls
          (results basic_controls are active now)
          . margins , predict(stdf) nose at(`x'=(`mymin'(`step')`mymax') (mean) `controls') post

          Adjusted predictions                            Number of obs     =        420

          Expression   : S.E. of the forecast, predict(stdf)

          1._at        : str             =           0
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          2._at        : str             =           1
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          3._at        : str             =           2
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          4._at        : str             =           3
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          5._at        : str             =           4
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          6._at        : str             =           5
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          7._at        : str             =           6
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          8._at        : str             =           7
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          9._at        : str             =           8
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          10._at       : str             =           9
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          11._at       : str             =          10
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          12._at       : str             =          11
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          13._at       : str             =          12
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          14._at       : str             =          13
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          15._at       : str             =          14
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          16._at       : str             =          15
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          17._at       : str             =          16
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          18._at       : str             =          17
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          19._at       : str             =          18
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          20._at       : str             =          19
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          21._at       : str             =          20
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          22._at       : str             =          21
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          23._at       : str             =          22
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          24._at       : str             =          23
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          25._at       : str             =          24
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          26._at       : str             =          25
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          27._at       : str             =          26
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          28._at       : str             =          27
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          29._at       : str             =          28
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          30._at       : str             =          29
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          31._at       : str             =          30
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          32._at       : str             =          31
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          33._at       : str             =          32
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          34._at       : str             =          33
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          35._at       : str             =          34
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          36._at       : str             =          35
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          37._at       : str             =          36
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          38._at       : str             =          37
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          39._at       : str             =          38
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          40._at       : str             =          39
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          41._at       : str             =          40
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          42._at       : str             =          41
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          43._at       : str             =          42
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          44._at       : str             =          43
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          45._at       : str             =          44
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          46._at       : str             =          45
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          47._at       : str             =          46
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          48._at       : str             =          47
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          49._at       : str             =          48
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          50._at       : str             =          49
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          51._at       : str             =          50
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          52._at       : str             =          51
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          53._at       : str             =          52
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          54._at       : str             =          53
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          55._at       : str             =          54
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          56._at       : str             =          55
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          57._at       : str             =          56
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          58._at       : str             =          57
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          59._at       : str             =          58
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          60._at       : str             =          59
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          61._at       : str             =          60
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          62._at       : str             =          61
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          63._at       : str             =          62
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          64._at       : str             =          63
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          65._at       : str             =          64
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          66._at       : str             =          65
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          67._at       : str             =          66
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          68._at       : str             =          67
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          69._at       : str             =          68
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          70._at       : str             =          69
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          71._at       : str             =          70
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          72._at       : str             =          71
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          73._at       : str             =          72
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          74._at       : str             =          73
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          75._at       : str             =          74
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          76._at       : str             =          75
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          77._at       : str             =          76
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          78._at       : str             =          77
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          79._at       : str             =          78
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          80._at       : str             =          79
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          81._at       : str             =          80
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          82._at       : str             =          81
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          83._at       : str             =          82
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          84._at       : str             =          83
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          85._at       : str             =          84
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          86._at       : str             =          85
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          87._at       : str             =          86
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          88._at       : str             =          87
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          89._at       : str             =          88
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          90._at       : str             =          89
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          91._at       : str             =          90
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          92._at       : str             =          91
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          93._at       : str             =          92
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          94._at       : str             =          93
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          95._at       : str             =          94
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          96._at       : str             =          95
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          97._at       : str             =          96
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          98._at       : str             =          97
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          99._at       : str             =          98
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          100._at      : str             =          99
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          101._at      : str             =         100
                         expn_stu_t      =    5.312408 (mean)
                         avginc          =    15.31659 (mean)
                         el_pct          =    15.76816 (mean)
                         meal_pct        =    44.70524 (mean)
                         comp_stu        =    .1359266 (mean)

          ------------------------------------------------------------------------------
                       |     Margin
          -------------+----------------------------------------------------------------
                   _at |
                    1  |   11.92684
                    2  |   11.74481
                    3  |   11.56965
                    4  |   11.40167
                    5  |   11.24119
                    6  |   11.08855
                    7  |   10.94407
                    8  |   10.80807
                    9  |   10.68088
                   10  |   10.56283
                   11  |   10.45421
                   12  |   10.35532
                   13  |   10.26646
                   14  |   10.18787
                   15  |    10.1198
                   16  |   10.06246
                   17  |   10.01603
                   18  |   9.980678
                   19  |   9.956509
                   20  |   9.943607
                   21  |   9.942018
                   22  |   9.951745
                   23  |   9.972756
                   24  |   10.00498
                   25  |   10.04831
                   26  |    10.1026
                   27  |   10.16768
                   28  |   10.24333
                   29  |   10.32934
                   30  |   10.42544
                   31  |   10.53135
                   32  |   10.64679
                   33  |   10.77145
                   34  |     10.905
                   35  |   11.04713
                   36  |   11.19752
                   37  |   11.35583
                   38  |   11.52173
                   39  |   11.69491
                   40  |   11.87504
                   41  |   12.06182
                   42  |   12.25494
                   43  |    12.4541
                   44  |   12.65903
                   45  |   12.86943
                   46  |   13.08506
                   47  |   13.30565
                   48  |   13.53097
                   49  |   13.76078
                   50  |   13.99486
                   51  |   14.23299
                   52  |   14.47499
                   53  |   14.72066
                   54  |   14.96981
                   55  |   15.22228
                   56  |   15.47791
                   57  |   15.73653
                   58  |   15.99801
                   59  |   16.26221
                   60  |     16.529
                   61  |   16.79825
                   62  |   17.06985
                   63  |   17.34368
                   64  |   17.61965
                   65  |   17.89765
                   66  |   18.17759
                   67  |   18.45939
                   68  |   18.74295
                   69  |    19.0282
                   70  |   19.31507
                   71  |   19.60348
                   72  |   19.89337
                   73  |   20.18468
                   74  |   20.47733
                   75  |   20.77128
                   76  |   21.06648
                   77  |   21.36286
                   78  |   21.66039
                   79  |     21.959
                   80  |   22.25867
                   81  |   22.55935
                   82  |     22.861
                   83  |   23.16358
                   84  |   23.46706
                   85  |   23.77139
                   86  |   24.07656
                   87  |   24.38252
                   88  |   24.68925
                   89  |   24.99671
                   90  |   25.30489
                   91  |   25.61376
                   92  |   25.92329
                   93  |   26.23346
                   94  |   26.54424
                   95  |   26.85562
                   96  |   27.16757
                   97  |   27.48008
                   98  |   27.79313
                   99  |   28.10669
                  100  |   28.42075
                  101  |    28.7353
          ------------------------------------------------------------------------------
          . 

          . mat stdf=e(b)
          . mat pred1=[stdf \ xb\ myx]'
          . svmat pred1
          . drop lb ub
          . generate lb = pred12 - (`myt' * pred11) /*Prediction minus t value times SE */
          (319 missing values generated)
          . generate ub = pred12 +  (`myt' * pred11) /*Prediction plus t value times SE */
          (319 missing values generated)
          . graph twoway line pred12 pred13 || ///
               line lb pred13,lcolor(red) || ///
               line ub pred13,lcolor(red) ///
               xtitle("Hypothetical Values of Student-Teacher Ratio") ///
               ytitle("Predicted Values of Math Test Scores") ///
               legend(order(1 "Predicted Value" 2 "Lower/Upper Bound 95% CI" )) ///
               name(ci_predict95_b)

          . 

          . graph export ci_predict95_forecast.`gtype', replace 
          (file /Users/doylewr/lpo_prac/lessons/s2-04-regression_prediction/ci_predict95_forecast.pdf written in PDF format)

The point is that we should approach these results with some humility.
Too often, we don't take forecast intervals very seriously. Predictions
are made on \`\`average'' using the conditional expectation function. If
you're going to forecast for an individual unit--- a person, a school, a
state--- you need to acknowledge that the uncertainty is likely to be
large.

          . } /* End part 2 */
