capture log close                       // closes any logs, should they be open
log using "stata_basics.log", replace    // open new log

// NAME: Stata Basics
// FILE: lecture2_stata_basic.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 4 September 2012
// LAST: 9/5/2016

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature
  
// downloading ado files

net search renvars

// load in school vote data 

webuse school, clear

// outsheet dataset

outsheet using "school_data.csv", comma replace

// insheet dataset

insheet using "school_data.csv", comma clear

// describe data

describe

// labeling data 

label data "Voting on school expenditures"

// labeling variables 

label variable loginc "Log of income"

label variable vote "Voted for public school funding"

// describe again

describe

// labeling values within variables 

tab vote

label define voteopts 0 "no" 1 "yes"

label values vote voteopts

tab vote

// transforming variables 

gen inc = exp(loginc)

sum loginc inc

// recoding variables

gen inc_bin = 0

replace inc_bin = 1 if inc > r(mean)

egen inc_q = cut(inc), group(4)

recode inc_q (0 = 1 "First Quartile") ///
    (1 = 2 "2nd Quartile") ///
    (2 = 3 "3rd Quartile") ///
    (3 = 4 "4th Quartile"), gen(new_inc_q)

// compute new variable

gen ptax = exp(logptax)

gen taxrate = ptax / inc

// end file
log close                               // close log
exit                                    // exit script
