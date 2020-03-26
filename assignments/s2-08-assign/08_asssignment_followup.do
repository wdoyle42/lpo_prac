
// Assignment 8 Follow Up
// Will Doyle
// 2020-03-26

use ../../data/plans3.dta, clear

local y bynels2m

local x byses1


local controls i.bypared i.byrace i.bysex


eststo reg1: reg `y' `x' `controls'

// Test for collinearity in the model. 
//Describe the results of your test and say what you have decided to do as a result.

estimates restore reg1

estat vif 


//Test for heteroskedacity in the model. Describe the results 
//of your test and say what you have decided to do as a result.

estimates restore reg1

//No options, yhat is used as the covariate

estat hettest , iid 

//BP with subsets of covariates

estat hettest `x', iid

estat hettest `controls', iid

estat hettest, rhs iid

svyset psu [pw=bystuwt], strat(strat_id) singleunit(scaled)

// This is what I would really do
svy: reg `y' `x' `controls'


// For example only

reg `y' `x' `controls', vce(robust)


// Decide if any of your variables need to be rescaled and do so if necessary.

// No


//Check on the functional form of your model using graphical approaches. 
//Include some of these graphics in your paper.

graph twoway (scatter `y' `x', msize(vtiny) mcolor(%25)) ///
			 (lowess `y'  `x'  )  ///
			 (lfit `y' `x', lpattern(dash))


reg `y' c.`x'##c.`x' `controls', vce(robust)
 		
// Including the square of SES improves model fit, so new model includes a quadratic in SES.
 


