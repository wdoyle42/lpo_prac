
/***

# Getting started in Stata


Today we'l do a brief run-through of interacting with Stata. Next week we'll go more in-depth. 
***/



version 16 /* Can set version here, use version 13 as default */
capture log close /* Closes any logs, should they be open */

// This is a comment

* This is also a comment

/* This is an old school comment */
  
log using "introduction.log",replace /*Open up new log */ 

// Introduction to Stata  
// Provides a brief look at display, list, summarize, gen, by and if commands 
// Will Doyle 
// 8/25/21

clear

clear mata // Clears any fluff that might be in mata 

estimates clear // Clears any estimates hanging around 

set more off // Get rid of annoying "more" feature 

set scheme s1color // My  preferred graphics scheme 

use ad, clear    /*filename of dataset */



/*** This data comes from the American Community Survey of 2019. It covers all of the  in the United States. It includes characteristics of these areas, include education, income, home ownership and others as described below.  
***/

/***
| Name  | Description   |
|---|---|
| name   | Name of Micro/Metro Area   |
| college_educ   | Percent of population with at least a bachelor's degree   |
| perc_commute_30p   | Percent of population with commute to work of 30 minutes or more   |
| perc_insured  | Percent of population with health insurance   |
| perc_homeown  | Percent of housing units owned by occupier   |
| geoid | Geographic FIPS Code (id) |
| income_75  | Percent of population with income over 75,000   |
| perc_moved_in   | Percent of population that moved from another state in last year   |
|  perc_in_labor force  | Percent of population in labor force   |
| metro | Metropolitan Area? Yes/No |
| state  | State Abbreviation |
| region  | Census Region |
| 
***/


/*Using the display command for arithmetic */

display sqrt(42)

di sqrt(42)+4

di (sqrt(42)+4)-10


/* Taking a look at the data */

list

describe

codebook 

/* Show me the data for the first ten cities */
list if _n <11

/*Just state names and percent in labor force for the first ten states */

list 


/*Take a look at deaths in the first 10 states. Which is highest, which is lowest? */


/*Recoding variables */

*generate perc_in_labor=  perc_in_labor/100



/*Whoops!*/

gen pr_in_labor=  perc_in_labor/100


/* Summarize the new variable */

summarize pr_in_labor 

/* Summarize the new variable in more detail */

sum pr_in_labor, detail

/*using the by command */  
  
*by region: sum perc_in_labor

/*Whoops */

bysort region: sum perc_in_labor

/*Create a table of college educateed by region */  

bysort region: sum college_educ


/*Univariate graphics */

histogram college_educ

// bysort region: histogram poplt5_pr

/*Whoops */

histogram college_educ, by(region) percent

/*Kernel density plot */

kdensity college_educ

/*Which city is that, anyway?*/
  
li state name if college_educ>50


graph twoway scatter income_75 college_educ /*Scatterplot of earnings by college educated*/

graph  twoway scatter income_75 college_educ, mcolor(%30) xtitle("Percent with Bachelor's Degree") ytitle("Percent with Income>75k") 
  
  
log close /* close log file */

  
exit /*end do file */ 

