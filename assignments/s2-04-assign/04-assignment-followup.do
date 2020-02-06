capture log close 

graph drop _all

// Assignment 4
// Prediction with forecast ci
// Will Doyle
// Github Repo

use ../../data/caschool, clear

// Using the California schools dataset, estimate a model that identifies 
// the predicted impact of an additional student per teacher, controlling for 
// expenditures per student, cal works percent, and free/reduced meal percent on test scores.
// Create a graphic that shows the predicted impact of increasing 
// the number of students per teacher over its range with uncertainty around the prediction.


local y testscr

local x str

local controls expn_stu calw_pct meal_pct

eststo test_estimates: reg `y' `x' `controls'

local alpha=.05

local alpha_2=`alpha'/2

local df_r=e(df_r)

//Get correct t value
local myt=invttail(`df_r',`alpha_2')

sum `x'

local min=r(min) // Stores minimum of key iv, student teacher ratio
local max=r(max) // Stores max of key iv, student teacher ratio
local diff=`min'-`max' // Calculates difference between min and max
local step=`diff'/100 // Divides difference by 100, giving us a value for "steps" from min to max

estimates restore test_estimates

margins ,  /// /* init margins */
    predict(xb) /// /* Type of prediction */
     at( (mean)  `controls' ///  /* Set controls at mean */
    `x'=(`min'(`step')`max'))  /// /*range from min to max of x in steps of .1 */
     post  /* Post results in matrix form */

	 
marginsplot, recast(line) recastci(rarea) ciopts(col(pink*.25))


// Assume that a policy has been suggested that will lower class sizes by 5 students per teacher.
// Holding all another values at a reasonable level, predict the impact of this 
//increase on student test scores at the district level, with an appropriate statement of
// uncertainty. Remember that what you’ll need to be doing here is forecasting. 
//Assume that you’ll be going from the current value to 5 students lower.

sum `x'

local min=r(mean)-5 // Stores minimum of key iv, student teacher ratio
local max=r(mean) // Stores max of key iv, student teacher ratio
local diff=`min'-`max' // Calculates difference between min and max
local step=`diff'/100 // Divides difference by 100, giving us a value for "steps" from min to max

estimates restore test_estimates

// Run margins to gnerate predicted values 

margins ,  /// /* init margins */
    predict(xb) /// /* Type of prediction */
     at( (mean)  `controls' ///  /* Set controls at mean */
    `x'=(`min'(`step')`max'))  /// /*range from min to max of x in steps of diff */
     post  /* Post results in matrix form */

// Pull results
mat xb=e(b)

// store x values used to generate predictions
mat allx=e(at)

// store just x values from that matrix
matrix myx=allx[1...,1]'
	 
// Now need forecast standard errors

estimates restore test_estimates

margins ,  /// /* init margins */
    predict(stdf) /// /* Type of prediction */
	nose /// /* Don't need se of se */
     at( (mean)  `controls' ///  /* Set controls at mean */
    `x'=(`min'(`step')`max'))  /// /*range from min to max of x in steps of diff */
     post  /* Post results in matrix form */

mat stdf=e(b) // Save se forecast

mat predict_matrix=[stdf \ xb\ myx]' //combine se forecast with prediction (xb) and x (myx) then transpose


svmat predict_matrix

rename predict_matrix1 sim_stderr_forecast
rename predict_matrix2 sim_prediction
rename predict_matrix3 sim_str

di "Critical value of t is: `myt'"

generate sim_lower_bound = sim_prediction - (`myt' * sim_stderr_forecast) /*Prediction minus t value times SE */
generate sim_upper_bound = sim_prediction +  (`myt' * sim_stderr_forecast) /*Prediction plus t value times SE */


graph twoway (rarea sim_lower_bound sim_upper_bound sim_str, color(blue%25) ) ///
			 (line sim_prediction sim_str) , name(policy5)

			
// Last problem

drop sim*

sum `x'

local min=r(mean)-10 // Stores minimum of key iv, student teacher ratio
local max=r(mean)-5 // Stores max of key iv, student teacher ratio
local diff=`min'-`max' // Calculates difference between min and max
local step=`diff'/100 // Divides difference by 100, giving us a value for "steps" from min to max

estimates restore test_estimates

// Run margins to gnerate predicted values 

margins ,  /// /* init margins */
    predict(xb) /// /* Type of prediction */
     at( (mean)  `controls' ///  /* Set controls at mean */
    `x'=(`min'(`step')`max'))  /// /*range from min to max of x in steps of diff */
     post  /* Post results in matrix form */

// Pull results
mat xb=e(b)

// store x values used to generate predictions
mat allx=e(at)

// store just x values from that matrix
matrix myx=allx[1...,1]'
	 
// Now need forecast standard errors

estimates restore test_estimates

margins ,  /// /* init margins */
    predict(stdf) /// /* Type of prediction */
	nose /// /* Don't need se of se */
     at( (mean)  `controls' ///  /* Set controls at mean */
    `x'=(`min'(`step')`max'))  /// /*range from min to max of x in steps of diff */
     post  /* Post results in matrix form */

mat stdf=e(b) // Save se forecast

mat predict_matrix=[stdf \ xb\ myx]' //combine se forecast with prediction (xb) and x (myx) then transpose


svmat predict_matrix

rename predict_matrix1 sim_stderr_forecast
rename predict_matrix2 sim_prediction
rename predict_matrix3 sim_str

di "Critical value of t is: `myt'"

generate sim_lower_bound = sim_prediction - (`myt' * sim_stderr_forecast) /*Prediction minus t value times SE */
generate sim_upper_bound = sim_prediction +  (`myt' * sim_stderr_forecast) /*Prediction plus t value times SE */


graph twoway (rarea sim_lower_bound sim_upper_bound sim_str, color(blue%25) ) ///
			 (line sim_prediction sim_str) , name(policy10)
			
			

exit 


	 

