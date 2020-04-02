capture log close 

// Assignment 9 
// Complex Reporting
// Will Doyle
// 2020-04-02

use ../../data/plans3,  replace


local y bynels2m 

local x pared_bin

local controls bysex byrace f1psepln 

local controls_reg i.bysex i.byrace i.f1psepln 

local mysig =.001

egen read_q=cut(bynels2r), group(4)

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

estout matrix(M_col) using "baseline_tab.rtf",  replace

} // Loop over control variables 


// Run a regression across both your full sample and various subsamples, 
//reporting the results for just your key independent variable or variables in
// a table.
svyset psu [pw=f1pnlwt], strat(strat_id) singleunit(scaled)


svy:reg `y' `x' `controls_reg' 

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))

mat results_tab= [my_coeff\my_se\my_n]

    
foreach i of numlist 0(1)3{

svy:reg `y' `x' `controls_reg' if read_q==`i'

scalar my_coeff = round(_b[`x'], `mysig')

scalar my_se =round(_se[`x'],`mysig')

scalar my_n=round(e(N))

mat M=[my_coeff\my_se\my_n]

mat results_tab=(results_tab,M)

}

exit 

// Create a graphic that shows how the relationship between one of your 
//key independent variables and your dependent variable varies by levels 
//of another variable. Repeat that graphic for various subsamples of the data. 
//(hint: use grc1leg2)
