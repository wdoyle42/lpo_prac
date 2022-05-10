
version 15 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "limited.log",replace /*Open up new log */

/* Models for Limited and Count Variables*/
/* Will Doyle */
/* 2022-05-10 */


clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */

graph drop _all

global ddir "../../data/"

/*Controls*/

local coding=1
local analysis=1
local count_section=0
local truncated_section=1


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
  
merge 1:1 stu_id using "${ddir}attend_type.dta"

drop _merge
//limited outcomes: number of applications and credits earned 

merge 1:1 stu_id using "${ddir}limited.dta"

drop _merge

foreach myvar of varlist f2ps1sec{ /* Start outer loop */
              foreach i of numlist -3 -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End outer loop */

  

// Easier to remember names:

gen n_apps=f2napp1p

replace n_apps=. if  n_apps<0

gen credits=f3tzpostern

replace credits=. if credits <0
  
recode f2ps1sec (1=1) (2=2) (4=3) (3=4) (5/9=4), gen(first_inst)

replace first_inst=. if first_inst<0  

  label define sector 1 "Public 4 Year" 2 "Private 4 Year" 3 "Public 2 Year"  4 "Other"

  label values first_inst sector
  
 tab first_inst f2ps1sec
  
save "${ddir}apps_credits.dta", replace
  
}

else{
  use "${ddir}apps_credits.dta", clear
}



/*Analysis*/

  if `analysis'==1{

  
 if count_section==1{ 
  
  // Count outcome: number of apps
  
  sum n_apps
  
  kdensity n_apps, name(dist_apps)
  
  tab n_apps
 
  //OLS
  
eststo ols_full_count:  reg n_apps female `race' `pared' `test' `income', vce(robust)
 
  //Poisson: assumption is that variance=mean
  
eststo poisson_full:  poisson n_apps female `race' `pared' `test' `income'
 
 
  // Negative binomial: more flexible, generally better

eststo nbreg_simple:  nbreg n_apps  `income'
 
eststo nbreg_full:  nbreg n_apps female `race' `pared' `test' `income'
 
esttab nbreg_simple nbreg_full using nbreg_results.rtf, ///
	not ///
    nostar ///
    se(2) ///
    b(2) ///
    replace     

  // Marginal effects
  
  margins, dydx(female `race' `pared' `test' `income')
  
  margins, dydx(*)
 
  
  estimates restore nbreg_full
  
  
  estimates replay ols_full_count

  
  /*
       n               number of events; the default
      ir               incidence rate (equivalent to predict ..., n nooffset)
      pr(n)            probability Pr(y = n)
      pr(a,b)          probability Pr(a < y < b)
      xb               linear prediction
      stdp             standard error of the linear prediction
*/
  
  // Setup for margins
  
sum byses1, detail

local no_steps=100
local mymin=r(min)
local mymax=r(max)
local diff=`mymax'-`mymin'
local step=`diff'/`no_steps'

  
  
  // Margins: n
  estimates restore nbreg_full
  
  margins, predict(n) at(byses=(`mymin'(`step')`mymax')  (min) female `race' `pared'  (mean) `test'  )  post
 
 marginsplot, ///
	recastci(rarea)  ///
	ciopts(color(eltblue%25) lwidth(0)) ///
	recast(line) ///
	plotopts(lcolor(black)) ///
	name(nbreg_n) ///
	ytitle("Predicted Number of Applications") ///
	xtitle("SES") ///
	title("")

	
 
  // Margins: pr y=n
  
  
estimates restore nbreg_full
  
margins, predict(pr(4)) at(byses=(`mymin'(`step')`mymax')  (min) female `race' `pared'  (mean) `test'  )  post
 
 marginsplot, ///
 	recastci(rarea)  ///
	ciopts(color(eltblue%25) lwidth(0)) ///
	recast(line) ///
	plotopts(lcolor(black)) ///
	name(nbreg_p) ///
	ytitle("Pr(Applications=4)") ///
	xtitle("SES") ///
	title("")
	
	
  //Margins: pr a<y<b
 
 estimates restore nbreg_full
  
margins, predict(pr(5,100)) at(byses=(`mymin'(`step')`mymax')  (min) female `race' `pared'  (mean) `test'  )  post
 
marginsplot, recastci(rarea)  ///
	ciopts(color(eltblue%25) lwidth(0)) ///
	recast(line) ///
	plotopts(lcolor(black)) ///
	name(prymoren) ///
	ytitle("Pr(Applications>5)") ///
	xtitle("SES") ///
	title("")


	
sum bynels2m, detail

local no_steps=100
local mymin=r(min)
local mymax=r(max)
local diff=`mymax'-`mymin'
local step=`diff'/`no_steps'	


estimates restore nbreg_full
  
margins, ///
	predict(pr(2,.)) ///
	at( ///
	(mean) `test'   ///
	bynels2m=(`mymin'(`step')`mymax') 	///
	(min) female `race' `pared' ///
	hispanic= (0 1) ///
	) ///
	post

marginsplot, ///
	recastci(rarea) ///
	ci1opts(color(orange%25) lwidth(0)) ///
		ci2opts(color(purple%25) lwidth(0)) ///
	recast(line) ///
	plot1opts(lcolor(blue)) ///
		plot2opts(lcolor(yellow)) ///
	ytitle("Pr(>2 Applications)") ///
	xtitle("Math Scores") ///
	title("")



// Another model: zero-inflated poisson (zip)

eststo zip_full: zip n_apps female `race' `pared' `test' `income', ///
				inflate(female `race' `pared' `test' `income')

// And . . . zero-inflated negative binomial

eststo zinb_fll: zinb n_apps female `race' `pared' `test' `income', ///
				inflate(female `race' `pared' `test' `income')

  } // End 1st section 


  if truncated_section==1{
 
 // Truncated Outcome: number of credits
 
 sum credits
 
 kdensity credits, name(density_credits)
 
 eststo ols_full_censor: reg credits female `race' `pared' `test' `income', vce(robust)
 
 eststo tobit_full: tobit credits female `race' `pared' `test' `income', ll(0)
 

 
 /*      xb               linear prediction; the default
      stdp             standard error of the linear prediction
      stdf             standard error of the forecast
      pr(a,b)          Pr(a < y < b)
      e(a,b)           E(y|a < y < b)
      ystar(a,b)       E(y*),y* = max{a, min(y,b)}
*/
 
 /* Marginal effects */
 margins , dydx(female `race' `pared' `test' `income')
 
 // Prob >0
 
 estimates restore tobit_full
 margins, predict(pr(0,5000)) at(byses=(`mymin'(`step')`mymax')  (min) female `race' `pared'  (mean) `test'  )  post
 
marginsplot, recastci(rarea) recast(line) name(pr_credits)

 
 //E(y|y>0)
 
 estimates restore tobit_full
 margins, predict(e(0,5000)) at(byses=(`mymin'(`step')`mymax')  (min) female `race' `pared'  (mean) `test'  )  post
 
marginsplot, recastci(rarea) recast(line) name(e_credits)

//ystar
 
 
 
 estimates restore tobit_full
margins, predict(ystar(0,5000)) at(byses=(`mymin'(`step')`mymax')  (min) female `race' `pared'  (mean) `test'  )  post
 
marginsplot, recastci(rarea) recast(line) name(e_credits)

  } //end truncated_section
  } //end analysis section


