/* Assignment 2*/
/* Will Doyle */
/* 1/24 /2017 */

capture log close

log using "ols_regression_stata.log",replace

clear

estimates drop _all

/* Set locals */

local tab_type rtf

/*Please complete the following steps, using the mroz dataset available on
our website. The Moz datasets comes from the Panel Study of Income
Dynamics, and was used as part of a famous study on women’s labor force
participation. For this assignment, you will model the correlates of
women’s labor force outcomes.*/

use mroz, clear

/*1.  Create a macro called y, and assign its value to the variable hours*/

local y hours

/*2.  Create three other macros, named family, husband, and qualifcations.
    Place in each macro a set of variables related to family
    characteristics, husband’s labor force characteristics, and the
    woman’s labor force qualifications.*/

	local family kidslt6 kidsge6 
	
	local husband huseduc huswage
	
	local qualifications educ exper
	
/*3.  Create a summary table of all of the variables from above, including
    both means and standard deviations.*/

eststo descriptives: estpost tabstat `y' `family' `husband' `qualifications', ///
    statistics(mean sd) ///
    columns(statistics) ///
    listwise 
    
esttab descriptives using esttab_means.`tab_type' , ///
    main(mean) ///
    aux(sd) ///
    nostar ///
    nonote ///
    label ///
    nonumber ///
    replace 
		

/*4.  Run a total of four regressions. The first three should have y as
    the dependent variable and each “cluster” of variables represented
    by a macro as the sole set of independent variables. The last should
    have all of the independent variables on the right hand side.*/

local depvars hours wage

foreach y of local depvars{
	
reg `y' `family'

reg `y' `husband'

reg `y' `qualifications'
	
reg `y' `family' `husband' `qualifications'
}
	
/*5.  Repeat the above step, but reassign the macro y to an alternative
    labor force outcome for the woman (your choice).*/

	
/*6.  In a single paragraph (no more than 150 words), comment on the
    results of your estimation. This should be a comment in the do file.

	Women who have children under 6 work considerably fewer hours and have 
	lower wages than women who do not have any children under 6. As the estimates show, 
	for each additional child under 6 women are predicted to work 271 fewer hours, 
	even after controlling for relevant characteristics. This estimate is bounded by a 95% 
	confidence interval that runs from 382 fewer hours to 162 fewer hours.  Women with higher 
	levels of education and experience work more hours and earn higher wages. Women 
	whose husbands are more educated work fewer hours, but do not have measurably different 
	wages. 
	
	*/
