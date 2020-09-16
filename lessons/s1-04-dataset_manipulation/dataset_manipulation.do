/***
# Dataset Manipulation
# Will Doyle
# 2020-09-16


Introduction
-------------

Learning to manipulate datasets is a key skill for statistical analysis. Today we'll work on four skills: subsetting data using preserve and restore commands, appending data, doing a simple one-to-one merge, and collapsing data.



***/


capture log close                       // closes any logs, should they be open
log using "dataset_manipulation.log", replace    // open new log

// NAME: Dataset manipulation
// FILE: dataset_manipulation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 9 September 2012
// LAST: 16 Sep 2020

clear all                               // clear memory


//Data import

import delimited "https://stats.idre.ucla.edu/wp-content/uploads/2016/02/hsb2-2.csv", clear
 
// Excel

import excel "tabn304.10.xls", cellrange(A5:L64) clear

// set globals for url data link and local data path
global urldata "https://stats.idre.ucla.edu/stat/stata/seminars/svy_stata_intro/apipop"

// read web data into memory
use $urldata, clear


/***
Subsetting with `preserve` and `restore`
----------------------------------------

A feature and sometimes curse of Stata is that it can only hold one dataset in active memory at a time. As a feature, it helps you keep your work organized and, through numerous warning messages, tries to make sure you don't lose your work by accidentally forgetting to save or mindlessly overwritting your data. The feature feels more like a curse when you have multiple datasets that you would like to work with simultaneously or, as we will do below, split a single dataset into smaller parts.

To repeatedly subset a large dataset, there are two primary choices:
1. Reload the full dataset into memory after each subset and save
2. Use the `preserve` and `restore` commands

In the code below, notice how the `preserve` and `restore` commands bookend the `keep` command, which keeps only those observations that fulfill the `if` statement (in this case, the type of school). The steps are:
1. preserve dataset in memory
2. subset to keep only school type that we want
3. save new subset dataset
4. restore old dataset
***/


// split into three datasets: elementary, middle, and high school

// -1- preserve dataset in memory
// -2- subset to keep only school type that we want
// -3- save new subset dataset
// -4- restore old dataset

// elementary schools
preserve
keep if stype == 1    
tab stype 
                 
save elem, replace
restore

// high schools
preserve
keep if stype == 2                      
save hs, replace
restore

// middle schools (keep this one in memory so no preserve/restore needed)
keep if stype == 3                      
save middle, replace

/***
Appending Data
--------------

Appending data is done when we want to add additional *observations* to an existing dataset, using a dataset that has exactly the same variable names but different observations. Suppose you have data on high schools, middle schools, and elementary schools on a variety of performance indicators and you'd like to merge them together. The syntax uses, appropriately enough, the `append` command, which takes the format `append <new dataset>` (the command assumes the first dataset is the one in memory; remember that the middle school subset data are still in memory):
***/

// merging via the append command
append using elem   
append using hs


/*** 
The `append` command will not copy over labels from the using dataset, so you'll need to make sure they're right in the master dataset. The most common error with an append command is to not have exactly matching variable names.
***/

/***
Merging Data
------------

You can also use Stata's `merge` command to do an append operation in special cases. This happens when the merging variable doesn't have repeated *observations* in the two datasets, which in turn have exactly the same variable structure. Think of a Venn diagram where the circles contain exactly the same types of information, but don't overlap; in combining them, we've really just grown them into one bigger circle. One of the virtues of using `merge` when `append` will suffice is that you have access to more information about where the data came from once you're done.
***/

 
// merging via the merge command

use elem, clear

merge 1:1 snum using hs, gen(_merge_a)

merge 1:1 snum using middle, gen(_merge_b)

/***
Once you've completed the merge, you can take a look at the \_merge\_\* variables that were generated to see where the data came from.
***/




// show merge stats for each merge
tab _merge_a
tab _merge_b


/* Quick Exercise: Create a dataset that has just middle and elementary schools.
 Do this using first the append command and then the merge command.*/
 
 // Elementary schools in memory
 use elem, clear
 
 append using middle
 
 use elem, clear
 
 merge 1:1 snum using middle, nogen

/***
One-to-one merges
-----------------

A one-to-one merge is when you have exactly the same *observations* but new variables to add to the dataset. Say you have *observations* with variables split across datasets, e.g., School 1 has variables A, B, and C in dataset 1 and variables X, Y, and Z in dataset two. As long as School 1 has a unique identifier---a name, an id number, etc---you can `merge` these two datasets together so that you have access to all of the school's variables for your analysis.

First, we need to subset our data again, only this time by splitting along columns (*variables*) rather than rows (*observations*):
***/


// split dataset by variables
use $urldata, clear

preserve
keep snum api00 api99 ell meals         // variable set 1
save api_1, replace
restore
keep snum full emer                     // variable set 2
save api_2, replace


// merging back together (api_2 in memory)
merge 1:1 snum using api_1

// view merge stats
tab _merge

// collapsing data

// reload main dataset, since we didn't preserve it before
use $urldata, clear


/***
*QUICK EXERCISE
Create a dataset that has only mobility and percent tested. Next create another dataset that has only the year round and percent responding variables. Now merge these two datasets together using a one-to-one merge.*
***/


/***
Collapsing data
---------------

Collapsing data refers to summarizing data across a type and creating a new dataset as a result. Say we want to create a county-level dataset from our school data, using the average figures for the schools across a set of characteristics. The command would look like this:

***/

// count of unique counties in dataset
unique cnum

preserve
// mean of pcttest and mobility within countyr
collapse (mean) pcttest mobility, by (cnum)
restore

// Total enrollment by district

collapse (sum) district_enroll=enroll, by(dnum)

save district_enroll, replace

use $urldata, clear

merge m:1 dnum using district_enroll
 
// give count of number of observations (should be number of unique counties)
count

/***
QUICK EXERCISE
Create a district level dataset that contains district level averages for the following variables:

-apioo
-api99
-ell
-meals 

Then do the same thing using just district medians.

***/

// end file
log close                               // close log
exit                                  // exit script


