capture log close                       // closes any logs, should they be open
set linesize 90
log using "sampling_part2.log", replace    // open new log

// NAME: Sampling: Part 2
// FILE: lecture7_sampling_part2.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 18 October 2014
// LAST: 18 October 2016
     
clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// load data from web, nhanes2f
webuse nhanes2f, clear

// naive mean
mean age height weight

// explore survey design
tab stratid psuid

// mean with probability weights
mean age height weight [pw = finalwgt] 

// TAYLOR SERIES LINEARIZED ESTIMATES

// set survey characteristics with svyset
svyset psuid [pweight = finalwgt], strata(stratid)

// compute mean using svy pre-command and taylor series estimates
svy: mean age height weight

// BRR ESTIMATES

// load data from web, nhanes2brr
webuse nhanes2brr, clear

// svyset automagically
svyset

// compute mean using svy pre-command and brr weights
svy: mean age height weight

// load data from web, nhanes2 no brr
webuse nhanes2, clear

// create Hadamard matrix in Mata
mata: h2 = (1, 1 \ 1, -1)
mata: h4 = h2 # h2
mata: h8 = h2 # h4
mata: h16 = h2 # h8
mata: h32 = h2 # h16

// check row and column sums
mata: rowsum(h32)
mata: colsum(h32)

// save Mata matrix in Stata matrix form
mata: st_matrix("h32", h32)

// use our BRR weighting matrix with svy
svy brr, hadamard(h32): mean age height weight 

// JACKNIFE ESTIMATES

// load data from web, nhanes2jknife
webuse nhanes2jknife, clear

// set svyset using jackknife weigts
svyset [pweight = finalwgt], jkrweight(jkw_*) vce(jackknife)

// compute naive means without jackknife weights
mean age weight height

// compute mean with jackknife weights
svy: mean age weight height

// BOOTSTRAP ESTIMATES

// load data from web, nmihs_bs 
webuse nmihs_bs, clear

// svyset 
svyset idnum [pweight = finwgt], vce(bootstrap) bsrweight(bsrw*)

// convert birth weight grams to lbs for the Americans
gen birthwgtlbs = birthwgt * 0.0022046

// compute naive mean birthweight
mean birthwgtlbs

// compute mean with svy bootstrap
svy: mean birthwgtlbs

// end file     
log close
exit
