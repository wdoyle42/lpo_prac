// Simpler Interaction Plots
// Will Doyle
// 2022-03-17 
// Examples of how to use margins and marginsplot to understand interactions

set scheme s1color

use ../../data/plans2.dta

local y bynels2m

local controls byses1 ib(6).bypared


// Binary to binary interactions

// Interact fouryr with female 

eststo reg1: reg `y' i.female##i.fouryr `controls'

estimates restore reg1 

margins, predict(xb) at((mean) _continuous ///
							(base) _factor ///
							female=(0 1) ///
							fouryr=(0 1)) ///
							post
						
marginsplot

marginsplot, recast(scatter) ///
			ytitle("Predicted Math Test Scores") ///
			legend(order(3 "Does Not Plan to Go to a Four Year" ///
						4 "Plans to Go to a Four Year")) ///
						title("") ///
			xscale(range(-.5(1)1.5))
			
// Interact binary with continuous

eststo reg2: reg `y' c.byses1##i.fouryr `controls'		

estimates restore reg2 

margins, predict(xb) at((mean) _continuous ///
						(base) _factor ///
						byses1=(-2(.1)2) ///
						fouryr=(0 1) ///
							) 
							
marginsplot, recast(line) ///
			recastci(rarea) ///
			ciopts(color(%50)) ///
			ytitle("Predicted Math Test Scores") ///
			legend(order(3 "Does Not Plan to Go to a Four Year" ///
						4 "Plans to Go to a Four Year"))  ///
						legend(cols(1)) ///
						title("") 

// Interact continuous with continuous

eststo reg3: reg `y' c.byses1##c.bynels2r `controls'

summarize byses1, detail 

local sesmin=r(min)
local sesmax=r(max)
local diff=`sesmax'-`sesmin'
local number_steps=50
local step=`diff'/`number_steps'

summarize bynels2r, detail 

local read_lo=r(p25)
local read_med=r(p50)
local read_hi=r(p75)

estimate restore reg3

margins, predict(xb) at((mean) _continuous ///
						(base) _factor ///
						byses1=(`sesmin'(`step')`sesmax') ///
						bynels2r=(`read_lo' `read_med' `read_hi' ) ///
							)

marginsplot, recast(line) ///
			plotopts(lcolor(black)) ///
			recastci(rarea) ///
			ciopts(color(%50)) ///
			ytitle("Predicted Math Test Scores") ///
			legend(order(1 "25th Percentile Reading Scores" ///
						2 "Median Reading Scores" /// 
						3 "75th Percentile Reading Scores") )  ///
						legend(cols(1)) ///
						title("") 
						
// Categorical w/ Categorical Interaction
						
eststo reg4: reg `y' i.order_plan##i.bypared 

/*  					942         1  did not finish high school
                        3,044         2  graduated from high school or
                                         ged
                        1,663         3  attended 2-year school, no
                                         degree
                        1,597         4  graduated from 2-year school
                        1,758         5  attended college, no 4-year
                                         degree
                        3,466         6  graduated from college
                        1,785         7  completed master^s degree or
                                         equivalent
                        1,049         8  completed phd, md, other
                                         advanced degree
*/

/* 1,041         1  ---No Plans/DK
                        3,880         2  ---Votech/CC
                        8,955         3  ---Four Year
*/

estimates restore reg4

margins, predict(xb) ///
		 at((mean) _continuous /// 
			(base) _factor ///
			order_plan=(1 2 3) /// 
			bypared=(2 6 7))

marginsplot			
			
exit 
