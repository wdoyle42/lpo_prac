capture log close                       // closes any logs, should they be open
log using "stata_basics.log", replace    // open new log

// NAME: Stata Basics
// FILE: stata_basics.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 2012-09-04 
// LAST: 2019-09-05

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature
  
// downloading ado files

net search renvars 

// load in school vote data 

webuse school, clear

save school, replace
 
// outsheet dataset

outsheet using "school_data.csv", comma replace

// Create a tab-separated version

outsheet using "school_data.txt", replace

// insheet dataset

insheet using "school_data.csv", comma clear

import delimited using "school_data.csv", clear

import delimited using "school_data.tsv", clear 

// export delimited using "school_data.tsv", delimiters("\t")

// describe data

//Save as tab delimited

outsheet using "school_data.tsv", replace

//Open up tab delimited file

insheet using "school_data.tsv", clear

describe

// labeling data 

label data "Voting on school expenditures"


// labeling variables 

label variable loginc "Log of income"

label variable vote "Voted for public school funding"

la var obs "ID"

la var pub12 "One or two children in public school"

la var pub34 "Three or four children in public school"

la var pub5 "Five or more children in public school"

la var private "Child in private school"

la var years "Years lived in district" 

la var school "Bachelor's degree"

la var loginc "Log of income" 

la var logptax "Log of property tax"

la var logeduc "Log of education expenditures"

// describe again

describe
 
// labeling values within variables 

tab vote

label define voteopts 0 "No" 1 "Yes"

label values vote voteopts

tab vote

label define kidopts 0 "No"  1 "Yes"

label values pub12 pub34 pub5 kidopts

// transforming variables 

gen inc = exp(loginc)

sum loginc inc

gen inc_k= inc/1000

// In one step create a variable for property taxes, 
// expressed in hundreds of dollars

gen ptax_h=(exp(logptax))/100

// recoding variables
sum inc

gen inc_bin = 0

replace inc_bin = 1 if inc > r(mean)

la var inc_bin "Above average income"

gen inc_bin_2=inc>r(mean)

egen inc_q = cut(inc), group(4)

la var inc_q "Income Quartile"

recode inc_q (0 = 1 "1st Quartile") ///
    (1 = 2 "2nd Quartile") ///
    (2 = 3 "3rd Quartile") ///
    (3 = 4 "4th Quartile"), gen(new_inc_q)

la var new_inc_q "Income Quartile"
	
recode inc_q (0/1 = 0 "Below median") ///
    (2/3 = 1 "Above median"), gen(inc_median)	
	
// compute new variable

gen ptax = exp(logptax)

gen taxrate = ptax / inc

sum taxrate

// end file
log close                               // close log
exit                                    // exit script
