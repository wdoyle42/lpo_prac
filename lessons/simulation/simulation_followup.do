version 13
capture log close
log using "simulation.log",replace

/* PhD Practicum, Spring 2017 */
/* Getting Started with */
/* Will Doyle*/
/* 1/31/17 */
/* Saved on Blackboard */

 /*Graph type postscript */
// local gtype ps

/* Graph type: pdf */
//local gtype pdf

/* Graph type: eps */
local gtype eps

clear 

// TOC

//1: Run CLT example
local xbar_example=1

//2: Run basic regression example
local reg_example_1=1

//3: Run multiple regression example
local reg_example_2=1

// Create a hypothetical situation

local mymean 5
local mysd 1
local pop_size 10000
local sample_size 100
local nreps 1000

// Create variable x based on values above
drawnorm x, means(`mymean') sds(`mysd') n(`pop_size')

save x, replace

// Population mean
mean x

scalar pop_mean=_b[x]

// Popoluation standard deviation
tabstat x, stat(sd) save

mat M=r(StatTotal)

scalar pop_sd=M[1,1]

preserve // Set return state
sample `sample_size', count // Take a sample 
mean x // Calculate mean 
tabstat x, stat(sd) // Calculate sds
restore //


// Is CLT a real thing?

if `xbar_example'==1{
// create a place in memory called buffer which will store a variable called xbar in a file called means.dta
postfile buffer xbar sd using means, replace 

forvalues i=1/`nreps'{
	preserve // Set return state
	quietly sample `sample_size', count // Keep only certain observations
	quietly mean x // get mean
	quietly tabstat x, stat(sd) save //standard deviation
	mat M=r(StatTotal)
	scalar sample_sd=M[1,1]
	post buffer (_b[x]) (sample_sd) // post the estimate to the buffer
	restore // Go back to full dataset
}

postclose buffer // Buffer can stop recording

use means, clear

kdensity xbar,xline (`mymean')

graph export clt.`gtype', replace

kdensity sd,xline (`mysd')

mean xbar

scalar simulate_mean=_b[xbar]

//Here's whate SE should be:
scalar hypo_se=`mysd'/sqrt(`sample_size')

//Here's what SE is: 
tabstat xbar,stat(sd) save

mat M=r(StatTotal)

scalar simulate_se=M[1,1]

// Mean of repeated sample standard deviations
mean sd

}

exit 

// Regression simulation: first example

use x, clear

// Generate error term
local error_sd 10

drawnorm e, means(0) sds(`error_sd')

// Set values for parameters
local beta_0=10

local beta_1=2

// Generate outcome
gen y=`beta_0'+`beta_1'*x+e

// Run MC study for basic regression
if `reg_example_1'==1{
// create a place in memory called buffer which will store a variable called xbar in a file called means.dta
postfile buffer beta_0 beta_1 using reg_1, replace 

forvalues i=1/`nreps'{
	preserve // Set return state
	quietly sample `sample_size', count // Keep only certain observations
	quietly reg y  x // get parameter estimates
	post buffer (_b[_cons]) (_b[x]) // post the estimate to the buffer
	restore // Go back to full dataset
}

postclose buffer // Buffer can stop recording

// Open up results of MC study for basic regression
use reg_1, clear

kdensity beta_0, xline(`beta_0')

graph export beta_0.`gtype', replace

kdensity beta_1, xline(`beta_1')

graph export beta_1.`gtype', replace

mean beta_0

mean beta_1

}

// Multiple regression example

local my_corr=.02

local my_means 10 20 

local my_sds 5 10

// Create variable x based on values above
drawnorm x1 x2, means(`my_means') sds(`my sds') corr(1,`my_corr'\`my_corr',1) n(`pop_size') cstorage(lower)

drawnorm e, mean(0) sd(`error_sd')

local beta_0=10

local beta_1=2

local beta_2=4

gen y= `beta_0'+`beta_1'*x1 +`beta_2'*x2 + e

if `reg_example_2'==1{
// create a place in memory called buffer which will store a variable called xbar in a file called means.dta
postfile buffer beta_0 beta_1 using reg_2, replace 

forvalues i=1/`nreps'{
	preserve // Set return state
	quietly sample `sample_size', count // Keep only certain observations
	quietly reg y  x1  // get parameter estimates
	post buffer (_b[_cons]) (_b[x]) // post the estimate to the buffer
	restore // Go back to full dataset
}

postclose buffer // Buffer can stop recording

use reg_2, clear

kdensity beta_1, xline(`beta_1')

graph export ovb.`gtype', replace
}



exit 
