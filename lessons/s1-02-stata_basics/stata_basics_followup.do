capture log close                       // closes any logs, should they be open
log using "stata_basics.log", replace    // open new log

// NAME: Stata Basics
// FILE: lecture2_stata_basic.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 2012-09-04 
// LAST: 2017-09-4

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature
  
// downloading ado files

net search renvars 

// load in school vote data 

webuse school, clear

save school, replace

// outsheet dataset

outsheet using "school_data.csv", comma replace

// insheet dataset

insheet using "school_data.csv", comma clear

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
sum inc

gen inc_bin = 0

replace inc_bin = 1 if inc > r(mean)

egen inc_q = cut(inc), group(4)

recode inc_q (0 = 1 "First Quartile") ///
    (1 = 2 "2nd Quartile") ///
    (2 = 3 "3rd Quartile") ///
    (3 = 4 "4th Quartile"), gen(new_inc_q)

// Binary variable for greater than median

sum inc, detail

gen bin_inc_med=0

replace bin_inc_med = 1 if inc > r(p50)

tab bin_inc_med

gen bin_inc2=0

replace bin_inc2= 1 if new_inc_q==3 | new_inc_q==4

tab bin_inc2
	
// compute new variable

gen ptax = exp(logptax)

gen taxrate = ptax / inc


//In class exercises

//Create a new binary variable for whether or not the family has any children
// in public schools. Properly label your variable and variable values.

gen pub_any=0
replace pub_any=1 if pub12==1 | pub34==1 | pub5==1
tab pub_any

//Create a new variable for percent of household income spent on education.
// Properly label your new variable.

gen prop_educ= (exp(logeduc))/inc

la var prop_educ "Proportion of income spent on education"

sum prop_educ

//Create a new variable for persons with low, moderate and high percentages of 
//spending on education. Label the variable and value labels properly.

egen prop_educ_q = cut(prop_educ), group(3)

recode prop_educ_q (0 = 1 "Low Spending") ///
    (1 = 2 "Moderate Spending") ///
    (2 = 3 "High Spending") ///
    , gen(new_prop_educ_q)

tab new_prop_educ_q

//Tabulate household spending and voting for public school funding. What do you find?

tab new_prop_educ_q vote, row

// end file
log close                               // close log
exit                                    // exit script
