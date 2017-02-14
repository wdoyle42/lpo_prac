version 13 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "model_design_do.log",replace /*Open up new log */

/* Model specification, interactions, prediction and plots after interaction*/
/* Will Doyle */
/* 1170214 */
/* Practicum Folder */

clear

clear matrix

graph drop _all

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */

ssc install bcuse

ssc install nnest

bcuse wage2, clear

label variable wage "Wages from work in last month"

label variable hours "Weekly hours"

label variable IQ "IQ test"

label variable KWW "Knowledge of world of work"

label variable educ "Years of education"

label variable tenure "Months in current job"

label variable age "Age"

label variable married "Married"

label variable black "African-American"

label variable south "South"

label variable urban "Urban"

label variable sibs "No. Siblings"

label variable brthord "Birth order"

label variable meduc "Mother's years of school"

label variable feduc "Father's years of education"

label variable lwage "ln Wage"

renvars *, lower

save wage2, replace

/*Constants*/

    local sig=.05

local sigtail=`sig'/2

/*Plots of data */

graph twoway scatter wage educ 

graph export "wage_educ.pdf", replace 

graph twoway qfit wage age||scatter wage age 

graph export "wage_age.pdf", replace  

/*Missing Data */ 
    
di _N
  
reg lwage hours educ age

reg lwage hours educ age meduc

reg lwage hours educ age feduc

reg lwage hours educ age feduc meduc

reg lwage hours educ age if e(sample)==1

reg lwage hours educ age meduc if e(sample)==1

gen meduc_flag=meduc==.
  
/*NOOOOOOOO!!! Stepwise regression*/

stepwise, pr(.2): reg lwage hours educ age meduc feduc tenure south married black urban sibs kww iq brthord

stepwise, pr(.05): reg lwage hours educ age meduc feduc tenure south married black urban sibs kww iq brthord

stepwise, pr(.2) : reg lwage south brthord iq kww sibs feduc tenure  married black urban hours educ age meduc

stepwise, pr(.05): reg lwage south brthord iq kww sibs feduc tenure  married black urban hours educ age meduc
  
stepwise, pr(.2) : reg lwage south brthord  kww sibs feduc tenure  married black  hours educ age meduc

stepwise, pr(.05): reg lwage south brthord  kww sibs feduc tenure  married black  hours educ age meduc


/*Functional Form */
  
/*RESET test */

reg lwage hours age educ

estat ovtest

estat ovtest, rhs

gen agesq=age^2

label var agesq "Age squared"

reg lwage hours educ age agesq

test age agesq

gen educsq=educ^2

la var educsq "Education squared"

reg lwage hours age educ educsq

test educ educsq

/*Preferred method */

reg lwage hours age agesq educ educsq

test age agesq

test educ educsq

/* Davidson-MacKinnon Test:non-nested alternatives */

reg lwage hours iq 

nnest educ age

/* Interactions */

gen educ_adj=educ+.2
  
graph twoway (scatter wage educ if black==0, msize(small) mcolor(red)) ///
    (scatter wage educ_adj if black==1, msize(small) mcolor(blue))   ///
        (lfit wage educ if black==0, lcolor(red))  ///
            (lfit wage educ if black==1, lcolor(blue)), ///
                legend(order(1 "White" 2 "Black")) 

/*Binary-binary interaction*/

gen black_marry=black*married
  
eststo black_marry: reg lwage hours age educ i.black##i.married iq meduc south urban

/*Binary-continous interaction*/

eststo black_educ: reg lwage hours age i.black##c.educ married  iq meduc south urban

/*Continuous-Continuous interaction*/

eststo age_educ : reg lwage hours age educ c.age#c.educ black married iq meduc south urban 

/// Margins after interactions

estimates replay black_marry 

estimates restore black_marry

local mydf=e(df_r)

margins , predict(xb) at(black=(1 0) married=(0 1) south=1 urban=1 (mean) hours age educ iq meduc ) post

mat mypred=e(b)'

mata: st_matrix("mypred", exp(st_matrix("mypred")))

svmat mypred

mat mypred1=e(b)'

svmat mypred1

local no_predict=rowsof(mypred)

di "no of preds is `no_predict'"

egen mycount=fill(1(1)`no_predict')

graph twoway bar mypred1 mycount in 1/4, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000) 
      
estimates restore black_marry

margins , predict(stdp) at((mean) _all black=(1 0) married=(0 1) south=1 urban=1) post nose

mat mystdp=e(b)'

svmat mystdp

gen ub_log=mypred11+ (invttail(`mydf',`sigtail')*mystdp)
gen lb_log=mypred11- (invttail(`mydf',`sigtail')*mystdp)

gen ub=exp(ub_log)
gen lb=exp(lb_log)


graph twoway (bar mypred1 mycount if mycount==1, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
              (bar mypred1 mycount if mycount==2, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
               (bar mypred1 mycount if mycount==3, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
                (bar mypred1 mycount if mycount==4, barw(.6) base(0) ytick(100(100)1000) ylabel(0(100)1000)) ///
                    (rcap ub lb mycount in 1/`no_predict'), ///
                        xlabel(1 "Unmarried, Black" 2 "Married, Black" 3 "Unmarried, White" 4 "Married, White") ytitle("Predicted Wages")   xtitle("") legend(off)

       
/* Clear out prediction variables */    
drop mypred*
drop mystdp*
drop ub*
drop lb*    

/* Working with continuous vs. Continuous interactions */
sum age, detail

local mymin=r(min)
local mymax=r(max)

/*Step through education in 2 year intervals, get predictions across range of age*/

foreach myeduc of numlist 10(2)16{

estimates restore age_educ
    
margins, predict(xb) at((mean) _all age=(`mymin'(1)`mymax') educ=`myeduc') post
mat pred_ed`myeduc'=e(b)'
mat li pred_ed`myeduc'
svmat pred_ed`myeduc'

estimates restore age_educ

margins, predict(stdp) at((mean) _all age=(`mymin'(1)`mymax') educ=`myeduc') nose post
mat pred_se_ed`myeduc'=e(b)'
mat li pred_se_ed`myeduc'
svmat pred_se_ed`myeduc'
}

foreach myeduc of numlist 10(2)16{
    gen exp_pred`myeduc'=exp(pred_ed`myeduc'1)
    gen ub`myeduc'=exp(pred_ed`myeduc'+(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
    gen lb`myeduc'=exp(pred_ed`myeduc'-(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
}

/* Need my at values */

egen age_levels=fill(`mymin'(1)`mymax')    

twoway line exp_pred10 exp_pred12 exp_pred14 exp_pred16 age_levels in 1/11, ///
       legend(order(1 "10 Years" 2 "12 Years" 3 "14 Years" 4 "16 Years"))  ytitle("Wages") xtitle("Age") name(educ_mult)

/* Plot at different levels with confidence intervals */
twoway (rarea ub10 lb10 age_levels in 1/11, color(gs14)) ///
    (rarea ub16 lb16 age_levels in 1/11, color(gs14)) ///
        (line exp_pred10 age_levels in 1/11, lcolor(blue) ) ///
            (line lb10 age_levels in 1/11, lcolor(blue) lwidth(thin) lpattern(dash)) ///
                (line ub10 age_levels in 1/11, lcolor(blue) lwidth(thin) lpattern(dash)) ///
                    (line exp_pred16 age_levels in 1/11, lcolor(red) ) ///
                        (line ub16 age_levels in 1/11, lcolor(red) lwidth(thin) lpattern(dash)) ///
                            (line lb16 age_levels in 1/11, lcolor(red) lwidth(thin) lpattern(dash)) , ///
                                legend(order( 3 "Less than HS" 6 "College Grad")) name(educ_ci)



/*Another Continuous-Continuous interaction*/

eststo age_iq : reg lwage hours age iq c.iq#c.age black married meduc south urban 

sum iq, detail

/* iq levels: low to high*/

    sum iq, detail

scalar iqlo=round(r(p10))
scalar iqhi=round(r(p90))

scalar diff=iqhi-iqlo
scalar step=round(diff/10)

/*Oh, Stata.*/

local iqlo=iqlo
local iqhi=iqhi
local step=step

foreach myiq of numlist `iqlo'(`step')`iqhi'{

estimates restore age_iq
    
margins, predict(xb) at((mean) _all age=(`mymin'(1)`mymax') iq=`myiq') post
mat pred_ed`myiq'=e(b)'
mat li pred_ed`myiq'
svmat pred_ed`myiq'

estimates restore age_iq

margins, predict(stdp) at((mean) _all age=(`mymin'(1)`mymax') iq=`myiq') nose post
mat pred_se_ed`myiq'=e(b)'
mat li pred_se_ed`myiq'
svmat pred_se_ed`myiq'
}


foreach myiq of numlist `iqlo'(`step')`iqhi'{
    gen exp_pred`myiq'=exp(pred_ed`myiq'1)
    gen ub`myiq'=exp(pred_ed`myiq'+(invttail(`mydf',`sigtail')*pred_se_ed`myiq'1))
    gen lb`myiq'=exp(pred_ed`myiq'-(invttail(`mydf',`sigtail')*pred_se_ed`myiq'1))
}

/*Kludge*/
    
local iqhi=118

/*For multiple levels */
twoway line exp_pred`iqlo' exp_pred90 exp_pred102 exp_pred`iqhi' age_levels in 1/11, ///
       legend(order(1 "10 Years" 2 "12 Years" 3 "14 Years" 4 "16 Years"))  ytitle("Wages") xtitle("Age") name(iq_mult)


/* Plot Result with confidence intervals*/

    twoway (rarea ub`iqlo' lb`iqlo' age_levels in 1/11, color(gs14)) ///
                (line exp_pred`iqlo' age_levels in 1/11, lcolor(blue) ) ///
                    (line ub`iqlo' age_levels in 1/11, lcolor(blue) lwidth(thin) lpattern(dash)) ///
                        (line lb`iqlo' age_levels in 1/11, lcolor(blue) lwidth(thin) lpattern(dash)) ///
                            (rarea ub`iqhi' lb`iqhi' age_levels in 1/11, color(gs14))  ///
                                 (line exp_pred`iqhi' age_levels in 1/11, lcolor(red) ) ///
                                     (line ub`iqhi' age_levels in 1/11, lcolor(red) lwidth(thin) lpattern(dash)) ///
                                         (line lb`iqhi' age_levels in 1/11, lcolor(red) lwidth(thin) lpattern(dash)) , ///
                                             legend(order( 2 "10th Percentile" 6 "90th Percentile")) xtitle("Age") ytitle("Predicted Wages") name(iqci)

exit 
