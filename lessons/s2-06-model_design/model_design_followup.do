version 15 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "model_design_do.log",replace /*Open up new log */

/* Model specification, interactions, prediction and plots after interaction*/
/* Will Doyle */
/* 2019-02-19 */
/* Practicum Folder */

clear

clear matrix

graph drop _all

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */

//ssc install bcuse

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

gen analytic_sample_flag=e(sample)

reg lwage hours educ age if analytic_sample_flag==1 

reg lwage hours educ age meduc if analytic_sample_flag==1 

gen meduc_flag=meduc==.

gen feduc_flag=feduc==.

tab meduc_flag feduc_flag

/* Quick digression: log transform */

preserve

clear

di log(0)
di log(1)
di log(10)
di log(100)
di log(1000)

set obs 1000

egen fakenumber= fill(1(10)1000)

gen log_fakenumber=log(fakenumber)

graph twoway line log_fakenumber fakenumber

restore

/*NOOOOOOOO!!! Stepwise regression*/

stepwise, pr(.2): reg lwage hours educ age meduc feduc tenure south married black urban sibs kww iq brthord

stepwise, pr(.05): reg lwage hours educ age meduc feduc tenure south married black urban sibs kww iq brthord

stepwise, pr(.2) : reg lwage south brthord iq kww sibs feduc tenure  married black urban hours educ age meduc

stepwise, pr(.05): reg lwage south brthord iq kww sibs feduc tenure  married black urban hours educ age meduc
  
stepwise, pr(.2) : reg lwage south brthord  kww sibs feduc tenure  married black  hours educ age meduc

stepwise, pr(.05): reg lwage south brthord  kww sibs feduc tenure  married black  hours educ age meduc

/*Functional Form */

/* F Test */

reg lwage south brthord kww sibs feduc tenure married black hours educ age meduc

test meduc feduc

test meduc=feduc

test educ tenure hours


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
								
/*Binary-binary interaction*/

gen black_marry=black*married
  
eststo black_marry: reg lwage hours age educ i.black##i.married iq meduc south urban


/*Binary-continous interaction*/

/* PLotting interactions in raw data */

gen educ_adj=educ+.2
  
graph twoway (scatter wage educ if black==0, msize(small) mcolor(red)) ///
    (scatter wage educ_adj if black==1, msize(small) mcolor(blue))   ///
        (lfit wage educ if black==0, lcolor(red))  ///
            (lfit wage educ if black==1, lcolor(blue)), ///
			legend(order(1 "White" 2 "Black")) 
			
graph twoway (scatter wage educ if married==0, msize(small) mcolor(red)) ///
    (scatter wage educ_adj if married==1, msize(small) mcolor(blue))   ///
        (lfit wage educ if married==0, lcolor(red))  ///
            (lfit wage educ if married==1, lcolor(blue)), ///
                legend(order(1 "Unmarried" 2 "Married")) 			

				
graph export interact1.pdf, replace

eststo black_educ: reg lwage hours age i.black##c.educ married  iq meduc south urban

test 1.black educ 1.black#c.educ

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
drop mycount    

eststo urban_south: reg lwage hours age educ black married iq meduc i.south##i.urban 

local mydf=e(df_r)

margins , predict(xb) at(urban=(1 0) south=(0 1) black=1 married=1 (mean) hours age educ iq meduc ) post

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

margins , predict(stdp) at((mean) _all urban=(1 0) south=(0 1) black=1 married=1) post nose

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
                        xlabel(1 "Urban, Non-South" 2 "Urban, South" 3 "Non-Urban, Non-South" 4 "Non-Urban, South") ytitle("Predicted Wages")   xtitle("") legend(off)

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
                                legend(order( 3 "Less than HS" 6 "College Grad"))  xtitle("Age") name(educ_ci)


drop lb* ub* exp_pred* pred* pred_ed* pred_se_ed*

/* Run a regression of log wages as a function of the interaction of
educ and knowledge of world of work (kww). Include other covariates as you
see fit. Plot the results of the interaction after generating predictions from the 
margins command */

********************Begin KWW ************************

eststo wage_kww: reg lwage c.educ##c.kww age hours

sum kww, detail

local mymin=r(min)
local mymax=r(max)

/*Step through education in 2 year intervals, get predictions across range of age*/

foreach myeduc of numlist 10(2)16{

estimates restore wage_kww
    
margins, predict(xb) at((mean) _all kww=(`mymin'(1)`mymax') educ=`myeduc') post
mat pred_ed`myeduc'=e(b)'
mat li pred_ed`myeduc'
svmat pred_ed`myeduc'

estimates restore wage_kww

margins, predict(stdp) at((mean) _all kww=(`mymin'(1)`mymax') educ=`myeduc') nose post
mat pred_se_ed`myeduc'=e(b)'
mat li pred_se_ed`myeduc'
svmat pred_se_ed`myeduc'
}

foreach myeduc of numlist 10(2)16{
    gen exp_pred`myeduc'=exp(pred_ed`myeduc'1)
    gen ub`myeduc'=exp(pred_ed`myeduc'+(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
    gen lb`myeduc'=exp(pred_ed`myeduc'-(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
}

egen kww_levels=fill(`mymin'(1)`mymax')    

twoway line exp_pred10 exp_pred12 exp_pred14 exp_pred16 kww_levels in 1/45, ///
       legend(order(1 "10 Years" 2 "12 Years" 3 "14 Years" 4 "16 Years")) ///
	   ytitle("Wages") xtitle("Knowledge of World of Work") name(educ_mult_kww)

exit 


********************END KWW ************************


eststo ten_educ: reg lwage hours age black married iq meduc c.tenure##c.educ 
						
/* Working with continuous vs. Continuous interactions */
sum educ, detail

local mymin=r(min)
local mymax=r(max)

/*Step through tenure in 5 year intervals */

foreach mytenure of numlist 0(5)20{

estimates restore ten_educ
    
margins, predict(xb) at((mean) _all educ=(`mymin'(1)`mymax') tenure=`mytenure') post
mat pred_ed`mytenure'=e(b)'
mat li pred_ed`mytenure'
svmat pred_ed`mytenure'

estimates restore ten_educ

margins, predict(stdp) at((mean) _all educ=(`mymin'(1)`mymax') tenure=`mytenure') nose post
mat pred_se_ed`mytenure'=e(b)'
mat li pred_se_ed`mytenure'
svmat pred_se_ed`mytenure'
}

foreach mytenure of numlist 0(5)20{
    gen exp_pred`mytenure'=exp(pred_ed`mytenure'1)
    gen ub`mytenure'=exp(pred_ed`mytenure'+(invttail(`mydf',`sigtail')*pred_se_ed`mytenure'1))
    gen lb`mytenure'=exp(pred_ed`mytenure'-(invttail(`mydf',`sigtail')*pred_se_ed`mytenure'1))
}

/* Need my at values */

egen educ_levels=fill(`mymin'(1)`mymax')    

twoway line exp_pred0 exp_pred5 exp_pred10 exp_pred15 exp_pred15 educ_levels in 1/10, ///
       legend(order(1 "0 Years" 2 "5 Years" 3 "10 Years" 4 "15 Years" 5 "20 Years"))  ytitle("Wages") xtitle("Education") name(tenure_mult)



/*Another Continuous-Continuous interaction*/

eststo age_iq : reg lwage hours age iq c.iq#c.age black married meduc south urban 

sum iq, detail

/* iq levels: low to high*/

    sum iq, detail

scalar iqlo=round(r(p10))
scalar iqhi=round(r(p90))

//for later
local iqhi=round(r(p90))

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


// Kludge
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
