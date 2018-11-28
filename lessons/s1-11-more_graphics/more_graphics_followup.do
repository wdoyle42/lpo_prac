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
	

// Using over
catplot bystexp2 [iw=bystuwt], over(bysex2) ///
				name(cat2, replace) ///
				blabel(bar,format(%9.1f)) ///
				percent ///
				ytitle("")  ///
				note("")

graph export expectations1.png	, replace	


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
				percent 
				
set scheme economist

catplot bystexp2, over(bysex2) /// 
				asyvars 

set scheme s1color				

//QE: Create a catplot for plans by ses quartile, using asyvars

egen ses_q=cut(byses1), group(4)

catplot f1psepln, over(ses_q) asyvars name(cat_ses_q)
 
la var f1psepln " "
 
local quartiles First Second Third Fourth
local i=0
foreach quart of local quartiles {
catplot f1psepln if ses_q==`i', ///
					asyvars ///
					blabel(bar,format(%9.0f)) ///
					percent ///
					name(cat_ses`i',replace) ///
					title("`quart'") ///
					ytitle("") ///
					yscale(range(0(10)100)) ///
					ylabel(0(10)100)
					
graph save cat_ses`i', replace
local i=`i'+1
}

graph combine cat_ses0.gph cat_ses1.gph cat_ses2.gph cat_ses3.gph, rows(2)

grc1leg2 cat_ses0.gph cat_ses1.gph cat_ses2.gph cat_ses3.gph, rows(2)  

 
// Ordering
catplot bystexp2 , var1opts(sort(1) descending)

// yvars, again
catplot bystexp , var1opts(sort(1) descending) asyvars


// recast

catplot bystexp2 , var1opts(sort(1) descending) recast(dot)


//QE plans by sex, recast to dot

catplot f1psepln , over(bysex) var2opts(sort(1) descending) recast(dot) 

//Ciplot

ciplot bynels2m , by(bystexp2)

ciplot bynels2r, by(f1psepln) msymbol(circle) xlabel( , angle(45) labsize(vsmall)) /// 
			ytitle(" Math Scores")  horiz 

//QE: Change to reading scores by plans and use better points

// Cibar

cibar bynels2m, over1(bystexp2) over2(bysex2) ciopts(msize(*0)) 

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

gen read2=round(bynels2r)

preserve

collapse (mean) mean_two=twoyr (count) total_two=twoyr, by(read2)

graph twoway scatter mean_two read2 [w=total_two], ///
			msymbol(circle_hollow) ///
			msize(*.5)  ///
			name(coll_attend3, replace) ///
			ytitle("Proportion Attending Two Year") ///
			xtitle("Reading Score (rounded)")

restore
