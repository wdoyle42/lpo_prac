capture log close                       // closes any logs, should they be open
log using "stata_basics.log", replace    // open new log

// NAME: Stata Basics
// FILE: stata_basics.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 2012-09-04 
// LAST: 2020-09-02

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature
  
// downloading ado files

net search renvars 


// load in school vote data 

webuse school, clear

save school , replace

// outsheet dataset

outsheet using "school_data.csv", comma replace

export delimited "school_data.csv", delim(",") replace

//outsheet as tab delimited

export delimited "school_data.tsv", delim(tab) replace

// insheet dataset

insheet using "school_data.csv", comma clear

import delimited school_data.csv, delim(",") clear



//Save as tab delimited

outsheet using "school_data.tsv", replace

//Open up tab delimited file

insheet using "school_data.tsv", clear

// describe data
describe

// labeling data 

label data "Voting on school expenditures"


// labeling variables 

label variable loginc "Log of income"

label variable vote "Voted for public school funding"

/*Quick Exercise The variables are as follows--- obs is an id for each observation, pub12, pub34 and pub5 are indicator variables for the number of children in public school, private is an indicator variable for whether the family has a child in privat4 school, years is the number of years in residence, school is an indicator for whether the parent is a teacher, logptax is log property tax, vote is an indicator for whether they voted for a school band measure and logeduc is log of years of education. Create appropriate variable names and labels for a more descriptive dataset.*/

la var obs unitid

la var pub12 "Respondent has between 1 and 2 children in public schools" 

la var pub34 "Respondent has between 3 and 4 children in public schools" 

la var pub5 "Respondent has 5 or more children public schools" 

la var years "Number of years in residence"

la var school "Respondent is a teacher"

la var logptax "Log property tax"

la var logeduc "Log years of education"

la var private "Respondent has child in private school"

// describe again

describe

// labeling values within variables 

tab vote

label define voteopts 0 "no" 1 "yes"

label values vote voteopts

tab vote

lab define yesno 0 "No" 1 "Yes"

la values pub12 pub34 pub5 school yesno

// transforming variables 

gen inc = exp(loginc)

sum loginc inc

la var inc "Income"

// recoding variables
sum inc

gen inc_bin = 0

replace inc_bin = 1 if inc > r(mean)

la var inc_bin "Respondent has above average income"

sum inc, detail

// Recode binary 1 if above median

sum inc, detail

gen inc_median = 0

replace inc_median = 1 if inc > r(p50)

la var inc_median "Respondent has above median income"

tab inc_median

egen inc_q = cut(inc), group(4)

recode inc_q (0 = 1 "First Quartile") ///
    (1 = 2 "2nd Quartile") ///
    (2 = 3 "3rd Quartile") ///
    (3 = 4 "4th Quartile"), gen(new_inc_q)

	
// compute new variable

gen ptax = exp(logptax)

gen taxrate = ptax / inc



//Create a new binary variable for whether or not the family has any children in public schools. Properly label your variable and variable values.

gen any_pub=0

replace any_pub=1 if pub12==1 | pub34==1 | pub5==1

gen any_pub2= pub12==1 | pub34==1 | pub5==1

la var any_pub "Respond has children in public schools"

la values any_pub yesno


//Create a new variable for percent of household income spent on education. Properly label your new variable.

gen educ_spend=exp(logeduc)

gen pct_inc_educ=(educ_spend/inc)*100

la var pct_inc_educ "Percent of household income spent on education"

sum pct_inc_educ

//Create a new variable for persons with low, moderate and high percentages of spending on education. Label the variable and value labels properly.

egen pct_inc_educ_q = cut(pct_inc_educ), group(4)

recode pct_inc_educ_q (0 = 1 "Low Spending") ///
    (1/2 = 2 "Moderate spending") ///
    (3 = 3 "High spending"), gen(new_pct_inc_educ_q)

exit

//Tabulate household spending and voting for public school funding. What do you find?



exit 

// end file
log close                               // close log
exit                                    // exit script
