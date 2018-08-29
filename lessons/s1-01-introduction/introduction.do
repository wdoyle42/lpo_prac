version 13 /* Can set version here, use version 13 as default */
capture log close /* Closes any logs, should they be open */

// This is a comment

* This is also a comment

/* This is an old school comment */
  
log using "introduction.log",replace /*Open up new log */ 

/* Introduction to Stata */ 
/* Provides a brief look at display, list, summarize, gen, by and if commands */
/* Will Doyle */
/* 8/22/18*/
/* Saved under in-class work */

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */ 

set scheme s1mono /* My  preferred graphics scheme */

use census     /*filename of dataset */


/*Using the display command for arithmetic */

display sqrt(42)

di sqrt(42)+4

di (sqrt(42)+4)-10


/* Taking a look at the data */

list

describe

codebook pop

/* Show me the data for the first ten states */
list if _n <11

/*Just state names and populations for the first ten states */
li state pop if _n<11


/*Take a look at deaths in the first 10 states. Which is highest, which is lowest? */
li state death if _n<11

/*Recoding variables */

*generate poplt5= poplt5/pop



/*Whoops!*/

gen poplt5_pr=  poplt5/pop


/* Summarize the new variable */

summarize poplt5_pr 

/* Summarize the new variable in more detail */

sum poplt5_pr, detail

/* Create a new variable for proportion of pop urban */

gen pop_urban=  popurban/pop

/*What is the mean, and median of the new variable ?*/

sum pop_urban, detail 

/*using the by command */  
  
*by region: sum poplt5_pr

/*Whoops */

bysort region: sum poplt5_pr 


/*Create a table of urbanicity by region */  

bysort region: sum pop_urban


/*Univariate graphics */

histogram poplt5_pr 

// bysort region: histogram poplt5_pr

/*Whoops */

histogram poplt5_pr, by(region) percent


/*Kernel density plot */

kdensity poplt5_pr

/*Which state is that, anyway?*/
  
li state poplt5_pr if poplt5_pr >.1 /*List state name and pop less than 5 if pop less than 5 is greater than .1 */

gen pop65p_pr=pop65p/pop

graph twoway scatter poplt5_pr pop65p_pr /*Scatterplot of young population as a function of older population */

graph twoway scatter poplt5_pr pop65p_pr, msymbol(none) mlabel(state) /*Add State Labels*/

graph  twoway scatter poplt5_pr pop65p_pr, ///
msymbol(none) mlabel(state)  mlabsize(tiny)/*Change Label Size*/    
  

/*Create variables for rate of marriages and divorces*/
/*Which region has the highest rates of marriage and divorce in the population?*/
/* What do the distributions of these two variables look like? */

/*What does a scatterplot say about the possible relationship? between the two*/  
  

  
log close /* close log file */

  
exit /*end do file */ 

