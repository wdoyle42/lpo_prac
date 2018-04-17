
version 13 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "limited.log",replace /*Open up new log */

/* Models for Limited and Count Variables*/
/* Will Doyle */
/* 2018-04-03 */

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */

graph drop _all

global ddir "../../data/"

/*Controls*/

local coding=0
local order_analysis=0
local multi_analysis=1
local multi_ses_race=0
local auc=1
local compare=1

/*Locals for analysis*/
local y first_inst

local test bynels2m bynels2r

local race amind asian black hispanic multiracial

local pared bypared_nohs bypared_2yrnodeg bypared_2yr bypared_some4 bypared_masters bypared_phd 

local income  byses1

local plan_outcomes "No Plans" "CC/Votech" "Bachelors or More"

if `coding'==1{

  use "${ddir}plans.dta", clear

foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */

local race_names amind asian black hispanic_no hispanic_race multiracial white

tab(byrace), gen(race_)

local i=1

foreach val of local race_names{
  rename race_`i' `val'
  local i=`i'+1
}

label variable byincome "Income"
label variable amind "American Indian/AK Native"
label variable asian "Asian/ PI"
label variable black "African American"
label variable white "White"
label variable multiracial "Multiracial"


gen hispanic=0
replace hispanic=1 if hispanic_no==1|hispanic_race==1
replace hispanic=. if byrace==.

label variable hispanic "Hispanic"

local plan_names noplan dontknow votech cc fouryr earlygrad

tab(f1psepln), gen(plan_)

local i=1

foreach val of local plan_names{
  rename plan_`i' `val'
  local i=`i'+1
}


label variable noplan "Plans: No plans"
label variable dontknow "Plans: Don't know"
label variable votech "Plans: Voc/Tech School"
label variable cc "Plans: Comm Coll"
label variable fouryr "Four Year"
label variable earlygrad "Early Graduation"

/* Plans for those who have them */

gen order_plan=.
replace order_plan=1 if noplan==1| dontknow==1
  replace order_plan=2 if votech==1|cc==1
  replace order_plan=3 if fouryr==1

label define orderplan 1 "No Plans/DK" 2 "Votech/CC" 3 "Four Year"

 label values order_plan orderplan
  
local pareds bymothed byfathed bypared

local ed_names nohs hs 2yrnodeg 2yr some4  4yrgrad masters phd

foreach pared of local pareds{

tab(`pared'), gen(`pared'_)

local i=1

foreach val of local ed_names{
  rename `pared'_`i' `pared'_`val'
  local i=`i'+1
}

label variable `pared'_nohs "Less than HS"
label variable `pared'_hs "HS/GED"
label variable `pared'_2yr "CC" 
label variable `pared'_some4 "Four year attend"
label variable `pared'_4yrgrad "Bachelor's"
label variable `pared'_masters "Master's"
label variable `pared'_phd "PhD"
}

tab bystexp,gen(exp_)

gen female=bysex==2
replace female=. if bysex==.

replace bynels2m=bynels2m/100

replace bynels2r=bynels2r/100  

// recode bystexp

recode bystexp (-1/1=1) (2=2) (3/4=3) (5/7=4), gen(exp_new)

//drop _merge  

merge 1:1 stu_id using "${ddir}attend_type.dta" , nogen

//limited outcomes: number of applications and credits earned 

merge 1:1 stu_id using "${ddir}limited.dta"

foreach myvar of varlist f2ps1sec{ /* Start outer loop */
              foreach i of numlist -3 -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */

  
recode f2ps1sec (1=1) (2=2) (4=3) (3=4) (5/9=4), gen(first_inst)

replace first_inst=. if first_inst<0  

  label define sector 1 "Public 4 Year" 2 "Private 4 Year" 3 "Public 2 Year"  4 "Other"

  label values first_inst sector
  
 tab first_inst f2ps1sec
  
save apps_credits.dta, replace
  
}

else{
  use apps_credits.dta, clear 
  }


/*Analysis*/

  if `order_analysis'==1{
reg order_plan female `test' `race' `pared' `income'

eststo oprob_1:oprobit order_plan female `test' 
eststo oprob_2:oprobit order_plan female `test' `race' `pared' 
eststo oprob_3:oprobit order_plan female `test' `race' `pared' `income'

esttab oprob_* using raw_oprobit.rtf, ///
    not ///
    nostar ///
    b(2) ///
    se(2) ///
    aic ///
    replace

local cut1=_b[cut1:_cons]
local cut2=_b[cut2:_cons]

margins, predict(xb)  at(female=(0/1)) atmeans post /* Z in wooldridge*/

mat linpred=e(b)
scalar male_pred=linpred[1,1]
scalar female_pred=linpred[1,2]
        
graph twoway (function y=normalden(x,female_pred,1),range(-3 6)) ///
             (function y=normalden(x,male_pred,1), range(-3 6)), ///
             xline(`cut1',lpattern(dash)) /// 
             xline(`cut2',lpattern(dash)) ///
             legend(order(1 "LP for Women" 2 "LP for Men")) ///
             note("") title("") ///
             xtitle("Linear Prediction") ///
             text(.3 -2 "No Plans", size(vsmall)) ///
             text(.35 .9 "Votech/CC", size(vsmall)) ///
             text(.3 4.2 "Four Year", size(vsmall))
              
graph export "linear.pdf", replace

estimates restore oprob_3

    margins ,at(female=(0/1)) predict(outcome(1)) atmeans
    margins ,at(female=(0/1)) predict(outcome(2)) atmeans
    margins ,at(female=(0/1)) predict(outcome(3)) atmeans

/*Marginal Effects*/

 estimates restore oprob_3
 eststo marg1_ord:margins, dydx(`test' `race' `pared' `income') predict(outcome(1)) post
 estimates restore oprob_3
 eststo marg2_ord:margins, dydx(`test' `race' `pared' `income') predict(outcome(2)) post
 estimates restore oprob_3
 eststo marg3_ord:margins, dydx(`test' `race' `pared' `income') predict(outcome(3)) post

esttab marg?_ord using marg_ord.rtf, ///
    not ///
    nostar ///
    ci(2) ///
    b(2) ///
    replace    

	
forvalues j= 1/3{

estimates restore oprob_3

margins,  predict(outcome(`j')) at(bynels2m=(.1 .2 .3 .4 .5 .6 .7) (min) `race' `pared'  (mean) bynels2r byses1  )  post

// If you want to use marginsplot: 
marginsplot, recastci(rarea) recast(line) name("outcome_`j'")

mat t=J(7,3,.) /* Empty matrix */

mat a = (.1\.2\.3\.4\.5\.6\.7)   /*"at values"*/

mat myb=r(b) /*Estimated marginal effects */
mat myvc=r(V) /* variance/covariance */
mat myvar=vecdiag(myvc) /* Variances of marginal effects */
mat myse=J(1,7,.) /*Empty matrix for standard errors */

/*Sqrt of variances = standard errors */
  
forvalues i=1/7{
  mat myse[1,`i']=sqrt(myvar[1,`i'])
}
  
forvalues i=1/7 {
  mat t[`i',1] = myb[1,`i']                      /*Probabilities */
  mat t[`i',2] = myb[1,`i'] - 1.96*myse[1,`i']   /* Lower bound of ci */
  mat t[`i',3] = myb[1,`i'] + 1.96*myse[1,`i']   /* Upper bound of ci */
}


mat t=t,a   /*Combine with "at" values */

mat li t

mat colnames t = prob ll ul at

svmat t, names(col) /*Converts matrix into data */

// local outcome `: word `j' of `plan_outcomes' '

twoway (rarea ll ul at,  fcolor(emidblue) fintensity(25) lwidth(none)  )(line prob at), nodraw legend(off)  ///
       xtitle("Math Score" ) ytitle("Pr y=m") title("Outcome=`j'") ///
         yscale(range(0 1)) ylabel(0(.1)1)  scheme(s1color)
         
graph save "order_plan_`j'.gph", replace

drop prob ll ul at

}/*End loop over outcomes*/

graph combine order_plan_1.gph order_plan_2.gph order_plan_3.gph, ///
  rows(1)
  
graph export  "order.pdf", replace

eststo exp_oprob_1: oprobit exp_new female `test' `race' `pared' `income'

forvalues j= 1/4{

estimates restore exp_oprob_1

margins, predict(outcome(`j')) at(bynels2m=(.1 .2 .3 .4 .5 .6 .7) (min) `race' `pared'  (mean) bynels2r byses1  )  post

// If you want to use marginsplot: 
marginsplot, recastci(rarea) recast(line) name("exp_outcome_`j'")

graph save "exp_outcome_`j'.gph", replace
}

graph combine exp_outcome_1.gph exp_outcome_2.gph exp_outcome_3.gph exp_outcome_4.gph, ///
  rows(1)


/* Class exercise: work with student expectations */

} // End order analysis section


/********************************************************************************/
/* Multinomial Logit */
/********************************************************************************/    

if `multi_analysis'==1{

eststo multi_plan:mlogit order_plan female `test' `race' `pared' `income', baseoutcome(1)


estimates restore multi_plan
margins, dydx(`test' `race' `pared' `income') predict(outcome(1)) post
estimates restore multi_plan
margins, dydx(`test' `race' `pared' `income') predict(outcome(2)) post
estimates restore multi_plan
margins, dydx(`test' `race' `pared' `income') predict(outcome(3)) post


forvalues j= 1/3{
estimates restore multi_plan  
margins, predict(outcome(`j'))  at(bynels2m=(.1 .2 .3 .4 .5 .6 .7)  (min) `race' `pared'  (mean) bynels2r byses1  )  post

mat t=J(7,3,.)

mat a = (.1\.2\.3\.4\.5\.6\.7)                   

mat myb=r(b)
mat myvc=r(V)
mat myvar=vecdiag(myvc)
mat myse=J(1,7,.)
forvalues i=1/7{
  mat myse[1,`i']=sqrt(myvar[1,`i'])
}
  
forvalues i=1/7 {
  mat t[`i',1] = myb[1,`i']                      
  mat t[`i',2] = myb[1,`i'] - 1.96*myse[1,`i']   
  mat t[`i',3] = myb[1,`i'] + 1.96*myse[1,`i']   
} 

mat t=t,a                                          

mat li t

mat colnames t = prob ll ul at                     
svmat t, names(col)   
  
twoway (rarea ll ul at)(line prob at), legend(off)  ///
       xtitle("Math Score" ) ytitle("Pr y=m") title("Outcome `j'") ///
         yscale(range(0 1)) scheme(s1mono) ylabel(0(.1)1)
         
graph save "unorder_plan_`j'.gph", replace

drop prob ll ul at 


}/*End loop over outcomes*/


graph combine unorder_plan_1.gph unorder_plan_2.gph unorder_plan_3.gph,  ///
  rows(1)


graph export "unorder.pdf", replace


/* Multinomial Logit: better application, first institution attended */

eststo multi_first1: mlogit first_inst female `test' ,baseoutcome(1)
eststo multi_first2: mlogit first_inst female `test' `race' `pared',baseoutcome(1) 
eststo multi_first3: mlogit first_inst female `test' `race' `pared' `income' ,baseoutcome(1) 


esttab multi_first* using multi_first.tex, ///
    not ///
    b(2) ///
    se(2) ///
    aic ///
    replace


estimates restore multi_first3
margins, dydx(`test' `race' `pared' `income') predict(outcome(1)) post
estimates restore multi_first3
margins, dydx(`test' `race' `pared' `income') predict(outcome(2)) post
estimates restore multi_first3
margins, dydx(`test' `race' `pared' `income') predict(outcome(3)) post
estimates restore multi_first3
margins, dydx(`test' `race' `pared' `income') predict(outcome(4)) post


forvalues j= 1/4{

estimates restore multi_first3

margins, predict(outcome(`j')) at(bynels2m=(.1 .2 .3 .4 .5 .6 .7)  (min) `race' `pared'  (mean) bynels2r byses1  )  post

mat t=J(7,3,.)

mat a = (.1\.2\.3\.4\.5\.6\.7)                   

mat myb=r(b)
mat myvc=r(V)
mat myvar=vecdiag(myvc)
mat myse=J(1,7,.)
forvalues i=1/7{
  mat myse[1,`i']=sqrt(myvar[1,`i'])
}
  
forvalues i=1/7 {
  mat t[`i',1] = myb[1,`i']                      
  mat t[`i',2] = myb[1,`i'] - 1.96*myse[1,`i']   
  mat t[`i',3] = myb[1,`i'] + 1.96*myse[1,`i']
} 

mat t=t,a                                          

mat li t

mat colnames t = prob ll ul at

svmat t, names(col)   
  
twoway (rarea ll ul at, fcolor(emidblue) fintensity(50) lwidth(none) )(line prob at), nodraw legend(off)  ///
       xtitle("Math Score" ) ytitle("Pr y=m") title("Outcome `j'") ///
         yscale(range(0 1)) scheme(s1color) ylabel(0(.1)1)
         
graph save "unorder_first_`j'.gph", replace

drop prob ll ul at 

}/*End loop over outcomes*/

/*graph combine unorder_first_1.gph ///
              unorder_first_2.gph ///
              unorder_first_3.gph ///        
              unorder_first_4.gph, ///
              rows(2)
*/
//graph export unorder_first.pdf,replace
} /*end multi analysis section*/

if `multi_ses_race'==1{
/* By Race and SES */

/*Locals for analysis*/
local y first_inst

local test bynels2m bynels2r

local race_non amind asian black hispanic multiracial

local pared bypared_nohs bypared_2yrnodeg bypared_2yr bypared_some4 bypared_masters bypared_phd 

local income  byses1

local plan_outcomes "No Plans" "CC/Votech" "Bachelors or More"

eststo multi_first3: mlogit first_inst female `test' `race_non' `pared' `income' ,baseoutcome(1) 

sum byses1, detail

local no_steps=20
scalar no_steps=20
local mymin=r(min)
local mymax=r(max)
local diff=`mymax'-`mymin'
local step=`diff'/`no_steps'

local select_race white black hispanic    

foreach myrace of local select_race{

forvalues j= 1/4{

estimates restore multi_first3

if "`myrace'"=="white"{
estimates restore multi_first3
margins, predict(outcome(`j')) at((min) `race_non' `pared'  (mean) bynels2r bynels2m byses=(`mymin'(`step')`mymax'))  post
}
else{
estimates restore multi_first3

margins, predict(outcome(`j')) at((min) `race_non' `pared'  (mean) bynels2r bynels2m byses=(`mymin'(`step')`mymax') `myrace'=1)  post
}

mat myb=r(b)

mat li myb

/* Matrix with 3 columns, 1 for prediction, 2 for lb/ub*/
mat t=J(21,3,.)

/* Standard Errors */
mat myvc=r(V)
mat myvar=vecdiag(myvc)
mat myse=J(1,21,.)
forvalues i=1/21{
  mat myse[1,`i']=sqrt(myvar[1,`i'])
}

/*Populate matrix*/  
forvalues i=1/21 {
/*Predictions*/
  mat t[`i',1] = myb[1,`i']                      
  /*Lower bound*/
  mat t[`i',2] = myb[1,`i'] - 1.96*myse[1,`i']   
  /* Upper bound*/
  mat t[`i',3] = myb[1,`i'] + 1.96*myse[1,`i']
} 


mat allx=e(at)

mat a=allx[1...,15]

mat t=t,a                                          

mat li t

mat colnames t = prob ll ul at

svmat t, names(col_`j'_`myrace')   

} /* end outcome loop*/

} /*end race loop*/


foreach i of numlist 1/4{
graph twoway line col_`i'_*1 col_1_white4, ///
legend(order(1 "White" 2 "Black" 3 "Hispanic")) name(multi_out_`i', replace) ///
xtitle("SES") ytitle("Pr(Attend)") 
graph save multi_out_`i'.gph, replace 
}

grc1leg2 "multi_out_1.gph" "multi_out_2.gph" "multi_out_3.gph" "multi_out_4.gph", ///
legendfrom("multi_out_1.gph") ///
rows(1) ///
name(multi,replace) ///
xcommon ycommon

}/* end section on complex predictions */


/* AUC for mlogit */
/* This takes FOREVER (approximately) */

estimates restore multi_first3
if `auc'==1{    
mlogitroc first_inst female `test' `race' `pared' `income'
}

/* Comparing Models */
if `compare'==1{
estimates restore oprob_3

estat ic

estimates restore multi_plan

estat ic
}

}/* end multi analysis section */




else di "No analysis"

exit
