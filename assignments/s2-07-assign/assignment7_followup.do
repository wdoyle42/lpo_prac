


// Assignment 7 Followup
// Will Doyle
// 3/19/19


global ddir "../../data/"

use ${ddir}plans3.dta, clear

gen plan_college=p_cc==1|p_fouryr==1
replace plan_college=. if f1psepln==.

cor byses1 pared_bin plan_college

mat cormat=r(C)

sum pared_bin

local prop_pared=r(mean) 

sum plan_college

local prop_plan_college=r(mean)

// Get plausible coefficients

reg bynels2m byses1 pared_bin plan_college




local ses_coeff=_b[byses1]

local pared_coeff=_b[pared_bin]

local plan_coeff=_b[plan_college]

local intercept=_b[_cons]

local rmse=e(rmse)

clear

set obs 100000

// Generate data with right correlation structure 
corr2data fakeses fake_pared_st fake_plan_college_st, corr(cormat)

gen pared_cut=invnormal(`prop_pared')    
gen fake_pared=fake_pared_st>pared_cut

gen plan_cut=invnormal(`prop_plan_college')    
gen fake_plan_college=fake_plan_college_st>plan_cut

drop fake_pared_st fake_plan_college_st plan_cut pared_cut

drawnorm e, mean(0) sd(`rmse')

gen y =`intercept'+`ses_coeff'*fakeses+ ///
		`pared_coeff'*fake_pared+ ///
		`plan_coeff'*fake_plan_college+e

		
tempname results_store
postfile `results_store' plans1 plans2  using results_file, replace
local j=1  
while `j'<=100{  

preserve

sample 1000, count		

quietly reg y fakeses fake_pared fake_plan_college

scalar plans1=_b[fake_plan_college]

quietly reg y fakeses fake_plan_college

scalar plans2=_b[fake_plan_college]

post `results_store' (plans1) (plans2)

restore

local j=`j'+1
}

postclose `results_store'

use results_file, clear

kdensity plans1, xline(`plan_coeff', lcolor(blue) lstyle(dash)) /// 
addplot(kdensity plans2) legend(order(1 "True Model" 2 "OVB Model"))

// Full Monte Carlo Study

local pared_effect 5 10 15 20

foreach pared_coeff of local pared_effect{

clear

set obs 100000

// Generate data with right correlation structure 
corr2data fakeses fake_pared_st fake_plan_college_st, corr(cormat)

gen pared_cut=invnormal(`prop_pared')    
gen fake_pared=fake_pared_st>pared_cut

gen plan_cut=invnormal(`prop_plan_college')    
gen fake_plan_college=fake_plan_college_st>plan_cut

drop fake_pared_st fake_plan_college_st plan_cut pared_cut

drawnorm e, mean(0) sd(`rmse')

gen y =`intercept'+`ses_coeff'*fakeses+ ///
		`pared_coeff'*fake_pared+ ///
		`plan_coeff'*fake_plan_college+e

		
tempname results_store
postfile `results_store' plans1 plans2  using results_file_`pared_coeff', replace
local j=1  
while `j'<=100{  

preserve

sample 1000, count		

quietly reg y fakeses fake_pared fake_plan_college

scalar plans1=_b[fake_plan_college]

quietly reg y fakeses fake_plan_college

scalar plans2=_b[fake_plan_college]

post `results_store' (plans1) (plans2)

restore

local j=`j'+1
}

postclose `results_store'

use results_file_`pared_coeff', clear

kdensity plans1, xline(`plan_coeff', lcolor(blue) lstyle(dash)) /// 
addplot(kdensity plans2) legend(order(1 "True Model" 2 "OVB Model"))

graph save "mc_results_`pared_coeff'.gph"
}		

graph combine mc_results_5.gph mc_results_10.gph mc_results_15.gph mc_results_20.gph

exit 


