capture log close                       // closes any logs, should they be open
set linesize 90
log using "more_graphics.log", replace    // open new log

// NAME: MOAR GRAPHICs
// FILE: more_graphics.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 5 November 2017
// LAST: 14 November 2017

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// set link for data, plot, and table directories
global datadir "../data/"
global plotdir "../plots/"
global tabsdir "../tables/"

// set plot and table types
global gtype eps
global ttype html

// theme for graphics
set scheme s1color

// open up modified plans data
use ../s1-10-programming/plans_b, clear


//catplot
catplot bystexp, name(cat1)

// Using over
catplot bystexp, over(bysex) name(cat2)


// Yvars trick
catplot bystexp, over(bysex) asyvars

//QE: Create a catplot for plans by income quartile, using asyvars

// Ordering
catplot bystexp , var1opts(sort(1) descending)

// yvars, again
catplot bystexp , var1opts(sort(1) descending) asyvars

// recast

catplot bystexp , var1opts(sort(1) descending) recast(dot)

//QE recast to scatter

//Ciplot

ciplot bynels2m , by(bystexp)


//QE: Change to reading scores and use better points

// Cibar

cibar bynels2m, over1(bystexp)

// Collapse trick

local myvar f2ps1sec

foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                        

								  
										  
gen fouryr =0 
replace fouryr=1 if f2ps1sec==1|f2ps1sec==3
replace fouryr=. if f2ps1sec==. 

graph twoway scatter foury byses1		

xtile byses_p =byses1, nquantiles(100)


collapse (mean) mean_four=fouryr (count) total_four=fouryr, by(byses_p)
