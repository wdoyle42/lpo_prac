/* Working with diff in diffs data */

use eitc.dta, clear

/*Setup */

gen treat=children>0

gen post=year>1993

gen treat_post=treat*post

/* Four groups */

gen no_treat_before=treat==0&post==0

gen no_treat_after=treat==0&post==1

gen treat_before=treat==1&post==0

gen treat_after=treat==1&post==1

/*Unconditional diff in diffs */

mean work if no_treat_before==1

mat result=e(b)

scalar mean_no_treat_before=result[1,1]

scalar li mean_no_treat_before

mean work if no_treat_after==1

mat result=e(b)

scalar mean_no_treat_after=result[1,1]

mean work if treat_before==1

mat result=e(b)

scalar mean_treat_before=result[1,1]

mean work if treat_after==1

mat result=e(b)

scalar mean_treat_after=result[1,1]

scalar change_notreat=mean_no_treat_after-mean_no_treat_before

scalar change_treat=mean_treat_after-mean_treat_before

scalar diff_diffs=change_treat-change_notreat

scalar li diff_diffs

exit 

save eitc_new, replace

/*Plot */

collapse work, by(year treat)

graph twoway line work year if treat==0 || line work year if treat==1, ytitle("Labor Force Participation") xtitle("Year") xline(1993) legend(order(1 "LFP Single Women" 2 "LFP Single Mothers"))

/*Regression */

use eitc_new, clear

reg work treat post treat_post

/*Four groups */

di _b[_cons]

scalar li mean_no_treat_before

di _b[_cons]+_b[post]

scalar li mean_no_treat_after

di _b[_cons]+_b[treat]

scalar li mean_treat_before

di _b[_cons]+_b[treat]+_b[post]+_b[treat_post]

scalar li mean_treat_after

/*With covariates */

reg work treat post treat_post urate nonwhite age ed unearn

/*With covariates and robust se's */

reg work treat post treat_post urate nonwhite age ed unearn, vce(robust)

  
/*With covariates and clustered se's on states */

reg work treat post treat_post urate nonwhite age ed unearn, vce(cluster state)
 
/* With covariates, clustered se's and fixed effects for years: does this make sense to do? */

xi: reg work treat post treat_post urate nonwhite age ed unearn i.year, vce(cluster state)

/* Fixed effects for states */

xi: reg work treat post treat_post urate nonwhite age ed unearn i.state

/* Fixed effects for states and years: again, does this make sense? */

xi: reg work treat post treat_post urate nonwhite age ed unearn i.state i.year

/* Alternate */

xtset state

xtreg work treat post treat_post urate nonwhite age ed unearn i.year, fe




