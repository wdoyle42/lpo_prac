capture log close 

// Assignment 9 
// Complex Reporting
// Will Doyle
// 2020-04-02

use ../../data/plans3,  replace


local y bynels2m 

local x pared_bin

local controls bysex byrace f1psepln 

local mysig =.001

// Create a table of baseline equivalence, that shows whether there are 
// significant differences among the control variables as a function of your 
// treatment variable.

local counter=1

foreach ind_var of local controls{

tab `ind_var', gen(`ind_var'_)

foreach myvar of varlist `ind_var'_*{

reg `myvar' `x' 

scalar my_diff = round(_b[`x'], `mysig')

scalar my_t =round(_b[`x']/_se[`x'],`mysig')

mat M= [my_diff\my_t]

if `counter'==1{
    mat M_col=M
}
    else mat M_col=(M_col\M)
	
 local counter=`counter'+1 

} // Loop over levels of independent variable

estout matrix(M_col) using "baseline_tab.html", style(scml) replace

} // Loop over control variables 

exit 



// Run a regression across both your full sample and various subsamples, 
//reporting the results for just your key independent variable or variables in
// a table.

// Create a graphic that shows how the relationship between one of your 
//key independent variables and your dependent variable varies by levels 
//of another variable. Repeat that graphic for various subsamples of the data. 
//(hint: use grc1leg2)
