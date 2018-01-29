version 15 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "cond_mean.log",replace /*Open up new log */

/* Conditional Means*/
/* Making the link between conditional means and regression */
/* Will Doyle */
/* 2018-01-09 */
/* Github Repo:  */

clear matrix

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */ 

set scheme s1color /* My  preferred graphics scheme */

graph drop _all    

/* Data Directory */

global ddir "../../data/"

/*Graphics Type*/
local gtype eps

/*Locals for analysis*/
local y fouryr

local test bynels2m bynels2r

local race amind asian black hispanic multiracial

local pared bypared_nohs bypared_2yrnodeg bypared_2yr bypared_some4 bypared_masters bypared_phd 

local income byses1

/**************************************************/
/* Outline */
/**************************************************/

/*Coding    */

local coding=1
    

/**************************************************/


/**************************************************/
/* Coding */
/**************************************************/
    
if `coding'==1{

use ${ddir}plans.dta, clear

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

recode byrace (4/5=4) (6=5) (7=6) (.=.), gen(byrace2)

label define byrace2 1 "Am.Ind." 2 "Asian/PI" 3 "Black" 4 "Hispanic" 5 "Multiracial" 6 "White"

label values byrace2 byrace2

gen urm=.
replace urm=0 if byrace2==4 | byrace2==6
replace urm=1 if byrace2==1 | byrace2==2 | byrace2==3 | byrace2==5
  
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

label define expect -1 "Don't Know" 1 "Less than HS" 2 "HS" 3 "2 yr" 4 "4 yr No Deg" ///
    5 "Bachelors" 6 "Masters" 7 "Advanced"

label values bystexp expect
  
tab bystexp,gen(exp_)

gen female=bysex==2
replace female=. if bysex==.

lab var female "Female"

replace bynels2m=bynels2m/100

replace bynels2r=bynels2r/100  
  
recode f2ps1sec (1=1) (2=2) (4=3) (3=4) (5/9=4), gen(first_inst)

label define sector 1 "Public 4 Year" 2 "Private 4 Year" 3 "Public 2 Year"  4 "Other"

label values first_inst sector
   
lab var bynels2m "10th Grade Math Scores"
lab var bynels2r "10th Grade Reading Scores"
lab var byses1 "SES v1"
lab var byses2 "SES v2"

save ${ddir}plans2.dta, replace

}/*End coding section */

else use ${ddir}plans2.dta, clear

/**************************************************/
    
/**************************************************/
/*Analysis*/
/**************************************************/

//Using the mean as a prediction

scalar drop _all

sort byses1

graph twoway scatter bynels2m byses1, msize(vtiny)


/* Predict using the mean */
egen uncond_mean=mean(bynels2m)

/*Generate residuals */
gen uncond_mean_error=bynels2m-uncond_mean

/* Square residuals */
gen uncond_mean_error_sq=uncond_mean_error*uncond_mean_error

/* Get Root mean squared error */
quietly sum uncond_mean_error_sq

scalar uncond_mean_mse=r(mean)

scalar uncond_mean_rmse=sqrt(uncond_mean_mse)

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    (line uncond_mean byses1,lcolor(blue)), legend(order(2 "Unconditional Mean"))

graph export "uncond_mean.`gtype'", replace

// OR . . . 

reg bynels2m 

scalar li uncond_mean_rmse


//Above average vs. below average 

// Generate prediction

egen sesq2=cut(byses1), group(2)

egen cond_mean2=mean(bynels2m), by(sesq2)

// Get residual
gen cond_mean2_error=bynels2m-cond_mean2

// Square residual
gen cond_mean2_error_sq=cond_mean2_error*cond_mean2_error

// Mean squared error
quietly sum cond_mean2_error_sq

scalar cond_mean2_mse=r(mean)

scalar cond_mean2_rmse=sqrt(cond_mean2_mse)

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
             (line uncond_mean byses1,lcolor(blue)) ///
             (line cond_mean2 byses1,lcolor(orange)), ///
              legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 groups") )

graph export "cond_mean2.`gtype'", replace



// Or . . .

reg bynels2m sesq2


/*Conditional mean by Quartiles*/

egen sesq4=cut(byses1), group(4)

egen cond_mean4=mean(bynels2m), by(sesq4)

gen cond_mean4_error=bynels2m-cond_mean4

gen cond_mean4_error_sq=cond_mean4_error*cond_mean4_error

quietly sum cond_mean4_error_sq

scalar cond_mean4_mse=r(mean)

scalar cond_mean4_rmse=sqrt(cond_mean4_mse)

scalar li

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
             (line uncond_mean byses1,lcolor(blue)) ///
             (line cond_mean2 byses1,lcolor(orange)) ///
             (line cond_mean4 byses1,lcolor(yellow)), ///    
             legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 groups" 4 "Conditional Mean, 4 Groups") )

graph export "cond_mean4.`gtype'", replace

egen read_mean4=mean(bynels2r), by(sesq4)

// Conditional mean for reading scores
gen read_mean4_error=bynels2r-cond_mean4

gen read_mean4_error_sq=read_mean4_error*read_mean4_error

quietly sum read_mean4_error_sq

scalar read_mean4_mse=r(mean)

scalar read_mean4_rmse=sqrt(read_mean4_mse)

graph twoway (scatter bynels2r byses1,msize(vtiny) mcolor(black)) ///
             (line read_mean4 byses1,lcolor(yellow)), ///    
             legend(order(2  "Conditional Mean, 4 Groups") )


/*Conditional means across Deciles*/

egen sesq10=cut(byses1), group(10)

egen cond_mean_10_math=mean(bynels2m), by(sesq10)

gen cond_mean10_error=bynels2m-cond_mean_10

gen cond_mean10_error_sq=cond_mean10_error*cond_mean10_error

quietly sum cond_mean10_error_sq

scalar cond_mean10_mse=r(mean)

scalar cond_mean10_rmse=sqrt(cond_mean10_mse)

// scalar li

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
             (line uncond_mean byses1,lcolor(blue)) ///
             (line cond_mean2 byses1,lcolor(orange)) ///
             (line cond_mean4 byses1,lcolor(yellow)) ///  
			 (line cond_mean_10_math byses1,lcolor(purple)), ///  
             legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 groups" 4 "Conditional Mean, 4 Groups" 5 "Conditional Mean, 10 Groups"))

graph export "cond_mean10.`gtype'", replace

// Conditional mean by ses and sex

//egen cond_mean_10_bysex= mean(bynels2m), by(sesq10 bysex)
 
/*Plotting conditional means for policy audiences*/

scalar n=_N/10

preserve

// 
collapse (mean) math_cond_mean=bynels2m (semean) math_cond_mean_se=bynels2m, by(sesq10)
scalar alpha=.05
scalar myt=invttail(n, alpha/2)
gen low_ci=math_cond_mean-(math_cond_mean_se*myt)
gen high_ci=math_cond_mean+(math_cond_mean_se*myt)
replace sesq10=sesq10+1

graph twoway (bar math_cond_mean sesq10, horizontal  ) ||  ///
             (rcap low_ci high_ci sesq10, horizontal msize(0) lcolor(gs12)) ///
			 , xtitle("NELS Math Score") ytitle("Socio-Economic Status") ///
			 legend(off) ///
			 ylabel(2(1)9 1 "Lowest 10%" 10 "Highest 10%",angle(45))
			 
graph export "horiz10.`gtype'", replace
			 
restore

/*Conditional Mean: Regression*/

reg bynels2m byses1

predict reg_predict

predict reg_error, residual

gen reg_error_sq=reg_error*reg_error

quietly sum reg_error_sq

scalar reg_mse=r(mean)

scalar reg_rmse=sqrt(reg_mse)

graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
             (line uncond_mean byses1,lcolor(blue)) ///
             (line cond_mean2 byses1,lcolor(orange)) ///
             (line cond_mean4 byses1,lcolor(yellow)) ///
             (line reg_predict byses1,lcolor(red)), ///        
             legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 groups" 4 "Conditional Mean, 4 Groups" 5 "Regression Prediction") )

graph export "regress.`gtype'", replace

scalar li

exit 


