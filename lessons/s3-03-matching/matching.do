version 15 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "match.log",replace /*Open up new log */

/* Matching Examples */
/* Following Zhao, 2004 examples of difft kinds of matching */
/* Will Doyle */
/* 180507 */
/* Practicum Folder */


*ssc install nnmatch
*ssc install psmatch2
*ssc install sensatt
*net search attnd
*ssc install rbounds
/* install st0026_2 */
/* Super Useful Source: http://www.ssc.wisc.edu/sscc/pubs/stata_psmatch.htm*/    

clear

clear mata /* Clears any fluff that might be in mata */

clear matrix

set matsize 4000

set maxvar 10000

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */ 

graph set print logo off /*No Stata logo on graphics */

use attain2, clear

/*Only bachelor's intending students */

keep if bystexp>=5 & bystexp~=.   

/*recodoe dv*/

gen bach_plus=.
replace bach_plus=1 if f3attainment>=6 & f3attainment<.
replace bach_plus=0 if f3attainment<6
    
drop if bach_plus==.	
	
/*recode treatment */
drop cc
gen cc=.
replace cc=1 if first_inst==3
replace cc=0 if first==1 | first_inst==2 | first_inst==4

/*Locals */

local y bach_plus

local t cc

local controls  byses1  bynels2m bynels2r amind asian black hispanic white  bysex 

/*Basic pattern*/
    
tab  `t' `y' ,row 

/*Examining possible selection bias */

 kdensity byses1 if `t'==1, ///
 addplot(kdensity byses1 if `t'==0, lpattern(dash))  ///
 legend(order(1 "Treated"  2 "Untreated")) ///
 title("Unmatched Sample")

graph save balance_ses_unmatch.gph, replace 
 
/* Using teffects structure*/
teffects psmatch (`y') (`t' `controls')
 
/* Balance on various covariates */

ttest byses1, by(`t')

ttest bynels2m, by(`t')


/*Naive Estimate */

ttest `y' ,by(`t')

reg `y' `t' `controls', vce(robust)



/* Full matching Table */


/* Propensity Score Matching: 1 to 1 */
  psmatch2 `t'   ///
         `controls', ///
         outcome(`y') ///
         neighbor(1) ///
         caliper(.05) ///
         noreplacement /// /* This gives 1 to 1 */
         common

         
pstest `controls', treated(`t')  both

psgraph


/* Teffects -- PS matching, 1 to 1 */
    teffects psmatch (`y') (`t' `controls'), ///
        nn(1) ///
		caliper(.25) ///
            atet 
         

/*Replciate psmatch2, almost*/

teffects psmatch (`y') (`t' `controls', probit) , nn(1) atet caliper(.25)

tebalance summarize

mat balance=r(table)

estout matrix(balance) using balance.rtf, replace


		 
/* Teffects -- Nearest Neighbor matching, 4 neighboring units */
    teffects nnmatch (`y' `controls')  ///
    (`t'), ///
    nn(4) 
	
/*use teffects to estimate difference, algorithm: ps matching, 5 nn, .15 calipers */ 
teffects psmatch (`y') (`t' `controls', probit) , nn(5) atet caliper(.15)

/* use teffects to estimate difference, algorithm: nn matching on mahalanobis metric 5 nn, .2 caliper width */	

teffects nnmatch (`y'  `controls') (`t') , nn(5)   atet 

/* use teffects to exactly match on race and gender	 */
teffects nnmatch (`y' `controls' ) (`t'),  ///
ematch( amind asian black hispanic white bysex ) 


/* use psmatch2 estimate via ps matching, 5 nn .15 caliper, */

	
 	
/* Propensity Score Matching: 1 to 4 */
  psmatch2 `t'   ///
         `controls', ///
         outcome(`y') ///
         neighbor(5) ///
         caliper(.15) 

		 
/* Plotting Kdensity based on the psmatch weights */		 

local k=1		 
gen fwt=round(10^(`k')*_weight,1)

local t cc
kdensity byses1 if `t'==1 [fweight=fwt], /// 
	addplot(kdensity byses1 if `t'==0 [fweight=fwt]) ///
	name(balance_ses_match) ///
	legend(order(1 "Treated"  2 "Untreated")) ///
	title("Matched Sample")
 
graph save balance_ses_match.gph, replace
		 
grc1leg2 balance_ses_unmatch.gph balance_ses_match.gph

exit 		 
 	
/* Propensity Score Matching: 1 to 4 */
  psmatch2 `t'   ///
         `controls', ///
         outcome(`y') ///
         neighbor(4) ///
         caliper(.25) 
		 

/*How this gets results */

reg `y' `t' [iweight=_weight]
 

/*Regression on balanced sample */
    
reg `y' `t' `controls' [iweight=_weight] 


/*Regression with ps as control */
reg `y' `t' `controls'  _pscore


/* Stratification on ps: using weighted results */

sum _pscore, detail


scalar pscore25=r(p25)


scalar pscore50=r(p50)


scalar pscore75=r(p75)

scalar n_full=r(N)

/* First quartile */
reg `y' `t' `controls'  if _pscore<=pscore25

scalar e1=_b[`t']

scalar se1=_se[`t']

scalar var1=se1^2

scalar n1=e(N)

/*Second Quartile */

reg `y' `t' `controls' if _pscore>=pscore25  & _pscore<pscore50

scalar e2=_b[`t']

scalar se2=_se[`t']

scalar var2=se2^2

scalar n2=e(N)

/*Third Quartile */

reg `y' `t' `controls'   if _pscore>=pscore50  & _pscore<pscore75

scalar e3=_b[`t']

scalar se3=_se[`t']

scalar var3=se3^2

scalar n3=e(N)

/*Fourth Quartile */
  
reg `y' `t' `controls'   if _pscore>pscore75

scalar e4=_b[`t']

scalar se4=_se[`t']

scalar var4=se4^2

scalar n4=e(N)

/*Combining estimates */

scalar myest=(e1*(n1/n_full))+(e2*(n2/n_full))+(e3*(n3/n_full))+(e4*(n4/n_full)) /*Weighted average of estimates, based on sample size*/

scalar myvar=(var1*(n1/n_full))+(var2*(n2/n_full))+(var3*(n3/n_full))+(var4*(n4/n_full)) /*Weighted average of variances */

scalar myse=sqrt(myvar)

di "Estimate is " myest

di "SE is " myse


/* Propensity Score Matching: Calipers, multiple matches */
  
  psmatch2 `t' ///
         `controls' , ///
         outcome(`y') ///
         caliper(.25) ///
         common ///
         neighbor(3) 
         

pstest _pscore `controls', treated(`t') both


 kdensity _pscore if `t'==1 , ///
 addplot(kdensity _pscore if `t'==0, lpattern(dash))  ///
 legend(order(1 "Treated"  2 "Untreated")) 
 
graph save balance_ses_unmatch.gph 

/* Propensity Score Matching: Calipers on propensity score and Mahalonobis metric */
  psmatch2 `t' ///
         `controls' , ///
         outcome(`y') ///
         caliper(.25) ///
		 neighbor(4) /// 
         common ///
         mahal(bysex byses1)
         

pstest _pscore `controls' , both


/* Teffects -- Nearest Neighbor matching, 4 neighboring units */
    teffects nnmatch (`y' `controls')  ///
    (`t'), ///
    nn(4) 


/* AIPW: Augmented Inverse Probability Weights */
   teffects aipw (`y' `controls') ///
    (`t' `controls') 

	
predict pscore, ps

gen pscore_weight=.
replace pscore_weight=1/pscore if `t'==1
replace pscore_weight=pscore/(1-pscore) if `t'==0

preserve
sample 1000, count

graph twoway (scatter pscore bynels2m [w=pscore_weight] if `t'==1, msize(vtiny) msymbol(circle_hollow)) ///
    (scatter pscore bynels2m [w=pscore_weight] if `t'==0,msize(vtiny) msymbol(circle_hollow) ), ///
legend (order(1 "PS, CC Attend" 2 "PS, 4yr Attend")) ytitle("Propensity Score")

restore



/*Using sensatt */


/*Similar confounders */

  
sensatt `y' /// /*Outcome*/
        `t' /// /*Treatment */
       `controls' , ///  /*varlist */
       alg(attnd) ///
       p(black) ///
       reps(100)
	   
	   
/*"Killer" confounders */

local probs .25 .5 .75

mat results=J(3,3,.)

local column=1


foreach prob1 of local probs{

  local row=1
  foreach prob2 of local probs{
  

sensatt `y' /// /*Outcome*/
        `t' /// /*Treatment */
       `controls' , ///  /*varlist */
       alg(attnd) ///
       p11(`prob2') ///
       p10(`prob1') ///
       p01(`prob2') ///
       p00(`prob1') ///
       reps(50) 

di "`row',`column'"

mat results[`row',`column']=r(att)

local row=`row'+1


}
  local column=`column'+1 
}

matrix rownames results="p1=25" "50" "75"
matrix colnames results="p0=25" "50" "75"

mat li results


log close
exit 

