
/******************************************************************************/
// TI: Recovery from cuts
// AU: Will Doyle and Jennifer Delaney
// INIT: 5/21/2018
// REV: 5/29/2018
// This script creates tables and graphics from prepared data files
// investigating factors that influence time until recovery from
// cuts in higher education of various sizes
/******************************************************************************/

//Recoding 

replace tuition_i=tuition_i/1000

// Covariates

// Economic Characteristics
local econ med_inc unemploy gini

// Higher Education Characteristics
local higher_ed tuition_i 

// Demographic Characteristics
local demog pct_pop65p 

// Diffusion
local diffusion i.region

// Political Characteristics
local politics prop_all_dem

use shefo_surv_5.dta, clear
   
stset t, failure(recovery)

sts list

sts graph, xtitle("Years Until Recovery") title("") 

// Stratified Graph
sts graph, by(govparty_c) xtitle ("Years Until Recovery") ///
                                  plot2opts(lwidth(0)) ///
                                  plot3opts(lpattern(dash)) ///
                                  legend(order(1 "Republican" 3 "Democrat")) ///
                                  title("")

								  
// Discrete-time Logit

logit recovery `econ' i.t
						
logit recovery `demog' i.t

logit recovery `politics' i.t

logit recovery `higher_ed' i.t

logit recovery `diffusion' i.t

logit recovery `econ' `demog' `politics' `higher_ed' `diffusion'
								  
    
//     // Economics

    eststo econ_`cut_size': stcox `econ'

    // Demographics

    eststo demog_`cut_size': stcox `demog'
    
    // Politics

    eststo politics_`cut_size': stcox `politics'
    
    // Higher Education

    eststo higher_ed_`cut_size': stcox  `higher_ed'
    
    // Diffusion
    eststo diffusion_`cut_size':stcox `diffusion'
    
    // Full model
    eststo full_`cut_size': stcox `econ' `demog' `politics' `higher_ed' `diffusion' , basesurv(surv_est)

    esttab econ_`cut_size' ///
           demog_`cut_size' ///                    
           politics_`cut_size' ///
           higher_ed_`cut_size' ///
           full_`cut_size' ///
           using "results_`cut_size'.rtf", replace ///  
           eform ///
           b(2) ///
           ci(2) ///
           label ///
           scalar(chi2 N) ///
           sfmt(2 0) ///
          nodepvars  
	
	
estimates restore full_`cut_size'

        stcurve, surv at1(tuition_i=2000) at2(tuition_i=5000) at3(tuition_i=13000) ///
           legend(order(1 "Tuition= 2,000" 2 "Tuition=5,000" 3 "Tuition=13,000")) 
   
logit recovery `econ' `demog' `politics' `higher_ed' `diffusion' i.t
