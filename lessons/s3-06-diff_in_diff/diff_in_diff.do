// Diff in diff using Stata 17 commands
// Will Doyle
// 2022-05-17

net install cleanplots, replace from("https://tdmize.github.io/data/cleanplots")

// Card and Krueger Study

// https://www.jstor.org/stable/2677856
use ck_min_wage, clear


gen fte = empft + emppt/2 + nmgrs 
drop if fte == .
bys store: gen nperiods = [_N]
keep if nperiods == 2

summarize fte if state==1 & time==0
summarize fte if state==1 & time==1
summarize fte if state==0 & time==0
summarize fte if state==0 & time==1

gen treatment = time*state
reg fte state time treatment, cluster(store)

xtset state
xtreg fte treatment time, fe 

xtset store

xtreg fte treatment time, fe vce(robust)

xtreg fte treatment time hoursopen, fe vce(robust)


// Parallel Trends

//https://www.stata.com/new-in-stata/difference-in-differences-DID-DDD/

webuse hospdd, clear

didregress (satis) (procedure), group(hospital) time(month)

estat trendplots

estat ptrends

estat grangerplot

estat grangerplot, nodraw verbose


// Two Way FE

// https://doi-org.proxy.library.vanderbilt.edu/10.1002/(SICI)1099-1255(199803/04)13:2%3C163::AID-JAE460%3E3.0.CO;2-Y

use wagepan, clear

xtset nr year

xtreg lwage union  i.year

xtdidregress (lwage) (union), group(nr) time(year) 




