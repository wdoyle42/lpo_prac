capture log close

// Assignment4 followup
// 2022-02-24


**Assignment 4**

/*Prediction is central to the interpretation of regression results. In
this exercise, you'll be asked to conduct a cost benefit analysis of
changing the student-teacher ratio in California using both prediction and forecasting.*/

/*
1.  Using the California schools dataset, estimate a model that
    identifies the predicted impact of an additional student per
    teacher, controlling for expenditures per
    student, cal works percent, and free/reduced meal percent on
    test scores. Create a graphic that shows the predicted impact of
    increasing the number of students per teacher over its range with uncertainty
    around the prediction.*/
	
use caschool_new, clear 	
	
la var expn_stu_t "Expenditure/Student (1000s)"	
	
local y testscr

local x str

local controls 	expn_stu_t calw_pct meal_pct
	
reg `y' `x'

estimates store basic	
	
reg `y' `x' `controls'

estimates store basic_controls
	

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

		
estimates restore basic_controls

graph twoway (lfitci `y' `x') (scatter `y' `x')


sum `x', detail

local mymin= r(min)
local mymax= r(max)
local diff=`mymax'-`mymin'
local step=`diff'/100

estimates restore basic_controls

margins , predict(xb) at((mean) `controls'  `x'=(`mymin'(`step')`mymax'))

marginsplot, recast(line) plotopts(lcolor(black)) recastci(rarea) ciopts(fcolor(gray%50))



/*2.  Assume that a policy has been suggested that will lower class sizes by 5 students per teacher.
    Holding all another values at a reasonable level, predict the impact
    of this increase on student test scores at the district level, with
    an appropriate statement of uncertainty. Remember that what you'll
    need to be doing here is forecasting. Assume that you'll be going
    from the current value to 5 students lower. */

sum `x', detail
local mean_x=r(mean)
local mean_less_5=`mean_x'-5
	
estimates restore basic_controls

margins, predict(xb) at((mean) _all `x'=(`mean_x' `mean_less_5')) post

mat pred_basic=e(b)
	
		
estimates restore basic_controls

margins, predict(stdf) nose at((mean) _all `x'=(`mean_x' `mean_less_5')) post	

mat pred_basic_se=e(b)

mat pred_basic_all=[pred_basic\pred_basic_se]'

//Turn that into data

svmat pred_basic_all

gen pred_basic_lo=pred_basic_all1-(1.96*pred_basic_all2)

gen pred_basic_hi=pred_basic_all1+(1.96*pred_basic_all2)

// The model predicts that if a district were to reduce class sizes by student per teacher, the test scores would increase by about 2 points. The prediction interval goes from 638 ton 674, which is roughly equivalent to going from the 25th percentile to the 75th percentile of test scores. 




/*3.  The legislature is now debating a range of policies, from an
    decrease of 5 students to a decrease of 10 students per teacher. Predict the
    impact of an increase from the minimum suggested level to the
    maximum suggested level, again with an appropriate statement
    of uncertainty. Plot the result in a manner appropriate for
    presentation to an interested lay audience.*/

sum `x', detail
local current_policy=r(mean)
local max_change=`current_policy'-10

estimates restore basic_controls

margins, predict(xb) at((mean) _all `x'=(`current_policy'(.1)`max_change')) post

mat pred_max_change=e(b)

mat allx=e(at)

mat myx=allx[1...,1]'
			
estimates restore basic_controls

margins, predict(stdf) nose at((mean) _all `x'=(`current_policy'(.1)`max_change')) post	

mat pred_max_change_se=e(b)

mat pred_max_change_all=[pred_max_change\pred_max_change_se\myx]'

//Turn that into data

svmat pred_max_change_all

gen pred_max_change_lo=pred_max_change_all1-(1.96*pred_max_change_all2)

gen pred_max_change_hi=pred_max_change_all1+(1.96*pred_max_change_all2)

graph twoway (line pred_max_change_all1  pred_max_change_all3) ///
 (rarea  pred_max_change_lo pred_max_change_hi  pred_max_change_all3, ///
 fcolor(gray%50) lwidth(0)) 
 
 // The coefficient for student teacher ratio in the fully specifiedd model is not statistically significant. The prediction form the model for the proposed change suggests that test scores might increase by about 4 points if the number of students per teacher were 10 lower than they are currently.  However, the forecast interval for any given district is quite wide. Even given a substantial change in policy, the forecasted change for a single school indicates that test scores could be within a range encompassing the 25th to the 75th percentile of current test scores. This means we're still very uncertain about where an individual school district might end up after this change in policy. 
 

	
exit	

/*5.  In a separate document, comment on the coefficients estimated in the
    model, including their direction and significance. Report the
    results of your predictions, interpreting them for an interested
    policy audience.  Then describe the uncertainty around your forecast of increasing from the current ratio to the lower level. Make sure to include a graphic for your state legislator.
	*/

Turn this in as s2_04_assignment_<yourlastname>.do, s2_04_assignment_<yourlastname>.docx, example:04_assignment_doyle.do
