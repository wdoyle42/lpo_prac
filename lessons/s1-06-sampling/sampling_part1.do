capture log close                       // closes any logs, should they be open
set linesize 90
log using "sampling_part1.log", replace    // open new log

// NAME: Sampling: Part 1
// FILE: lecture7_sampling_part1.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 1 October 2014
// LAST: 10 October 2016
     
clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

global datadir "./"

// install gsample and moremata for probability samples
// ssc install gsample
// ssc install moremata

// SIMPLE RANDOM SAMPLING

// read in fake SAT score data
use ${datadir}fakesat, clear


// calculate population mean, variance, sd, and sem by hand
egen scoretot = total(score)            // total of all scores
scalar popmean = scoretot / _N          // population mean score
gen sqdiff = (score - popmean)^2        // (Xi - Xbar)^2
egen sst = total(sqdiff)                // total of squared differences
scalar popvar = sst / (_N - 1)          // population variance (not super pop)
scalar popsd = sqrt(popvar)             // population standard deviation
scalar popsem = popsd / sqrt(_N)        // standard error of population mean

// compare to stata internal calculation
scalar list popmean popsd popsem
summarize score
mean score

// drop everything but score
keep score

// randomly sample 10%, all with equal probability of selection
sample 10

// calculate sample mean, variance, sd, and sem by hand
egen scoretot = total(score)            // total of all scores
scalar sampmean = scoretot / _N         // sample mean score
gen sqdiff = (score - sampmean)^2       // (Xi - Xbar)^2
egen sst = total(sqdiff)                // total of squared differences
scalar sampvar = sst / (_N - 1)         // sample variance
scalar sampsd = sqrt(sampvar)           // sample standard deviation
scalar sampsem = sampsd / sqrt(_N)      // standard error of sample mean

// compare to stata internal calculation of sample
scalar list sampmean sampsd sampsem
summarize score
mean score


// SIMPLE RANDOM SAMPLING WITH FINITE POPULATION CORRECTION

// read in data for single class test 
use ${datadir}singleclasstest, clear

// check population stats; store population number
sum score
scalar N = _N

// sample large part of population
sample 30, count
scalar n = _N

// calculate sample stats without fpc correction
egen scoretot = total(score)            // total of all scores
scalar xbar = scoretot / n              // sample mean score
gen sqdiff = (score - xbar)^2           // (Xi - Xbar)^2
egen sst = total(sqdiff)                // total of squared differences
scalar var_x = sst / (n - 1)            // sample variance
scalar sd_x = sqrt(var_x)               // sample standard deviation
scalar sampsem = sd_x / sqrt(n)         // standard error of sample mean

scalar list xbar var_x sd_x sampsem

// calculate fpc
scalar fpc = sqrt((N - n) / (N - 1))

// correct sem with fpc
scalar sampsemfpc = sampsem * fpc
scalar list sampsem sampsemfpc

// 95% CI for the mean
di xbar - invnormal(.975) * sampsem
di xbar + invnormal(.975) * sampsem

// 95% CI for fpc-adjusted mean
di xbar - invnormal(.975) * sampsemfpc
di xbar + invnormal(.975) * sampsemfpc


// SIMPLE RANDOM SAMPLING WITH FREQUENCY WEIGHTS

use ${datadir}fakesat_freq, clear

// list first few observations
list if _n < 11


// compare simple mean with freqency-weighted mean
mean score
mean score [fw = freq]

// SIMPLE RANDOM SAMPLING WITH (INVERSE) PROBABILITY WEIGHTS

use ${datadir}fakesat, clear

// assume probability of reporting score is corrected with score
gen preport = score / 1000 + .1 * (score / 10000)^2 + rnormal(0, .025)

// sample based on probability of reporting
gsample 1 [w = preport], percent

// mean of sample
mean score

// generate pweight (inverse probability of selection)
gen pweight = 1 / preport

// check probability-weighted mean 
mean score [pweight = pweight]

// STRATIFIED RANDOM SAMPLING WITH PROBABILITY PROPORTIONAL TO SIZE

// read in fake highschool data; store full student population
insheet using ${datadir}fakehs.csv, clear
scalar stupop = _N

// proportion of students at risk
mean atrisk                             // overall
mean atrisk, over(grade)                // within each grade

// sample within grades (strata)                               
global ss = 50                          // set within grade sample size
sample $ss, count by(grade)             // sample



// compute within grade and overall means and sems
preserve 
collapse (mean) propatr = atrisk (sd) sdatr = atrisk (first) nstgrade, by(grade)


scalar Ybar9 = propatr[1]               // 9th grade average
scalar Ybar10 = propatr[2]              // 10th grade average
scalar Ybar11 = propatr[3]              // 11th grade average
scalar Ybar12 = propatr[4]              // 12th grade average

// compute ((N_h - n_h) / N_h - 1) * (s_h^2 / n_h)
gen varatr = ((nstgrade - $ss) / (nstgrade - 1)) * (sdatr^2 / $ss)

// compute sem for each grade and store
gen grade_sem = sqrt(varatr)

scalar Ybar9_sem = grade_sem[1]         // 9th grade sem
scalar Ybar10_sem = grade_sem[2]        // 10th grade sem
scalar Ybar11_sem = grade_sem[3]        // 11th grade sem
scalar Ybar12_sem = grade_sem[4]        // 12th grade sem

gen weight = nstgrade / stupop          // (N_h / N)

gen wpropatr = weight * propatr         // weight strata proportions
gen wvaratr = weight^2 * varatr         // weight strata variances

collapse (sum) wpropatr wvaratr         // sum within stata means and vars
scalar Ybar = wpropatr[1]               // store estimate of pop. at risk
scalar Ybar_sem = sqrt(wvaratr[1])      // compute root of above measure
restore

// compare computed to Stata version
scalar list Ybar Ybar_sem
mean atrisk
scalar list Ybar9 Ybar9_sem Ybar10 Ybar10_sem Ybar11 Ybar11_sem Ybar12 Ybar12_sem 
mean atrisk, over(grade)


// CLUSTER SAMPLING WITH PROBABILITY PROPORTIONAL TO SIZE

// open full fake highschool data again
insheet using ${datadir}fakehs.csv, clear

// get population estimates
mean testscore                          // overall
mean testscore, over(grade)             // within grade

// stratified sample
global cut = 10                         // number of classes to keep in each grade 
keep if classid <= $cut                 // keep only sampled classes
scalar m = _N                           // number of students in sample


// get estimated population (should be close to 2003)
gen weight = nclgrade / $cut            // 1 / (n_h / N_h) or just (N_h / n_h) 
qui sum weight                          // quietly -summarize-
scalar Mhat = r(sum)                    // store sum of weights
di Mhat                                 // estimated population


// get population score estimate, by class and overall
preserve
gen wscore = testscore * weight         // (w_hij * y_hij)

// same as double sum: students to class, class to grade
collapse (sum) wscore (first) nstgrade nclgrade, by(grade) 
gen Ybar_grade = wscore / nstgrade      // Ytotal_h / stupop_h = Ybar_h
scalar Ybar9 = Ybar_grade[1]            // 9th grade average score
scalar Ybar10 = Ybar_grade[2]           // 10th grade average score
scalar Ybar11 = Ybar_grade[3]           // 11th grade average score
scalar Ybar12 = Ybar_grade[4]           // 12th grade average score
qui sum wscore                          // quietly -summarize-
scalar Ybar_school = r(sum) / Mhat      // Ytotal / stupop = Ybar
restore

scalar list Ybar9 Ybar10 Ybar11 Ybar12 Ybar_school

// mean of overall school score
mean testscore


// get right-ish estimate of standard error of school test mean
gen wscore = testscore * weight         // (w_hij * y_hij)
gen fpc_r = $cut / nclgrade             // fpc rate by strata (grade)
collapse (sum) wscore (first) nstgrade fpc_r, by(grade classid) // sum w/n class
preserve
collapse (mean) stmscore = wscore, by(grade) // mean weighted score w/n grades
tempfile stratmeans                          // init temporary file
save `stratmeans'                            // save temporary file
restore
merge m:1 grade using `stratmeans', nogen    // merge grade means into file

// (1 - f_h) * (n_h / (n_h - 1)) * (y_hi - ybar_h)^2
gen adjsqdiff = (1 - fpc_r) * ($cut / ($cut - 1)) * (wscore - stmscore)^2 
collapse (sum) adjsqdiff                // double sum: w/n strata, overall

// var(Ybar) = var(total) / stupop^2; Ybar_sem = sd(var(Ybar)) / sqrt(sampstu)
scalar Ybar_school_sem = sqrt(adjsqdiff / Mhat^2) / sqrt(m)

scalar list Ybar_school Ybar_school_sem

// end file     
log close
exit
