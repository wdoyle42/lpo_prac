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


// Quick Exercise: Outsheet using tabs
outsheet using "school_data.tsv", replace


// insheet dataset

insheet using "school_data.csv", comma clear

// describe data

describe

// labeling data 

label data "Voting on school expenditures"

// labeling variables 

label variable loginc "Log of income"

label variable vote "Voted for public school funding"

// Quick exercise label variable for 1 or 2 kids

label variable pub12 "One or two children in public schools"

// describe again

describe

// labeling values within variables 

tab vote

label define yesno 0 "no" 1 "yes"

label values vote pub12 yesno

tab vote

tab pub12

codebook vote 


// transforming variables 

gen inc = exp(loginc)


gen inc10k=inc/10000

sum loginc inc inc10k


// recoding variables

gen inc_bin = 0

sum inc

replace inc_bin = 1 if inc > r(mean)

egen inc_q = cut(inc), group(4)

recode inc_q (0 = 1 "First Quartile") ///
    (1 = 2 "2nd Quartile") ///
    (2 = 3 "3rd Quartile") ///
    (3 = 4 "4th Quartile"), gen(new_inc_q)
 	
	
// compute new variable

gen ptax = exp(logptax)

gen taxrate = ptax / inc

//ending exercises

//Create a new binary variable for whether or not the family has any 
//children in public schools. Properly label your variable and variable values.

gen anypubkids=0

replace anypubkids=1 if pub12==1 | pub34==1 | pub5==1

label variable anypubkids "Any children in public schools"

label values anypubkids yesno

tab anypubkids

//Create a new variable for percent of household income spent on education. 
//Properly label your new variable.

gen educ=exp(logeduc)

gen educ_pct=(educ/inc)*100

label var educ_pct "Percent of income spend on education"

//Create a new variable for persons with low, moderate and high percentages of 
//spending on education. Label the variable and value labels properly.

egen educ_pct_q=cut(educ_pct), group(3)

recode educ_pct_q (0 = 1 "Low Spending") ///
    (1 = 2 "Moderate Spending") ///
    (2 = 3 "High Spending") ///
     , gen(educ_pct_q_2)

//Tabulate household spending and voting for public school funding. What do you find?	 
	 
tab educ_pct_q_2 vote, row 
	
// end file
log close                               // close log
exit                                    // exit script
