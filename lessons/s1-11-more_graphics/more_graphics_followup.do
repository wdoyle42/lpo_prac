capture log close                       // closes any logs, should they be open
set linesize 90
log using "more_graphics.log", replace    // open new log

// NAME: MOAR GRAPHICs
// FILE: more_graphics.do
// AUTH: Will Doyle
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
catplot bystexp, over(bysex) name(cat2, replace) blabel(bar,format(%9.2f)) percent

// Yvars trick
catplot bystexp, over(bysex) asyvars

//QE: Create a catplot for plans by ses quartile, using asyvars


egen ses_q=cut(byses1), group(4)

catplot f1psepln, over(ses_q) asyvars name(cat_ses_q)
 
local quartiles First Second Third Fourth
/*
local i=0
foreach quart of local quartiles {
catplot f1psepln if ses_q==`i', ///
					asyvars ///
					blabel(bar,format(%9.0f)) ///
					percent ///
					name(cat_ses`i') ///
					title("`quart'")
					
graph save cat_ses`i', replace
local i=`i'+1
}

graph combine cat_ses0.gph cat_ses1.gph cat_ses2.gph cat_ses3.gph, rows(2)
*/

// Ordering
catplot bystexp , var1opts(sort(1) descending)

// yvars, again
catplot bystexp , var1opts(sort(1) descending) asyvars

// recast

catplot bystexp , var1opts(sort(1) descending) recast(dot)


//QE plans by sex, recast to dot


catplot f1psepln , over(bysex) var2opts(sort(1) descending) recast(dot)

//Ciplot

ciplot bynels2m , by(bystexp)

ciplot bynels2r, by(f1psepln) msymbol(circle) xlabel(,angle(45) labsize(vsmall)) 

//QE: Change to reading scores by plans and use better points

// Cibar

cibar bynels2m, over1(bystexp) over2(bysex) ciopts(msize(*0))

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

preserve
collapse (mean) mean_four=fouryr (count) total_four=fouryr, by(byses_p)

graph twoway scatter mean_four byses_p [w=total_four], msymbol(circle_hollow) name(coll_attend)

restore 

				 										 
gen twoyr =0 
replace twoyr=1 if f2ps1sec==4|f2ps1sec==5|f2ps1sec==6
replace twoyr=. if f2ps1sec==. 

xtile bynels2m_p =bynels2m, nquantiles(100)

preserve

collapse (mean) mean_two=twoyr (count) total_two=twoyr, by(bynels2m_p)

graph twoway scatter mean_two bynels2m_p [w=total_two], msymbol(circle_hollow) name(coll_attend2,replace)

restore 


gen math2=round(bynels2m)

preserve

collapse (mean) mean_four=fouryr (count) total_four=fouryr, by(math2)

graph twoway scatter mean_four math2 [w=total_four], msymbol(circle_hollow) msize(*.5) name(coll_attend3, replace)

restore
