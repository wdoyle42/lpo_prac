/* Vanderbilt University */
/* Leadership, Policy and Organizations */
/* Class Number 9952 */
/* Spring 2017 */

/* **Assignment 8** */


/* 1. Using your own dataset, run a regression using a continuous variable as your dependent */
/* variable and several regressors. Report the results of at least two model */
/* specifications in a nice table. */

global ddir "../../data/"

use ${ddir}nlsy97.dta, clear

gen lyinc=log(yinc+1)

eststo main_model:reg lyinc ccol i.sex i.raceth exper mothed jobtenure
/* 2. Test for collinearity in the model. Describe the results of your test and say what */
/* you have decided to do as a result. */

estat vif    


/* 3. Test for heteroskedacity in the model. Describe the results of your test and say */
    /* what you have decided to do as a result. */

        estat hettest, iid
eststo model_revise: reg lyinc ccol i.sex i.raceth exper mothed jobtenure, vce(robust)

/* 4. Decide if any of your variables need to be rescaled and do so if necessary. */

reg lyinc c.ccol##c.ccol i.sex i.raceth exper mothed jobtenure, vce(robust) 
    
/* 5. Check on the functional form of your model using graphical approaches. Include */
/* some of these graphics in your paper. */


graph twoway scatter lyinc ccol, msize(tiny) || lowess lyinc ccol    
    
    
/* 6. If you decide the functional form needs to change, describe the changes made. */
/* Submit the descriptions of these tests and any tables or graphics generated in a */
/* Word or PDF document. */

 margins ,predict(xb) at((mean) _all ccol=(0(.2)4) ) post

marginsplot, recastci(rarea) recast(line)

