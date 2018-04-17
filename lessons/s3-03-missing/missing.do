version 14 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "mvn.log",replace /*Open up new log */

    /*Techniques for handling missing data */
/* Will Doyle */
/* 180417 */
/* Practicum Folder */

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */

  graph drop _all

/*Controls*/

local coding=0
local imputation=0
local analysis=1

/*Locals for analysis*/
local y fouryr

local test bynels2m bynels2r

local race amind asian black hispanic multiracial

local pared bypared_nohs bypared_2yrnodeg bypared_2yr bypared_some4 bypared_masters bypared_phd 

local income byincome byses1


if `coding'==1{

  use plans, clear

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
  
/*Missing on dv? */
*keep if f1psepln!=.
  
save plans2, replace
  
}

else{
  use plans2, clear
}


/* Regression without multiple imputation */

svyset psu [weight=f1pnlwt], strata(strat_id) singleunit(scaled)

svy: logit fouryr `test' `race' `pared' `income'
eststo full

svy: logit fouryr `test' `race' 
eststo race

svy: logit fouryr `test'  `pared' 
eststo pared

svy: logit fouryr `test'  `income'

eststo income


#delimit;
estout race pared income full  using "fouryear_noi.rtf",
label
replace
       cells(b (fmt(2) label("Coefficient")) se(fmt(2) label("S.E") par))
       stats (df_m df_r F p  N, labels ("D.F. Model" "D.F. Residual" "F" "p" "N") fmt(0 0 2 2 0))
;
  
#delimit cr
  

if `imputation'==1 {

local mice=0

local mvn=1

mvpatterns `test'

mvpatterns `race'

mvpatterns `pared'

mvpatterns `income'

mvpatterns `y' `test' `race'

mi set mlong

drop if fouryr==.

gen four_yr_flag=fouryr==.

kdensity byses1 if four_yr_flag==0 , addplot(kdensity byses1 if four_yr_flag==1)


#delimit;

mi register imputed
bynels2m
bynels2r
byses1
amind
asian
black
hispanic
multiracial
bypared_nohs
bypared_2yrnodeg
bypared_2yr
bypared_some4
bypared_masters
bypared_phd 
;

mi register regular
fouryr
byincome
;


#delimit cr

if `mice'==1{

mi impute chained ///
 (regress) bynels2m bynels2r byses1 (logit) amind asian black hispanic multiracial bypared_nohs bypared_2yrnodeg bypared_2yr bypared_some4 bypared_masters bypared_phd , ///   
        burnin(10) /// /* Don't run! took a loooooooong time */
        dots ///
        augment ///
        savetrace(mice_stats, replace) ///    
        add(5) 
    
save mi_impute_mice, replace

/* Check convergence */
use mice_stats, clear

keep if m==1

tsset iter 

tsline bynels2m_mean, name(gr1) nodraw
tsline bynels2m_sd, name(gr2) nodraw

tsline byses1_mean, name(gr3) nodraw
tsline byses1_sd, name(gr4) nodraw

graph combine gr1 gr2 gr3 gr4

} /*End mice sub loop */



if `mvn'==1{

#delimit ;
    
set seed 040621 ;

mi impute mvn /// /*Assuming mvn pattern, can use multiple methods to predict*/
bynels2m 
bynels2r 
byses1
amind 
asian
black
hispanic
multiracial
bypared_nohs
bypared_2yrnodeg
bypared_2yr
bypared_some4
bypared_masters
bypared_phd 

/*Nonmissing data*/
=
fouryr
byincome
  

,  add(5)  /*Number of imputations: Use 5 to start*/
alldots
noisily
prior(ridge, df(0.5))
burnin(2000)
burnbetween(500)
initmcmc(em,  iter(2000) tol(1e-6))
savewlf(wlf, replace)
;


#delimit cr

save plans_impute_mvn, replace

/* Checking convergence of MCMC run */

 use wlf, clear

 tsset iter

 tsline wlf, ytitle(Worst linear function) xtitle(Burn-in period) name(wlf_line)
 graph save converge_wlf, replace 

 ac wlf, title(Worst linear function) ytitle(Autocorrelations) ciopts(astyle(none)) note("") name(wlf_ac)

graph save autocorr_wlf, replace 

use plans_impute_mvn, clear

} /* End MVn sub loop */


       
}

/********************************/
/*End Imputation Section*/
/********************************/


 else{
 use plans_impute_mvn, clear
}



if `analysis'==1{

//use mi_impute_mice, clear

mi svyset psu [weight=f1pnlwt], strata(strat_id) singleunit(scaled)

drop if fouryr==.

/* Table of Descriptive Statistics */

eststo descriptives: mi estimate, nosmall imputations(1/5) : svy: mean `y' `test' `race' 

//`pared' `income'


/*The following lines of code are needed to get estout to get along with mi/svy */
local vars :rownames e(V_mi)

mat myvar=e(V_mi)
scalar numvars=colsof(myvar)
mat mv=vecdiag(myvar)
matrix myse=J(numvars,1,0)
scalar icol=1
while icol<=numvars{
    matrix myse[icol,1]=sqrt(mv[1,icol])
    scalar icol=icol+1
}

mat myse=myse'
mat colnames myse= `vars'
estadd matrix myse

/*End code chunk */


#delimit ;
estout descriptives  using "descriptives.rtf",
       label
       replace
       cells( b_mi(fmt(2) label("Mean")) myse(par fmt(2) label("S.E.")))
       stats(N, fmt(0))
       title ("Descriptive Statistics for variables in analysis")
       unstack
;

#delimit cr


/*Logistic Regression*/

  
/*The following lines of code are needed to get estout to get along with mi/svy */    
mi estimate, nosmall: svy: logit fouryr `test' `race' `pared' `income'

local vars  :rownames e(V_mi)

mat myvar=e(V_mi)
scalar numvars=colsof(myvar)
mat mv=vecdiag(myvar)
matrix myse=J(numvars,1,0)
scalar icol=1
while icol<=numvars{
    matrix myse[icol,1]=sqrt(mv[1,icol])
    scalar icol=icol+1
}

mat myse=myse'
mat colnames myse= `vars'
estadd matrix myse
/*End code chunk */


eststo full

mi estimate, nosmall: svy: logit fouryr `test' `race' 


/*The following lines of code are needed to get estout to get along with mi/svy */    
local vars  :rownames e(V_mi)
mat myvar=e(V_mi)
scalar numvars=colsof(myvar)
mat mv=vecdiag(myvar)
matrix myse=J(numvars,1,0)
scalar icol=1
while icol<=numvars{
    matrix myse[icol,1]=sqrt(mv[1,icol])
    scalar icol=icol+1
}

mat myse=myse'
mat colnames myse= `vars'
estadd matrix myse
/*End code chunk */


eststo race


mi estimate, nosmall: svy: logit fouryr `test'  `pared' 


local vars  :rownames e(V_mi)

mat myvar=e(V_mi)
scalar numvars=colsof(myvar)
mat mv=vecdiag(myvar)
matrix myse=J(numvars,1,0)
scalar icol=1
while icol<=numvars{
    matrix myse[icol,1]=sqrt(mv[1,icol])
    scalar icol=icol+1
}

mat myse=myse'
mat colnames myse= `vars'
estadd matrix myse


eststo pared

mi estimate, nosmall: svy: logit fouryr `test' `income'
local vars  :rownames e(V_mi)

mat myvar=e(V_mi)
scalar numvars=colsof(myvar)
mat mv=vecdiag(myvar)
matrix myse=J(numvars,1,0)
scalar icol=1
while icol<=numvars{
    matrix myse[icol,1]=sqrt(mv[1,icol])
    scalar icol=icol+1
}

mat myse=myse'
mat colnames myse= `vars'
estadd matrix myse


eststo income



#delimit ;
estout race pared income full  using "fouryear.rtf",
label
replace
       cells(b_mi(fmt(2) label("Coefficient") star) myse(fmt(2) label("S.E") par))
      stats (df_m_mi df_r_mi F_mi N ,labels("DF: Model" "DF: Residual" "F" "N") fmt (0 0 2 0))
;

#delimit cr

}
exit
