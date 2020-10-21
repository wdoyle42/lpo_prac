/***
Data validation
================
LPO 9951 | Fall 2020

Data validation refers to the process of ensuring that the characteristics of your data match the known characteristics of the population as measured by other analysts. If you have large discrepancies between your estimates and the estimates compiled by others, this is a clear "red flag" that something has gone wrong. Usually this is a problem that can be solved by going back to cleaning the data, but sometimes your sample may diverge in important ways from the samples collected by others. You will need to state why this is the case in your write-up of the data.

Data validation can be done in several ways:

-   You can compare the estimates from your dataset with the estimates from another analysis of the same dataset. This is what we will do with the datasets used in this class.
-   Sometimes you will be the first one to analyze your dataset. In this case, you need to look for others who have collected similar samples and compare with them.
-   Sometimes you won't have any other samples to work with. In this case, you'll need to see if there are population data that might be useful. Many people use the Census as a "check" on the data they have collected.
-   Last, you need to use common sense. If you have data on private elite institutions of higher education, and you calculate an average tuition of $2,000, you can rest assured that you have not found a hidden bargain but rather a flaw in your data.
***/



capture log close                       // closes any logs, should they be open
set linesize 90
log using "validation.log", replace    // open new log

// NAME: Data cleaning
// FILE: validation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 22 October 2014
// LAST: 21 October 2020
     
clear all                               // clear memory


global ddir "../../data/"

/***
Calculating estimates and comparing them with known results
-----------------------------------------------------------

Today, we'll use the `plans` dataset. We're going to compare our results with several tables published by NCES. Let's start with educational expectations of high school sophomores. We start by survey setting the data:


***/

// load plans data
use ${ddir}plans.dta

// set up data for survey commands 
svyset psu [pw = bystuwt], str(strat_id) singleunit(scaled)

/***

### Account for missing data

The next step is to account for missing data properly:

***/

// set up local to hold variables we wish to recode 
local allvar bystexp bysex byrace byses1 f1psepln 

mvdecode `allvar', mv(-9/-2)

// Recoding

recode bystexp (-1=8 )

// Variable and value labeling

label define expect 1 "Less than HS" /// 
					2 "HS/GED" ///
					3 "2 Yr" ///
					4 "Attend 4" ///
					5 "BA Degree" ///
					6 "Master's" ///
					7 "PhD" ///
					8 "Don't Know'"

label values bystexp expect	

label define race 1 "American Indian/AK Native" ///
				  2 "Asian/PI" ///
				  3 "African American/Black" ///
				  4 "Hispanic No Race Specified" ///
				  5 "Hispanic, Race Specified" ///
				  6 "Multiracial, non Hispanic" ///
				  7 "White" 

label values byrace race	
			  
/***
### Get estimates

Next, we tabulate expectations for college and compare it to a known estimate.


***/


// student expectations for education 
tab bystexp

svy: proportion bystexp

/***

Once you create estimates from a command like `proportion` 
you can save them for later, using the `estimates store` command.
These can be replayed using `replay` and can be brough back into memory using `restore` 

***/
// store estimates
estimates store expect_tab

// show estimates
estimates replay expect_tab

// put estimates back in memory
estimates restore expect_tab

/*** 
Estimates can be stored using a simplified approach, using
`eststo` and then the name of the estimates to be stored. 
***/

//one line version

eststo expect_tab: svy: tabulate bystexp

/***

### Nicer tables

We get output in the console, but let's use the `eststo` and `esttab` commands to store our estimates and produce nicer tables. Using `esttab` alone, we'll get a nicely formatted table in the console. By adding `... using <file>` we save an `.rtf` version of the same table. We can easily paste this table in a paper. 
***/

// use estpost to output results in format that esttab likes
estpost svy: tabulate bystexp

eststo expect_tab

// save as table using esttab
esttab expect_tab using expect_tab.rtf, /// 
		b(3) /// /* 3 decimal points for estimates */
		se(4) /// /* 4 decima points for se's */
		nostar /// /* No sig tests */
		nomtitles /// No column titles
		nonumbers /// No column numbers
		replace /* replace if file exists */

/***
### Validate with published data

Now that we have a clean table to look at, is this the same as [Table 2 on page 22 of the report](http://nces.ed.gov/pubs2005/2005338.pdf#50)? Yes. Checking the standard errors on page B-3 reveals that these were also correctly done. Now we need to check this for all of the other variables in our dataset.

<br>

#### Not-so-quick Exercise

> I want you to replicate [Table 34 on page 128 of NCES 2005-338](http://nces.ed.gov/pubs2005/2005338.pdf#154). We'll split this up, but I want the class to come up with a single table that has exactly the same results as the NCES document.

<br><br>			  
***/


// end file     
log close
exit
