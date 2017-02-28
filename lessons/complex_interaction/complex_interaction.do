version 13
capture log close
log using "complex_interaction.log",replace

/* PhD Practicum, Spring 2017 */
/* Complex Interactions */
/* Will Doyle*/
/* 1/2817*/

clear
    
    // Data directory

global ddir "../../data/"
    
 /*Graph type postscript */
// local gtype ps

/* Graph type: pdf */
local gtype pdf

/* Graph type: eps */
//local gtype eps

clear

capture

use ${ddir}nlsy97, clear

gen log_inc=log(yinc)

gen lwage=log(hrwage)

gen female=sex==1

/* Work hours expressed in weaks*/

gen wkhrsw=wkhrsy/(365/7)    

local y log_inc

local x ccol 

local z wkhrsw

local ytitle "Income"

local xtitle "Months of College"

/* Mediating moderating, what to do? */

reg `y' `x' , robust
 
reg  `z' `x', robust

reg `y' `z' , robust

/* Controlling for intermediate outcomes*/

reg `y' `x' `z' , robust

/* Continuous/continuous interaction, quadratic, factor interaction, log transform of dv */

eststo fullmod: reg `y' c.ccol##c.asvab##i.female c.agem##c.agem i.female##i.raceth jobtenure ,robust

local mydf=e(df_r)

local sigtail=.025

/* Working with continuous vs. Continuous interactions */
sum asvab, detail

scalar asvablo=r(p10)
scalar asvabhi=r(p90)

scalar diff=asvabhi-asvablo /* Diff, hi vs. low*/
scalar step=diff/100

/*Oh, Stata.*/

local asvablo=asvablo
local asvabhi=asvabhi
local step=step


/*Step through education in 2 year intervals, get predictions across range of age*/

foreach myeduc of numlist 12(2)20{

estimates restore fullmod
    
quietly margins, predict(xb) at( ///
    asvab=(`asvablo'(`step')`asvabhi') ///
        ccol=`myeduc' ///
            female=1 ///
                race=2 ///
                    female=1 ///
                        (mean) jobtenure agem ///
                 ) ///
                nose post

mat pred_ed`myeduc'=e(b)'
mat li pred_ed`myeduc'
svmat pred_ed`myeduc'

estimates restore fullmod

quietly margins, predict(stdp) at((mean) _all age=(`asvablo'(`step')`asvabhi') ccol=`myeduc') nose post
mat pred_se_ed`myeduc'=e(b)'
mat li pred_se_ed`myeduc'
svmat pred_se_ed`myeduc'
}

// Exponentiatie
foreach myeduc of numlist 12(2)20{
    gen exp_pred`myeduc'=exp(pred_ed`myeduc'1)
    gen ub`myeduc'=exp(pred_ed`myeduc'+(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
    gen lb`myeduc'=exp(pred_ed`myeduc'-(invttail(`mydf',`sigtail')*pred_se_ed`myeduc'1))
}

/* Need my at values */

egen asvab_levels=fill(`asvablo'(`step')`asvabhi')    

twoway line exp_pred12 exp_pred14 exp_pred16 exp_pred18 asvab_levels in 1/101, ///
       legend(order(1 "12 Years" 2 "14 Years" 3 "16 Years" 4 "18 Years"))  ytitle("Income") xtitle("ASVAB Score") name(educ_mult, replace)

exit
