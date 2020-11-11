/***
More Graphics Options
------------------------
Today we'll go over a few more things you can do in creating descriptives. 
We'll focus on categorical and binary data since many of you are using categorical 
predictors. 
***/



capture log close                       // closes any logs, should they be open
set linesize 90
log using "more_graphics.log", replace    // open new log

// NAME: MORE GRAPHICs
// FILE: more_graphics.do
// AUTH: Will Doyle
// INIT: 5 November 2017
// LAST: 11 November 2020

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



recode f1psepln (1=1 "No Plans") ///
				(2=2 "Don't Know'") ///
				(3=3 "Vo-tech") ///
				(4=4 "CC") ///
				(5=5 "4 yr") ///
				(6=6 "Early grad"), ///
				gen(f1psepln2)
		
recode bystexp (-1=-1 "Don't Know") ///
				(1=1 "Less than HS") ///
				(2=2 "HS/GED") ///
				(3=3 "2 yr") ///
				(4=4 "4 yr/ not graduate") ///
				(5=5 "Bachelor's") ///
				(6=6 "Master's") ///
				(7=7 "PhD/Advanced"), ///				
				gen(bystexp2)		


la var bystexp2 " "				
	
			
recode bysex(1=1 "Male") ///
			(2=2 "Female"), ///
			gen(bysex2)				
				
/***
Catplot
--------

Catplot is an add-on function that's designed for plotting categorical variables. If we do a 
basic catplot it would look like this: 

***/


//catplot
catplot bystexp, name(cat1, replace)

graph export cat1.png, name(cat1) replace

/***
![](cat1.png)

<br>
Where catplot can really come into its own is when using two categorical variables, 
for example plotting expectations by sex. 

***/

// Using over
catplot bystexp, over(bysex) name(cat2, replace) blabel(bar,format(%9.2f)) percent
graph export cat2.png, name(cat2) replace

/***
!()[cat2.png]
***/
	
/***
You can also include weights (here I'm using importance weights)
***/
	
// Using over
catplot bystexp2 [iw=bystuwt], over(bysex2) ///
				name(cat2, replace) ///
				blabel(bar,format(%9.1f)) ///
				percent ///
				ytitle("")  ///
				note("")

graph export expectations1.png	, replace	


/***


***/

/***
The "yvars" trick
------------------

If you use the options yvars, then you can individually manipulate each different
element of the bar graph. 

***/


// Yvars trick
catplot bystexp2, over(bysex2) /// 
				asyvars ///
				bar(1, bcolor(blue*.5)) ///
				bar(2, bcolor(yellow*.5)) ///
				bar(3, bcolor(green*.5)) ///
				bar(4, bcolor(orange*.5)) ///
				bar(5, bcolor(purple*.5)) ///
				bar(6, bcolor(gray*.5)) ///
				bar(7, bcolor(red*.5)) ///				
				bar(8, bcolor(mint*.5)) ///
				percent ///
				name(yvars_cat,replace)
				
/***
Schemes
--------
There are a wide variety of different schemes. Don't use Stata's default scheme.
Really. Please use anything else. 

***/				
set scheme economist

catplot bystexp2, over(bysex2) /// 
				asyvars 

set scheme s1color				

/***
*Quick Exercise* 

Create a catplot for plans by ses quartile, using asyvars

***/


/***
Other catplot options
----------------------

You can order catplots, and combine that with the `asyvars` option

***/


				
// Ordering
catplot bystexp2 , var1opts(sort(1) descending)

// yvars, again
catplot bystexp , var1opts(sort(1) descending) asyvars

/***
You can also recast catplot so that it's another type of plot, in this case
a dotplot. 
***/

// recast

catplot bystexp2 , var1opts(sort(1) descending) recast(dot)


/***
*Quick Exercise* 
Plot follow up one plabns (f1psepln2) by sex, then recast the results to a dot plot. 

***/


/***
CI Plot
------------

CI plot is another add on that can be really useful. As advertised, it plots 
confidence intervals around estimates. 

***/

//Ciplot


ciplot bynels2m , by(bystexp2)

/***
*Quick Exercise* change the plot to reading scores by plans and use better points. 
***/
			
//QE: Change to reading scores by plans and use better points

/***


***/

// Cibar

cibar bynels2m, over1(bystexp2) over2(bysex2) ciopts(msize(*0)) 


/***
The "collapse" trick
---------------------
Following up on our previous discussion of the "collapse" trick,
you can also use the size of the underlying dot to communicate the proportion 
of the sample represented within each dot. Here I plot the probablity of attending
a four year instituition as a function of socio economic status. 
***/

// Collapse trick

local myvar f2ps1sec

foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                        
			
graph twoway scatter foury byses1		

xtile byses_p =byses1, nquantiles(100)

preserve
collapse (mean) mean_four=fouryr (count) total_four=fouryr, by(byses_p)

graph twoway scatter mean_four byses_p [w=total_four], msymbol(circle_hollow) name(coll_attend)

restore 

/***
*Quick Exercise* Plot the probability of attending a two year institution (use f2ps1sec as a starting point) as a function of reading scores.  
***/
		
