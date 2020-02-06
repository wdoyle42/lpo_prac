capture log close 

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
        

exit 


// Assume that a policy has been suggested that will lower class sizes by 5 students per teacher.
// Holding all another values at a reasonable level, predict the impact of this 
//increase on student test scores at the district level, with an appropriate statement of
// uncertainty. Remember that what you’ll need to be doing here is forecasting. 
//Assume that you’ll be going from the current value to 5 students lower.


