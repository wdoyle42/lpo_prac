
//Assignment 11 Followup
//Use the Mroz data to answer the following
// questions about female employment.



//Run a logit model predicting labor force participation 
//based on characteristics of the woman and of the children.

use mroz, clear

local y inlf
local x educ
local controls kidslt6 kidsge6 age city exper


eststo basic_mod: logit `y' `x' `controls'



//Generate the marginal effects for all of the variables, 
//holding other predictors at their means.

margins, dydx(*) atmeans

margins, predict(pr) at(_all (mean) educ=(12.28 13.28))


//In comments in the do file, explain why the estimates 
//of an independent variable’s relationship to the outcome 
//are not constant across population.

//Non-linear link function--- logit scale doesn't move proportionally to
// changes in x

//Generate the predicted probability of working for a 
//range of mother’s years of education. 
//Create a plot or table for these predicted probabilities.

sum `x'
local mymin= r(min)
local mymax= r(max)
local steps=100
local mydiff =(`mymax'-`mymin')/`steps'

margins, predict(pr) at(_all (mean) `x'=(`mymin'(`mydiff')`mymax'))

marginsplot, recastci(rarea) ciopts(color(%20)) recast(line)


//Generated the predicted probability of working for range 
//of mother’s years of education interacted with husband’s wage. 
//Create a plot or table to explain the relationship you observe.


eststo interact_mod:logit `y' `controls' c.`x'##c.huswage

sum huswage


margins, predict(pr) at(_all (mean) ///
						`x'=(`mymin'(`mydiff')`mymax') ///
						huswage=(3.5 7.5 11.5))


marginsplot, recastci(rarea) ciopts(color(%20)) recast(line)
						


//Does including characteristics related to the husband’s education 
//significantly increase model fit from your preferred model? 
//Compare predictions of these two models graphically using the ROC.

eststo huseduc_model: logit `y' `x' `controls' huseduc

test huseduc

estimates restore basic_mod

lroc, name("lroc1",replace)

fitstat

estimates restore huseduc_model 

fitstat

lroc, name("lroc2",replace)




