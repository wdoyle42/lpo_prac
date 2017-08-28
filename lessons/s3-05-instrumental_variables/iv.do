version 13 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "iv.log",replace /*Open up new log */

/* Instrumental Variables */
/* Will Doyle */
/* 170515 */
/* Practicum Folder */

clear 

global ddir "../../data/"

use "${ddir}nlsy_2010.dta", clear


// Interaction variable
gen moth_prox= mothed*prox

local y lyinc
local x ccol
local controls female black multiracial hispanic asvab i.quarter
local z prox
local z1 prox moth_prox

// gen z= 1 + 2*ccol + rnorm(10)

// Basic regression with endog regressor

reg `y' `x'
reg `y' `x' `controls'

// "First Stage": does instrument predict endog regressor?

reg `x' `z' if `y' !=.
reg `x' `z' `controls' if `y' !=.

// "Reduced form": does instrument predict outcome (omitting endog regressor)

reg `y' `z'
reg `y' `z' `controls'


// Basic IV estimate

eststo basic_iv:ivregress 2sls `y' (`x'=`z'), first

eststo basic_iv_controls:ivregress 2sls `y' `controls' (`x'=`z'), first

estat endogenous

estat first

// Overidentification

eststo overid:ivregress 2sls `y' (`x'=`z1'), first

eststo overid_controls:ivregress 2sls `y'  `controls' (`x'=`z1'), first

estat endogenous

estat first

estat overid

// Check against LIML
eststo overid_controls_liml:ivregress liml `y'  `controls' (`x'=`z1'), first

