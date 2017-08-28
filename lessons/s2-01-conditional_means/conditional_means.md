Regression and Conditional Means
================
LPO 9952 | Spring 2017

Unconditional Means as a Prediction
-----------------------------------

In most of our day-to-day thinking, we use unconditional means as the basis for making pre- dictions. For instance, if I asked you to predict the temperature on June 1st of this year, you’d most likely simply say it would be the average temperature for that day or that time of year.

In the example below, I calculate the mean of math test scores in the plans dataset and use it as a prediction. I calculate the error term, then calculate the mean squared error (which is exactly what it sounds like) as a measure of how good this prediction is. As the graphic shows, the mean is a pretty terrible predictor for most people.

    . sort byses1

    . graph twoway scatter bynels2m byses1, msize(vtiny)

    . egen uncond_mean=mean(bynels2m)

    . gen uncond_mean_error=bynels2m-uncond_mean
    (276 missing values generated)

    . gen uncond_mean_error_sq=uncond_mean_error*uncond_mean_error
    (276 missing values generated)

    . quietly sum uncond_mean_error_sq

    . scalar uncond_mean_mse=r(mean)

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >     (line uncond_mean byses1,lcolor(blue)), legend(order(2 "Unconditional M
    > ean"))

    . graph export "uncond_mean.`gtype'", replace
    (file uncond_mean.eps written in EPS format)

<img src = "uncond_mean.png" />

*Quick Exercise* Calculate the mean of reading scores by ses, then make a prediction and calculate the mean squared error. Plot the result.

Predictions Using Conditional Means: 2 Groups
---------------------------------------------

With condtional means, we start using more information to think about how we will make our prediction. One of the simplest ways to do this in a bivariate sense is to calculate the mean of the dependent variable for individuals who are above average and below average.

Here’s a plot of the condtional mean of math scores by SES, for above average and below average SES.

    . egen sesq2=cut(byses1), group(2)
    (924 missing values generated)

    . egen cond_mean2=mean(bynels2m), by(sesq2)

    . gen cond_mean2_error=bynels2m-cond_mean2
    (276 missing values generated)

    . gen cond_mean2_error_sq=cond_mean2_error*cond_mean2_error
    (276 missing values generated)

    . quietly sum cond_mean2_error_sq

    . scalar cond_mean2_mse=r(mean)

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >              (line uncond_mean byses1,lcolor(blue)) ///
    >              (line cond_mean2 byses1,lcolor(orange)), ///
    >               legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 gro
    > ups") )

    . graph export "cond_mean2.`gtype'", replace
    (file cond_mean2.eps written in EPS format)

<img src = "cond_mean2.png" />

*Quick Exercise* Calculate the mean of reading scores by 2 levels of ses, then make predictions and calculate the mean squared error. Plot the result.

Predictions Using Conditional Means: 4 Groups
---------------------------------------------

We can continue with this logic through any number of arbitrary subdivsitons. Here’s a plot of the conditional mean of math scores by SES by quartile.

    . egen sesq4=cut(byses1), group(4)
    (924 missing values generated)

    . egen cond_mean4=mean(bynels2m), by(sesq4)

    . gen cond_mean4_error=bynels2m-cond_mean4
    (276 missing values generated)

    . gen cond_mean4_error_sq=cond_mean4_error*cond_mean2_error
    (276 missing values generated)

    . quietly sum cond_mean4_error_sq

    . scalar cond_mean4_mse=r(mean)

    . scalar li
    cond_mean10_mse =  .03228102
       reg_mse =  .01506973
    cond_mean4_mse =  .01528936
    cond_mean2_mse =  .01600496
    uncond_mean_mse_read =  .01832291
    uncond_mean_mse =  .01832291

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >              (line uncond_mean byses1,lcolor(blue)) ///
    >              (line cond_mean2 byses1,lcolor(orange)) ///
    >              (line cond_mean4 byses1,lcolor(yellow)), ///    
    >              legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 grou
    > ps" 4 "Conditional Mean, 4 Groups") )

    . graph export "cond_mean4.`gtype'", replace
    (file cond_mean4.eps written in EPS format)

<img src = "cond_mean4.png" />

*Quick Exercise* Calculate the mean of reading scores by 4 levels of ses, then make predictions and calculate the mean squared error. Plot the result.

Predictions Using Conditional Means: 10 Groups
----------------------------------------------

This logic can be extended indefinitely. For instance, here's a plot of the conditional mean of math scores at 10 different levels of SES.

    . egen sesq10=cut(byses1), group(10)
    (924 missing values generated)

    . egen cond_mean_10_math=mean(bynels2m), by(sesq10)

    . gen cond_mean10_error=bynels2r-cond_mean_10
    (276 missing values generated)

    . gen cond_mean10_error_sq=cond_mean10_error*cond_mean10_error
    (276 missing values generated)

    . quietly sum cond_mean10_error_sq

    . scalar cond_mean10_mse=r(mean)

    . // scalar li
    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >              (line uncond_mean byses1,lcolor(blue)) ///
    >              (line cond_mean2 byses1,lcolor(orange)) ///
    >              (line cond_mean4 byses1,lcolor(yellow)) ///  
    >                          (line cond_mean_10_math byses1,lcolor(purple)), //
    > /  
    >              legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 grou
    > ps" 4 "Conditional Mean, 4 Groups" 5 "Conditional Mean, 10 Groups"))

    . graph export "cond_mean10.`gtype'", replace
    (file cond_mean10.eps written in EPS format)

*Quick Exercise* Calculate the mean of reading scores by 20 levels of ses, then make predictions and calculate the mean squared error. Plot the result.

Regression is the conditional mean for ALL X's
----------------------------------------------

Regression is based on the idea of the expected value of y given, E(Y |X). If X can take on only two values, then regression will give two predictions. If X can take on 4, then it will give that many, based on the existing data. What regression does is calculate an expected value of Y at every level of X. The constraint is that the fit must be linear: it can only summarize the data using a straight line, set by two parameters (intercept and slope). How it does this is the subject of your regression class this semester.

Below, I regress math scores on SES, then predict math scores at every observed level of SES. I then plot this prediction.

    . reg bynels2m byses1

          Source |       SS       df       MS              Number of obs =   1523
    > 6
    -------------+------------------------------           F(  1, 15234) = 3532.1
    > 8
           Model |  53.2360435     1  53.2360435           Prob > F      =  0.000
    > 0
        Residual |    229.6024 15234  .015071708           R-squared     =  0.188
    > 2
    -------------+------------------------------           Adj R-squared =  0.188
    > 2
           Total |  282.838444 15235  .018565044           Root MSE      =  .1227
    > 7

    -----------------------------------------------------------------------------
    > -
        bynels2m |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval
    > ]
    -------------+---------------------------------------------------------------
    > -
          byses1 |   .0795636   .0013387    59.43   0.000     .0769396    .082187
    > 7
           _cons |   .4504293   .0009962   452.15   0.000     .4484766    .452381
    > 9
    -----------------------------------------------------------------------------
    > -

    . predict reg_predict
    (option xb assumed; fitted values)
    (924 missing values generated)

    . predict reg_error, residual
    (924 missing values generated)

    . gen reg_error_sq=reg_error*reg_error
    (924 missing values generated)

    . quietly sum reg_error_sq

    . scalar reg_mse=r(mean)

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >              (line uncond_mean byses1,lcolor(blue)) ///
    >              (line cond_mean2 byses1,lcolor(orange)) ///
    >              (line cond_mean4 byses1,lcolor(yellow)) ///
    >              (line reg_predict byses1,lcolor(red)), ///        
    >              legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 grou
    > ps" 4 "Conditional Mean, 4 Groups" 5 "Regression Prediction") )

    . graph export "regress.`gtype'", replace
    (file regress.eps written in EPS format)

    . scalar li
    cond_mean10_mse =  .03228102
       reg_mse =  .01506973
    cond_mean4_mse =  .01528936
    cond_mean2_mse =  .01600496
    uncond_mean_mse_read =  .01832291
    uncond_mean_mse =  .01832291

    end of do-file

<img src = "regress.png" />

*Quick Exercise* Use regression to predict reading scores. Compare the mse from your regression to the mse from the other methods used. What do you observe?
