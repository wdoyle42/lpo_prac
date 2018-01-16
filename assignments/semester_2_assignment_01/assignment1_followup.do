// ## Vanderbilt University
capture log close

log using "assignment1_followup.log" ,replace

// Assignment 1 Followup
// Will Doyle
// One way to do this assignment
// On Github

global ddir "../../data/"

use "${ddir}plans2.dta", clear

// ## Leadership, Policy and Organizations
// ## Class Number 9952
// ## Spring 2016

// **Part 1**

// Write a program that does the following:

// 1.  Takes a variable list (assumed to be each a factor) as its argument

// 2.  Converts each factor variable to a series of dummy variables

// 3.  Returns dummy variables that are appropriately labeled (both as
//     variables and values)

// Binary variable level
label define yesno 1 "Yes"  0 "No"


local factor_list bypared byincome

foreach myfactor of local factor_list{

// list of numbers associated with each level of the variable
levelsof `myfactor', local(mylevels)

di "`mylevels'"

// Labels for each level
local mylabel: value label `myfactor'

di "`mylabel'"

//use tab to generate dummy variables
tab `myfactor',gen(`myfactor'_)

// init counter
local i=1
// Iterate through each of the levels
foreach mylevel of local mylevels{
di "`mylevel'"
// Grab value label for level
local myname:label `mylabel' `i' 
di "`myname'"
// Label variable with value label
label variable `myfactor'_`mylevel'  "`myname'"
// Give binary variable appropriate value labels
label values  `myfactor'_`mylevel' yesno
//Iterate counter
local i= `i'+1
}   

//Tab results (not necessary)
foreach mylevel of local mylevels{
tab `myfactor'_`mylevel'
}

}





// **Part 2**

// Following the logic we went over in class, generate a simple mean of
// your dependent variable, followed by the conditional mean of your
// dependent variable over the levels of a continuous or ordinal
// independent variable. Use 2,4, and 10 categories. Then run a regression
// and predict the dependent variable from your independent variable.
// Generate a mean squared error for each type of prediction (unconditional
// and conditional means, regression) and describe what you find.


egen mean_math=mean(bynels2m)

// College vs. noncollege (two levels)
recode bypared (1/2=0) (nonmiss=1), gen(bypared2)

//Conditional means
egen cond_mean_math_2=mean(bynels2m), by(bypared2)

// No college, some college, bach, grad school
recode bypared (1/2=1) (3/5=2) (6=3) (7/8=4), gen(bypared4)

//Conditional means
egen cond_mean_math_4=mean(bynels2m), by(bypared4)

// All levels
egen cond_mean_math_all=mean(bynels2m), by(bypared)

// Three levels
local mynums 2 4 all

// Loop through and generate rmses
foreach mynum of local mynums{
// error= actual-predicted
gen error=bynels2m-cond_mean_math_`mynum'
// squared
gen error_sq=error^2
// mean
sum error_sq
scalar mse_math_`mynum'=r(mean)
//root
scalar rmse_math_`mynum'=sqrt(mse_math_`mynum')
drop error error_sq 
}

reg bynels2m i.bypared

scalar reg_rmse=e(rmse)

scalar li

// Lowest rmse is from predictions from all levels, which is very similar to regression, likely a precision problem.


