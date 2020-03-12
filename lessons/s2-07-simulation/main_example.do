capture log close

// Main Example
// Will Doyle
// Simplifying the code to main example
// 2020-02-27

local female female
    
local ses byses1
    
local pared pared_bin 
    
local race urm 

local plans p_fouryr 

local y bynels2m 

local popsize =1.6e5

local nreps 1000

use ${ddir}plans3.dta, clear
    
/*Stuff we'll want later */

prop `female'

local prop_fem=_b[1]

prop `plans'

local prop_plans=_b[1]

prop `race'

local prop_race=_b[1]

prop `pared'

local prop_pared=_b[1]

corr `female' `plans' `race' `pared' `ses'

mat cormat=r(C)


/*Survey set */
svyset psu [pw=f1pnlwt],str(strat_id)

/*Run regression*/
    
svy: reg `y' `female' `plans' `race' `pared' `ses'

eststo myresults

/*Grab coeffs*/

local int=_b[_cons]    

local fem_coeff=_b[`female']

di `fem_coeff'

local plans_coeff=_b[`plans']

local race_coeff=_b[`race']

local pared_coeff=_b[`pared']

local ses_coeff=_b[`ses']

clear

// Create Characteristics of unobserved "counseling" variable

mat newcol=(0.01\.5\-.2\.5\.5) /*Adds a column */

mat cormat2=cormat,newcol

mat cormat2=cormat2\0.01,.5,-.2,.5,.5,1 /*Adds a row */

mat li cormat2

corr2data female_st plans_st race_st pared_st ses counsel_st, corr(cormat2) n(`popsize')

/*Specify cut in normal dist for proportion with and without characteristics*/

gen femcut=invnormal(`prop_fem')    
gen female=female_st>femcut

gen paredcut=invnormal(`prop_pared')
gen pared= pared_st>paredcut 

gen plancut=invnormal(`prop_plans') 
gen plans=plans_st>plancut 

local race_other=1-`prop_race'

gen racecut=invnormal(`race_other') 
gen race=race_st>racecut 

local prop_counsel=.95
    
gen counselcut=invnormal(`prop_counsel') 
gen counsel=counsel_st>counselcut

mat li cormat

corr female plans race pared ses


drawnorm e, sds(11)

local effect 2

gen y=`int'+(`fem_coeff'*female)+(`plans_coeff'*plans)+(`race_coeff'*race)+(`pared_coeff'*pared)+(`ses_coeff'*ses) + (`effect'*counsel)+e

keep y female plans race pared ses counsel e

preserve

sample 10

reg y female plans race pared ses counsel /* True regression */

reg y female plans race pared ses /*OVB regression */

restore


/*Monte Carlo Study */

drop y

local effect 10 /* Size of the effect of counseling, can vary with each iteration */

gen y=`int'+(`fem_coeff'*female)+(`plans_coeff'*plans)+(`race_coeff'*race)+(`pared_coeff'*pared)+(`ses_coeff'*ses) + (`effect'*counsel)+e
    
save counsel_universe_`effect', replace

tempname results_store
postfile `results_store' plans1 plans2  using results_file, replace
local j=1  
while `j'<=100{  

use counsel_universe_`effect',clear  
  
quietly sample 10

quietly reg y female plans race pared ses counsel /* True regression */

scalar plans1=_b[plans]

 /*Pulls coefficient, puts it into scalar */
quietly reg y female plans race pared ses /*OVB regression */

scalar plans2=_b[plans]

post `results_store' (plans1) (plans2)

di "Finishing iteration `j'"

local j=`j'+1
}
postclose `results_store'

use results_file, clear

kdensity plans1, xline(`plans_coeff', lcolor(blue) lstyle(dash)) /// 
addplot(kdensity plans2) legend(order(1 "True Model" 2 "OVB Model"))


/*Now vary effect size*/

local effect_size 5 10 15 20

foreach effect of local effect_size{

use counsel_universe_10, replace
    
drop y

gen y=`int'+(`fem_coeff'*female)+(`plans_coeff'*plans)+(`race_coeff'*race)+(`pared_coeff'*pared)+(`ses_coeff'*ses) + (`effect'*counsel)+e
    
save counsel_universe_`effect', replace

tempname results_store
postfile `results_store' plans1 plans2  using results_file_`effect', replace
local j=1  
while `j'<=100{  

use counsel_universe_`effect',clear  
  
quietly sample 10

quietly reg y female plans race pared ses counsel /*True model */

scalar plans1=_b[plans]

 /*Pulls coefficient, puts it into scalar */
quietly reg y female plans race pared ses /*OVB model*/

scalar plans2=_b[plans]

post `results_store' (plans1) (plans2)

di "Finishing iteration `j'"

local j=`j'+1
}

postclose `results_store'

use results_file_`effect', clear

kdensity plans1, xline(`plans_coeff', lcolor(black) lpattern(dash)) ///
	addplot(kdensity plans2,note("")) ///
	legend(order(1 "True Model" 2 "OVB Model")) ///
	xtitle("Coefficients for Plan") ///
	title("Coefficient for Counseling=`effect'") ///
	note("")

graph save monte_carlo_`effect'.gph, replace

}

/* Ends loop over effect sizes */

grc1leg monte_carlo_5.gph ///
monte_carlo_10.gph ///
 monte_carlo_15.gph monte_carlo_20.gph , rows(2) cols(2)
}
