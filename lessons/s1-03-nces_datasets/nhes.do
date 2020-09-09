
capture log close

log using "nhes.log"

// Accessing NHES data
// Will Doyle
// 2020-09-08

use ///
 BASMID /// 
 CPNNOWX ///
 CPTYPE ///
 CPHRS ///
 using  "nhes_16_ecpp_v1_0.dta" , clear
 
 renvars *, lower
 
save "nhes_analysis.dta", replace  

exit
