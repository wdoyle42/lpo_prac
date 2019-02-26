capture log close

// Assignment 6 Key
// Will Doyle
// INIT: 2/26/19
// Lots of ways to plot interactions

global ddir "../../data/"

use "${ddir}plans2.dta"

local ttype rtf

//1. Using the plans dataset, specify a model that uses math scores as the dependent variable 
//and contains at least two interactions.

eststo reg_result:reg bynels2m c.byses1##c.bynels2r i.order_plan##i.female

//2. Plot the interaction at least four different ways, using both bar plots and line plots.

local x1 byses1
local x2 bynels2r

quietly summarize `x1', detail
local steps=100
local x1_min=r(min)
local x1_max=r(max)
local x1_diff=(`x1_max'-`x1_min')/`steps'

quietly summarize `x2', detail
local x2_25=r(p25)
local x2_50=r(p50)
local x2_75=r(p75)

estimates restore reg_result

margins, predict(xb) ///
		 at(         ///
			(mean) _all ///
			`x1'=(`x1_min'(`x1_diff')`x1_max') ///
			`x2'=(`x2_25' `x2_50' `x2_75') ///
			) ///
			saving(predict1, replace )
			
// marginsplot way			
marginsplot, recastci(rarea) ciopts(fcolor(gs10) fcolor(%50)) recast(line) ///
			legend(order( 1 "25th Percentile Reading" 2 "50th Percentile Reading" 3 "75th Percentile Reading")) ///
			name(margin1, replace)

			/*
// by hand way
use predict1, clear

/*
_at2
22.36
30.04
36.96
*/

graph twoway (rarea _ci_lb _ci_ub _at1 if _at2<23) ///
			 (line _margin _at1 if _at2<23) 			 

*/

					 
local x1 bynels2r
local x2 byses1

quietly summarize `x1', detail
local steps=100
local x1_min=r(min)
local x1_max=r(max)
local x1_diff=(`x1_max'-`x1_min')/`steps'

quietly summarize `x2', detail
local x2_25=r(p25)
local x2_50=r(p50)
local x2_75=r(p75)

estimates restore reg_result

margins, predict(xb) ///
		 at((base) _factor ///
			`x1'=(`x1_min'(`x1_diff')`x1_max') ///
			`x2'=(`x2_25' `x2_50' `x2_75') ///
			)
marginsplot, recastci(rarea) ciopts(fcolor(gs10) fcolor(%50)) recast(line) ///
			legend(order( 1 "25th Percentile SES" 2 "50th Percentile SES" 3 "75th Percentile SES")) ///
			name(margin2, replace)


estimates restore reg_result

margins, predict(xb) ///
		 at((mean) _all ///
			order_plan= (1 2 3) ///
			female= (0 1) ///
			) saving (predict2, replace)

marginsplot, recast(scatter) plotopts(xlabel(,angle(45)))

marginsplot, xdimension(order_plan) recast(bar) plotopts(barwidth(.9))

/*
preserve

use predict2, clear

graph twoway (bar _margin _at3, by(_at4)) ///
			(rcap _ci_lb _ci_ub _at3, by(_at4))
		
restore 		
*/

//3. Create a table that shows predictions and confidence intervals 
//  from the complex interactions in at least two different ways.

local x1 byses1
local x2 bynels2r
local ttype rtf

quietly summarize `x1', detail
local steps=10
local x1_min=r(min)
local x1_max=r(max)
local x1_diff=(`x1_max'-`x1_min')/`steps'

quietly summarize `x2', detail
local x2_25=r(p25)
local x2_50=r(p50)
local x2_75=r(p75)

estimates restore reg_result

local percentiles 25 50 75

foreach i of local percentiles{

quietly summarize `x2', detail

local x2_val=r(p`i')

estimates restore reg_result

margins, predict(xb) ///
		 at((mean) _all ///
			`x1'=(`x1_min'(`x1_diff')`x1_max') ///
			`x2'=`x2_val' ///
			) post

estimates store margins_`i'
}			
			
esttab margins_* using margins.`ttype' , margin label nostar ci replace //			

estimates restore reg_result

local ttype rtf
margins, predict(xb) ///
		 at((mean) _all ///
			order_plan= (1 2 3) ///
			female= (0 1) ///
			) saving (predict2, replace) post


estimates store margins_cat

esttab margins_cat using margins_cat.`ttype' ,  ///
	margin label nostar ci replace unstack 			

			


		
			
//4. Create an additional model (does not need to be nested) that includes a non-linear transform (log transform or quadratic).

gen log_math=log(bynels2m)

eststo reg_results_2:reg log_math c.byses1##c.bynels2r i.order_plan##i.female

//5. Plot the results of that model.

local x1 byses1
local x2 bynels2r

quietly summarize `x1', detail
local steps=100
local x1_min=r(min)
local x1_max=r(max)
local x1_diff=(`x1_max'-`x1_min')/`steps'

quietly summarize `x2', detail
local x2_25=r(p25)
local x2_50=r(p50)
local x2_75=r(p75)

estimates restore reg_result

margins, expression(exp(predict(xb))) ///
		 at(         ///
			(mean) _all ///
			`x1'=(`x1_min'(`x1_diff')`x1_max') ///
			`x2'=(`x2_25' `x2_50' `x2_75') ///
			) ///
			saving(predict1, replace )
			
// marginsplot way			
marginsplot, recastci(rarea) ciopts(fcolor(gs10) fcolor(%50)) recast(line) ///
			legend(order( 1 "25th Percentile Reading" 2 "50th Percentile Reading" 3 "75th Percentile Reading")) ///
			name(margin1, replace)

	
eststo reg_results_3:reg bynels2m byses1 c.bynels2r##c.bynels2r 

local x1 bynels2r

quietly summarize `x1', detail
local steps=100
local x1_min=r(min)
local x1_max=r(max)
local x1_diff=(`x1_max'-`x1_min')/`steps'

margins, predict(xb) ///
		 at(         ///
			(mean) _all ///
			`x1'=(`x1_min'(`x1_diff')`x1_max') ///
			) 
			
marginsplot, recastci(rarea) ciopts(fcolor(gs10) fcolor(%50)) recast(line) ///
				name(margin_quad, replace)
						
exit 

//6. In a word document, write up your results, including descriptions of the
// graphics and the tables.
