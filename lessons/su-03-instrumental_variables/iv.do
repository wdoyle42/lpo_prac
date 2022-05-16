version 13 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "iv.log",replace /*Open up new log */

/* Instrumental Variables */
/* Will Doyle */
/* 2022-05-11 */
/* Practicum Folder */

clear 

global ddir "../../data/"


// TOC

local iv=0
local rd=1

if `iv'==1{
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
} // End IV section 

//Installation list

// rddensity

// rdrobust

// rdlcaolrand

//net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace



// RD Designs

if `rd'==1{

use rdrobust_senate, clear

local y vote // Vote for dem in next election

local z margin // Dem vote share in previous election, centered on 0 (50-50)

gen dem_won_last= margin>0

local t dem_won_last
 
local int_t_z  i.dem_won_last##c.margin


// Basic Plot
rdplot `y' `z'

// Smooth at cutoff?

rddensity  `z' , plot


// Regression

reg `y' `t'

reg `y' `t' `z'

//RD in bandwidth
reg `y' `int_t_z' if abs(`z')<10


//RD robust command

rdrobust `y' `z', h(15)

rdrobust `y' `z', h(5)

// What bandwidth?

rdbwselect `y' `z'

rdbwselect `y' `z', bwselect(msetwo)

rdrobust `y' `z' // does this by default

rdrobust `y' `z', bwselect(msetwo)


tempname results_store
postfile `results_store' rd_est rd_se myN index using mult_bw, replace

forvalues i=3/100{

qui rdrobust `y' `z', h(`i') 

scalar rd_est=_b[RD_Estimate]

scalar rd_se=_se[RD_Estimate]

scalar myN=e(N_r)

scalar index=`i'

post `results_store' (rd_est) (rd_se) (myN) (index)

}

postclose `results_store'

use mult_bw, clear

gen t= invttail(myN,.025)

gen upper_ci=rd_est+(t*rd_se)

gen lower_ci=rd_est-(t*rd_se)

graph twoway (rarea upper_ci lower_ci index, color(gray%25) lwidth(0) ) ///
			(scatter rd_est index, color(blue%75) msize(vsmall) ), ///
			legend(order(2 "Estimate" 1 "95% CI")) ///
			ytitle("Estimate") ///
			xtitle("Bandwidth")


} // End RD section

exit


// need rdrobust

// rddensity

// rdlocarand


